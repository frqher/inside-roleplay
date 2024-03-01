texture gTexture;

sampler Sampler0 = sampler_state
{
    Texture = (gTexture);
};

struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
  float3 WorldNormal : TEXCOORD1;
  float3 WorldPos : TEXCOORD2;
};

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float4 texel = tex2D(Sampler0, PS.TexCoord);
    float4 finalColor = texel * PS.Diffuse;

    finalColor.rgb += texel.rgb * 0.4;

    return finalColor;
}

technique shine
{
    pass P0
    {
        Texture[0] = gTexture;
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}