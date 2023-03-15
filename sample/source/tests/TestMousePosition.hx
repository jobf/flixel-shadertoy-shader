package tests;

class TestMousePosition extends FlxShaderToyHack
{
	public function new()
	{
		super('
		// see #27 here - https://www.shadertoy.com/view/Md23DV
		// MOUSE INPUT
		//
		// ShaderToy gives the mouse cursor coordinates and button clicks
		// as an input via the iMouse vec4.
		//
		// The little disk will follow the cursor.
		// The x coordinate of the cursor changes the background color.
		// And if the cursor is inside the bigger disk, its color will change.
		
		float disk(vec2 r, vec2 center, float radius) {
			return 1.0 - smoothstep( radius-0.5, radius+0.5, length(r-center));
		}

		void mainImage( out vec4 fragColor, in vec2 fragCoord )
		{
			vec2 p = vec2(fragCoord.xy / iResolution.xy);
			vec2 r =  2.0*vec2(fragCoord.xy - 0.5*iResolution.xy)/iResolution.y;
			float xMax = iResolution.x/iResolution.y;
			
			// background color depends on the x coordinate of the cursor
			vec3 bgCol = vec3(iMouse.x / iResolution.x);
			vec3 col1 = vec3(0.216, 0.471, 0.698); // blue
			vec3 col2 = vec3(1.00, 0.329, 0.298); // yellow
			vec3 col3 = vec3(0.867, 0.910, 0.247); // red
			
			vec3 ret = bgCol;
			
			vec2 center;
			// draw the big yellow disk
			center = vec2(100., iResolution.y/2.);
			float radius = 60.;
			// if the cursor coordinates is inside the disk
			if( length(iMouse.xy-center)>radius ) {
				// use color3
				ret = mix(ret, col3, disk(fragCoord.xy, center, radius));
			}
			else {
				// else use color2
				ret = mix(ret, col2, disk(fragCoord.xy, center, radius));
			}	
			
			// draw the small blue disk at the cursor
			center = iMouse.xy;
			ret = mix(ret, col1, disk(fragCoord.xy, center, 20.));
			
			vec3 pixel = ret;
			fragColor = vec4(pixel, 1.0);
		}
		');
	}
}
