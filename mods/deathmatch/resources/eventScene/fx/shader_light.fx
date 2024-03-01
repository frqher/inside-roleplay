// shader_light.fx
//
// Author: Ren712/AngerMAN

texture gBallTexture;

float3 gRotAngle = (0,0,0);
float4 gLightFade = (150,110,75,55);
float gSelfShad=0.35;
bool isVeh = false;
bool isFakeBump = true;
bool isStr = false;
float3 sLightPosition = float3(50,50,50); 
float2 rc = float2(0.0018,0.0015); // fake bump parameter
 
#define GENERATE_NORMALS 
#include "mta-helper.fx"
#include "lightutil.fx" 

//---------------------------------------------------------------------
//-- Sampler for the main texture (needed for pixel shaders)
//---------------------------------------------------------------------

samplerCUBE cubeMapSampler = sampler_state
{
	Texture = (gBallTexture);
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	MIPMAPLODBIAS = 0.000000;
};

sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};

//---------------------------------------------------------------------
//-- Structure of data sent to the vertex shader
//--------------------------------------------------------------------- 
 
 struct VSInput
{
	float4 Position : POSITION; 
	float3 TexCoord : TEXCOORD0;
	float4 Diffuse : COLOR0;
	float4 Normal : NORMAL0;
};

//---------------------------------------------------------------------
//-- Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------

struct PSInput
{
	float4 Position : POSITION;
	float2 TexCoord : TEXCOORD0;	
	float3 SpTexCoord : TEXCOORD1;
	float DistFade : TEXCOORD2;
	float LightFade : TEXCOORD4;
	float LightDirection : TEXCOORD3;
	float4 ViewPos : TEXCOORD5;	
	float4 Diffuse : COLOR0;	
};

//-----------------------------------------------------------------------------
//-- VertexShader
//-----------------------------------------------------------------------------
PSInput VertexShaderSB(VSInput VS)
{
	PSInput PS = (PSInput)0;
	
	// Make sure normal is valid
	MTAFixUpNormal( VS.Normal.xyz);	
	// The usual stuff
	PS.Position = mul(VS.Position, gWorldViewProjection);
	PS.ViewPos = PS.Position;
	float4 worldPos = mul(VS.Position, gWorld); 	 
	
	//calculate light vector
	float3 WorldNormal = MTACalcWorldNormal( VS.Normal.xyz );
	float3 h = (sLightPosition - worldPos.xyz);
	PS.LightDirection = saturate(dot(WorldNormal,h));	
	
	// compute the eye vector 
	float3 eyeVector = worldPos.xyz - sLightPosition; 
	// Let's normalize it a bit(the lower, the less)
	eyeVector = eyeVector/length(pow(eyeVector,gSelfShad));
	
	float cosX,sinX;
	float cosY,sinY;
	float cosZ,sinZ;

	sincos(gRotAngle.x * gTime,sinX,cosX);
	sincos(gRotAngle.y * gTime,sinY,cosY);
	sincos(gRotAngle.z * gTime,sinZ,cosZ);

	float3x3 rot = float3x3(
      	cosY * cosZ + sinX * sinY * sinZ, -cosX * sinZ,  sinX * cosY * sinZ - sinY * cosZ,
      	cosY * sinZ - sinX * sinY * cosZ,  cosX * cosZ, -sinY * sinZ - sinX * cosY * cosZ,
      	cosX * sinY,                       sinX,         cosX * cosY
	);
	
	PS.SpTexCoord.xzy = mul(rot, eyeVector);
   
	PS.TexCoord = VS.TexCoord;
	PS.Diffuse = MTACalcGTABuildingDiffuse( VS.Diffuse );
   
	float DistanceFromLight = MTACalcCameraDistance( sLightPosition, worldPos);
	float DistanceFromCamera = MTACalcCameraDistance( gCameraPosition, MTACalcWorldPosition(VS.Position));
	PS.DistFade = MTAUnlerp ( gLightFade[0], gLightFade[1], DistanceFromCamera );
	PS.LightFade = MTAUnlerp ( gLightFade[2], gLightFade[3], DistanceFromLight );
	
	return PS;
}

struct PSOutput
{
    float4 color : COLOR0;
    float depth : DEPTH;
};

//-----------------------------------------------------------------------------
//-- PixelShader
//-----------------------------------------------------------------------------
PSOutput PixelShaderSB(PSInput PS)
{
    PSOutput output = (PSOutput)0;
	if (!isStr)
	{
		output.color = 0;
		output.depth = calculateLayeredDepth(PS.ViewPos);
	}
	float4 outPut = texCUBE(cubeMapSampler, PS.SpTexCoord);
	float4 texel = tex2D(Sampler0, PS.TexCoord);
	
	if (isFakeBump) 
	{
		texel -= tex2D(Sampler0, PS.TexCoord.xy - rc.xy)*1.5;
		texel += tex2D(Sampler0, PS.TexCoord.xy + rc.xy)*1.5;
	}
	float texalpha = (texel.r+texel.g+texel.b)/3;
	if (isVeh==false) 
	{
		if (texel.a<0.9) {outPut.a*=texel.a/2;}
	}
	else
	{
		float3 base = (gMaterialAmbient.rgb/3)+0.25;
		texel.a *= saturate((base.r+base.g+base.b)/1.5);
		texalpha = 0.5;
	}	
	outPut.rgb*=texalpha;
	if (gSelfShad>0) outPut*=PS.LightDirection;
	outPut *= saturate(PS.LightFade);
	outPut *= saturate(PS.DistFade);
	output.color = outPut;
    output.depth = calculateLayeredDepth(PS.ViewPos);

	return output;
}

//-----------------------------------------------------------------------------
//-- Technique
//-----------------------------------------------------------------------------

technique disco_light_v2
{
    pass P0
    {
        //DepthBias = -0.0003;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        VertexShader = compile vs_2_0 VertexShaderSB();
        PixelShader = compile ps_2_0 PixelShaderSB();									
    }
}
