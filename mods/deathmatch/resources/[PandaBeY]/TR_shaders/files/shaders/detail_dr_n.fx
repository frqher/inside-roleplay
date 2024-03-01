//
// Example shader - detail_dr_n.fx
//


//---------------------------------------------------------------------
// Detail settings
//---------------------------------------------------------------------
texture sDetailTexture;
float sDetailScale = 8;         // Repeat interval of the texture
float sFadeStart = 10;          // Near point where distance fading will start
float sFadeEnd = 80;            // Far point where distance fading will complete (i.e. effect will not be visible past this point)
float sStrength = 0.5;          // 0 to 1 for the strength of the effect
float sAnisotropy = 0.0;        // 0 to 1 for the amount anisotropy of the effect - Higher looks better but can be slower

float2 sHalfPixel = float2(0.000625,0.00083);
float sTextureSize = 512.0;
float sLerpNormal = 0.5;

//---------------------------------------------------------------------
// Render targets
//---------------------------------------------------------------------
texture colorRT < string renderTarget = "yes"; >;
texture depthRT < string renderTarget = "yes"; >;
texture normalRT < string renderTarget = "yes"; >;

//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
//#define GENERATE_NORMALS // Uncomment for normals to be generated
#include "mta-helper.fx"


//---------------------------------------------------------------------
// Extra renderstates which we use
//---------------------------------------------------------------------
int gCapsMaxAnisotropy < string deviceCaps="MaxAnisotropy"; >;
float gAlphaRef < string renderState="ALPHAREF"; >;

//---------------------------------------------------------------------
// Sampler for the main texture
//---------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy * sAnisotropy;
    MinFilter = Anisotropic;
};

sampler SamplerDepthTex = sampler_state
{
    Texture = (depthRT);
    AddressU = Clamp;
    AddressV = Clamp;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = None;
    SRGBTexture = false;
    MaxMipLevel = 0;
    MipMapLodBias = 0;
};

//---------------------------------------------------------------------
// Sampler for the detail texture
//---------------------------------------------------------------------
sampler SamplerDetail = sampler_state
{
    Texture = (sDetailTexture);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy * sAnisotropy;
    MinFilter = Anisotropic;
};


//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VertexShaderInput
{
  float3 Position : POSITION0;
  float3 Normal : NORMAL0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PixelShaderInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
  float4 Normal : TEXCOORD1;
  float2 DistFade : TEXCOORD2;
  float4 Depth : TEXCOORD3;
  float3 WorldPos : TEXCOORD4;
  float3 TexProj : TEXCOORD5;
  float4 ViewPos : TEXCOORD6;
};

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PixelShaderInput VertexShaderFunction(VertexShaderInput VS)
{
    // Initialize result
    PixelShaderInput PS = (PixelShaderInput)0;

    if (gDeclNormal != 1) PS.Normal = float4(1,1,1,0);
    else PS.Normal = float4(mul(VS.Normal, (float3x3)gWorld), 1);

    // Calculate screen pos of vertex
    float4 worldPos = mul(float4(VS.Position.xyz, 1), gWorld);
    PS.WorldPos = worldPos.xyz;
    float4 viewPos = mul(worldPos, gView);
    PS.ViewPos = viewPos;

    PS.Position = mul(viewPos, gProjection);

    // Pass through tex coord
    PS.TexCoord = VS.TexCoord;

    // Calculate GTA lighting for buildings
    PS.Diffuse = MTACalcGTABuildingDiffuse(VS.Diffuse);

    // Set texCoords for projective texture
    float projectedX = (0.5 * (PS.Position.w + PS.Position.x));
    float projectedY = (0.5 * (PS.Position.w - PS.Position.y));
    PS.TexProj.xyz = float3(projectedX, projectedY, PS.Position.w);

    // Pass depth
    PS.Depth = float4(PS.Position.z, PS.Position.w, viewPos.z, viewPos.w);

    // Distance fade calculation
    float DistanceFromCamera = MTACalcCameraDistance( gCameraPosition, worldPos.xyz );
    PS.DistFade.x = 1 - ( ( DistanceFromCamera - sFadeStart ) / ( sFadeEnd - sFadeStart ) );

    // Return result
    return PS;
}

//--------------------------------------------------------------------------------------
//-- Use the last scene projecion matrix to linearize the depth value a bit more
//--------------------------------------------------------------------------------------
float Linearize(float posZ)
{
    return gProjection[3][2] / (posZ - gProjection[2][2]);
}

float InvLinearize(float posZ)
{
    return (gProjection[3][2] / posZ) + gProjection[2][2];
}

