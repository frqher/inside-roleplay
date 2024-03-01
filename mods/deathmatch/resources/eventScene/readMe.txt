Resource name: Shader Disco Ball v0.58
Author: Ren_712
Video: http://www.youtube.com/watch?v=rAp0f9e9q0A
Contact: knoblauch700@o2.pl

changes in v0.58:
-Applied better solution for zFighting (when the effect flickers)

changes in v0.57:
-Rewritten/optimised most of the fx and lua code
-Changed the world effect blending mode to add

changes in v0.56:
-Changed the light position update method. Solves issues with light source shaking.

changes in v0.55:

-changed rotation matrix back to extrinsic.
-turning off the effect when object streamed out.
-turning off the effect when max distance is reached.
-fixed lightball flash when effect is started.

changes in v0.53:

-Created a cubemap texture with alpha channel. 
-Rewritten some of the shader code. (Red is finally proper
and there are no greyish parts anymore)
-Specular is created in pixel shader.
-Added 2 variables (fake bumps, light vector)
-changed rotation matrix from extrinsic to intrinsic.

changes in v0.52:

-Added a specular lighting effect to the ball object to make it look shiny.

This resource adds a rotating color ball to given world coordinates.
The effect projects a colorful light effect on nearby world, vehicle 
and ped textures. (Applying shader effect to peds has been enabled 
recently - to see the effect on peds update your nightly MTA client)

You can change the values like rotation speed,effect distance fade 
and other variables that determine the way the effect is rendered. 
You will find further explanation in the lua file.
The default coordinates are (-1436.51,-543.118,25.7417)

I'd suggest that anyone interested in using this resource on a server, 
applies the effect to entities rather than all textures. Also have in mind
that the map objects should not be rotated.

