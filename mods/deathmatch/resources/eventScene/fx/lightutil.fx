// This snippet i have found in MTA:Eir shader folder
// This was most probably written by The_GTA

// Mod this value if flickering occurs.

float depthCalcBias = 1.00004;
float depthBias = -0.00008f;
float depthPlanularBias = 1.0f;
float depthDensityStabilize = 50;

float calculateLayeredDepth(float4 ViewPos)
{
    float depth = ViewPos.z / ViewPos.w;
    
    return depth * pow(depthCalcBias, depth - (0.25 + (1 - depth * (depth * depthPlanularBias)) * depthDensityStabilize)) + depthBias;
}