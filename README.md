# Unity Rim Pseudo Volumetric Shader
A set of shaders for Unity which use the rim of a surface to suggest depth.

The rim is occluded using a texture or noise function to suggest that nothing was there prior. This package includes unlit, cutout, soft textured, textured shaders as examples for usage of this method. Because it uses the rim of a surface, the best behaving geometries are spherical or continuously round. This method is useful for rendering clouds, fur, or more general non-photorealistic effects. 

![anim1](http://imgur.com/slgumUO.gif)

Example textured materials on Unity primitive spheres.

Another implimentation with procedural noise for making clouds can be found here: https://github.com/thnewlands/rimvolume-clouds

Thomas Newlands - 2016
