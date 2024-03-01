texture Grunge;

technique setgrunge
{
	pass P0
	{
		// DepthBias = 0.0001;
		Texture[0] = Grunge;
	}
}