//------------------------------------------------------------------------------------------
// Pack Unit Float [0,1] into RGB24
//------------------------------------------------------------------------------------------
float3 UnitToColor24New(in float depth)
{
    // Constants
    const float3 scale	= float3(1.0, 256.0, 65536.0);
    const float2 ogb	= float2(65536.0, 256.0) / 16777215.0;
    const float normal	= 256.0 / 255.0;

    // Avoid Precision Errors
    float3 unit	= (float3)depth;
    unit.gb	-= floor(unit.gb / ogb) * ogb;

    // Scale Up
    float3 color = unit * scale;

    // Use Fraction to emulate Modulo
    color = frac(color);

    // Normalize Range
    color *= normal;

    // Mask Noise
    color.rg -= color.gb / 256.0;

    return color;
}

//------------------------------------------------------------------------------------------
// Unpack RGB24 into Unit Float [0,1]
//------------------------------------------------------------------------------------------
float ColorToUnit24New(in float3 color) {
    const float3 scale = float3(65536.0, 256.0, 1.0) / 65793.0;
    return dot(color, scale);
}

//------------------------------------------------------------------------------------------
// Pack Unit float [nearClip,farClip] Unit Float [0,1]
//------------------------------------------------------------------------------------------
float DistToUnit(in float dist, in float nearClip, in float farClip)
{
    float unit = (dist - nearClip) / (farClip - nearClip);
    return unit;
}

//------------------------------------------------------------------------------------------
// Pack Unit Float [0,1] to Unit float [nearClip,farClip]
//------------------------------------------------------------------------------------------
float UnitToDist(in float unit, in float nearClip, in float farClip)
{
    float dist = (unit * (farClip - nearClip)) + nearClip;
    return dist;
}

//------------------------------------------------------------------------------------------
// CotangentFrame
//------------------------------------------------------------------------------------------
float3x3 CotangentFrame(float3 N, float3 p, float2 uv)
{
    // get edge vectors of the pixel triangle
    float3 dp1 = ddx( p );
    float3 dp2 = ddy( p );
    float2 duv1 = ddx( uv );
    float2 duv2 = ddy( uv );

    // solve the linear system
    float3 dp2perp = cross( dp2, N );
    float3 dp1perp = cross( N, dp1 );
    float3 T = dp2perp * duv1.x + dp1perp * duv2.x;
    float3 B = dp2perp * duv1.y + dp1perp * duv2.y;

    // construct a scale-invariant frame
    float invmax = rsqrt( max( dot(T,T), dot(B,B) ) );
    return float3x3( -T * invmax, -B * invmax, N );
}

//------------------------------------------------------------------------------------------
// ComputeNormalsPS
//------------------------------------------------------------------------------------------
// The Sobel filter extracts the first order derivates of the image,
// that is, the slope. The slope in X and Y directon allows us to
// given a heightmap evaluate the normal for each pixel. This is
// the same this as ATI's NormalMapGenerator application does,
// except this is in hardware.
//
// These are the filter kernels:
//
//  SobelX       SobelY
//  1  0 -1      1  2  1
//  2  0 -2      0  0  0
//  1  0 -1     -1 -2 -1

float3 ComputeNormalsPS(sampler2D sample, float2 texCoord, float4 lightness, float tSize)
{
    float off = 1.0 / tSize;

    // Take all neighbor samples
    float4 s00 = tex2D(sample, texCoord + float2(-off, -off));
    float4 s01 = tex2D(sample, texCoord + float2( 0,   -off));
    float4 s02 = tex2D(sample, texCoord + float2( off, -off));

    float4 s10 = tex2D(sample, texCoord + float2(-off,  0));
    float4 s12 = tex2D(sample, texCoord + float2( off,  0));

    float4 s20 = tex2D(sample, texCoord + float2(-off,  off));
    float4 s21 = tex2D(sample, texCoord + float2( 0,    off));
    float4 s22 = tex2D(sample, texCoord + float2( off,  off));

    // Slope in X direction
    float4 sobelX = s00 + 2 * s10 + s20 - s02 - 2 * s12 - s22;
    // Slope in Y direction
    float4 sobelY = s00 + 2 * s01 + s02 - s20 - 2 * s21 - s22;

    // Weight the slope in all channels, we use grayscale as height
    float sx = dot(sobelX, lightness);
    float sy = dot(sobelY, lightness);

    // Compose the normal
    float3 normal = normalize(float3(sx, sy, 1));

    // Pack [-1, 1] into [0, 1]
    return float3(normal * 0.5 + 0.5);
}

//------------------------------------------------------------------------------------------
// MTAApplyFog
//------------------------------------------------------------------------------------------
int gFogEnable                     < string renderState="FOGENABLE"; >;
float4 gFogColor                   < string renderState="FOGCOLOR"; >;
float gFogStart                    < string renderState="FOGSTART"; >;
float gFogEnd                      < string renderState="FOGEND"; >;

