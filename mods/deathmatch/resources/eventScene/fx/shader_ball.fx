// shader_ball.fx
//
// Author: Ren712/AngerMAN

texture gBallTexture;
float3 gRotAngle = (0,0,0);
float sSpecularPower = 5;
float sBallSize = 6;

#define GENERATE_NORMALS 
#include "mta-helper.fx"

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
    float3 Normal : NORMAL0;
    float3 TexCoord : TEXCOORD0;
};

//---------------------------------------------------------------------
//-- Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------

struct PSInput
{
    float4 Position : POSITION;
    float2 TexCoord : TEXCOORD0;	
    float3 SpTexCoord : TEXCOORD1;
    float4 worldPos : TEXCOORD2; 
    float3 Normal : TEXCOORD3;
};

//-----------------------------------------------------------------------------
//-- VertexShader
//-----------------------------------------------------------------------------
PSInput VertexShaderSB(VSInput VS)
{
    PSInput PS = (PSInput)0;
    MTAFixUpNormal( VS.Normal.xyz);
    VS.Position.xyz *= sBallSize;
    float3 posNor = normalize(VS.Position.xyz);
    PS.Position = mul(VS.Position, gWorldViewProjection);
	
	PS.Normal=VS.Normal;
	PS.worldPos = mul(VS.Position, gWorld);	 
	
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

   PS.SpTexCoord.xzy = mul(rot, posNor);
 
   PS.TexCoord = VS.TexCoord;
   return PS;
}
 
//-----------------------------------------------------------------------------
//-- PixelShader
//-----------------------------------------------------------------------------
float4 PixelShaderSB(PSInput PS) : COLOR0
{
    float4 cubeBoxTex = texCUBE(cubeMapSampler, PS.SpTexCoord);
	cubeBoxTex.rgb*=cubeBoxTex.a;
	float4 outPut=float4(cubeBoxTex.rgb/6,1);
	
	// Specular
	float3 WorldNormal = MTACalcWorldNormal( PS.Normal ); 
	float3 h = normalize(normalize(gCameraPosition - PS.worldPos.xyz) - normalize(gCameraDirection));
	float SpecLighting = saturate(pow(saturate(dot(WorldNormal,h)), sSpecularPower));
	
	outPut.rgb+=(cubeBoxTex.rgb)*SpecLighting;
    return outPut;
}

////////////////////////////////////////////////////////////
//////////////////////////////// TECHNIQUES ////////////////
////////////////////////////////////////////////////////////

technique animated_ball
{
    pass P0
    {
        AlphaBlendEnable = TRUE;
        VertexShader = compile vs_2_0 VertexShaderSB();
        PixelShader = compile ps_2_0 PixelShaderSB();
    }
}