float3 MTAApplyFog( float3 texel, float distFromCam )
{
    if ( !gFogEnable )
        return texel;
    float FogAmount = ( distFromCam - gFogStart )/( gFogEnd - gFogStart );
    texel.rgb = lerp(texel.rgb, gFogColor.rgb, saturate( FogAmount) );
    return texel;
}

//------------------------------------------------------------------------------------------
// Structure of color data sent to the renderer ( from the pixel shader  )
//------------------------------------------------------------------------------------------
struct Pixel
{
    float4 World : COLOR0;      // Render target #0
    float4 Color : COLOR1;      // Render target #1
    float4 Depth : COLOR2;      // Render target #2
    float4 Normal : COLOR3;      // Render target #3
};

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
Pixel PixelShaderFunction(PixelShaderInput PS)
{
    Pixel output;

    // Get projective texture coords
    float2 TexProj = PS.TexProj.xy / PS.TexProj.z;
    TexProj += sHalfPixel.xy;

    // Get texture pixel
    float4 texel = tex2D(Sampler0, PS.TexCoord);

    // Get detail pixel
    float4 texelDetail1 = tex2D(SamplerDetail, PS.TexCoord * sDetailScale );
    float4 texelDetail2 = tex2D(SamplerDetail, PS.TexCoord * sDetailScale * 1.9 );
    float4 texelDetail3 = tex2D(SamplerDetail, PS.TexCoord * sDetailScale * 3.6 );
    float4 texelDetail4 = tex2D(SamplerDetail, PS.TexCoord * sDetailScale * 7.4 );

    float4 texelDetail = texelDetail1 * texelDetail2 * 2 * texelDetail3 * 2 * texelDetail4 * 2;

    // Apply diffuse lighting
    float4 Color = texel * PS.Diffuse;

    // Attenuate detail depending on pixel distance and user setting
    float detailAmount = saturate( PS.DistFade.x ) * sStrength;
    float4 texelDetailToUse = lerp ( 0.5, texelDetail, detailAmount );

    // Add detail
    float4 finalColor = Color * texelDetailToUse * 2;
    finalColor.a = Color.a;

     finalColor.rgb = MTAApplyFog(finalColor.rgb, PS.Depth.z / PS.Depth.w);
    output.World = saturate(finalColor);

    // Depth render target
	float depth = (PS.Depth.x / PS.Depth.y) * 0.5;

    // Get packed depth texture
    float3 packedDepth = tex2D(SamplerDepthTex, TexProj).rgb;

    // Unpack depth texture
    float depthVal = ColorToUnit24New(packedDepth);

    // Compare with current pixel depth
    if (depthVal >= depth * 0.9999f)
    {
        // Color render target
        output.Color.rgb = saturate(texel.rgb * texelDetailToUse.rgb * 2);
        output.Color.a = texel.a * PS.Diffuse.a;

        // Depth render target
        output.Depth.rgb = UnitToColor24New(depth);
        output.Depth.a = 1;

        float3 worldNormalVS = normalize(PS.Normal.xyz);
        if (PS.Normal.w == 0)
        {
            // Compute the surface normal in the fragment shader.
            float3 viewNormal = normalize(cross(ddx(PS.ViewPos.xyz), ddy(PS.ViewPos.xyz)));
            float3 worldNormal = mul(viewNormal, (float3x3)gViewInverse);
            worldNormalVS = worldNormal;

        }

        // Normal render target
        float3x3 tangentToWorldSpace = CotangentFrame(worldNormalVS, PS.WorldPos.xyz - gCameraPosition, PS.TexCoord);

        float3 NormalTex = ComputeNormalsPS(Sampler0, PS.TexCoord.xy, texel, sTextureSize);

        // get normal vector
        NormalTex.xyz = normalize((NormalTex.xyz * 2.0) - 1.0);
        float3 Normal = normalize(NormalTex.x * normalize(tangentToWorldSpace[0]) - NormalTex.y *
            normalize(tangentToWorldSpace[1]) + NormalTex.z * normalize(tangentToWorldSpace[2]));
        Normal = lerp(worldNormalVS, normalize(Normal), sLerpNormal * saturate(20 / (PS.Depth.z / PS.Depth.w)));
        output.Normal = float4((Normal.xyz * 0.5) + 0.5, 1);
    }
    else
    {
        // Color render target
        output.Color = 0;

        // Depth render target
        output.Depth = 0;

       // Normal render target
       output.Normal = 0;
    }

    return output;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------

technique detail_dr_n
{
    pass P0
    {
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader = compile ps_3_0 PixelShaderFunction();
    }
}

technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
