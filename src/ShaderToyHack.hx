package;

import openfl.display.GraphicsShader;

using StringTools;

/**
	Inherits all the standard openfl glsl nuts and bolts as defined in GraphicsShader
	injects shader toy mainImage in constructor
**/
class ShaderToyHack extends GraphicsShader {
	/**
		#pragma header injects from glFragmentHeader on GraphicsShader
	**/
	@:glFragmentSource("#pragma header
	
	// shadertoy uniforms
	uniform vec3 iResolution;
	uniform float iTime;
	uniform float iTimeDelta;
	uniform float iFrame;
	// uniform vec4 iMouse; todo !
	// uniform float iChannelTime[4]; todo !
	// uniform vec3 iChannelResolution[4]; ! todo
	// uniform sampler2D iChanneli; ! todo

	//!voidmainImage
	
	void main()
	{
		// set the color untouched (do nothing), 
		gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);

		// store coord so it can be altered (openfl_TextureCoordv is read only)
		vec2 coord = openfl_TextureCoordv;
		
		// flip y axis to match shader toy
		coord.y = 1.0 - coord.y;
		
		// convert to shader toy expected fragCoord
		vec2 fragCoord = (coord * openfl_TextureSize);
		
		// then process gl_FragColor with our copy of the shader toy mainImage function
		mainImage(gl_FragColor, fragCoord);
	}
	")
	
	public var void_mainImage:String;

	public function new(mainImageFunction:String = "") {
			var useDefaultFunction = mainImageFunction.length <= 0;

			if(useDefaultFunction){
				/** the default glsl function that shadertoy uses when you make a new one **/
				mainImageFunction = '
				void mainImage( out vec4 fragColor, in vec2 fragCoord )
				{
					// Normalized pixel coordinates (from 0 to 1)
					vec2 uv = fragCoord/iResolution.xy;
					
					// Time varying pixel color
					vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
					
					// Output to screen
					fragColor = vec4(col,1.0);
				}
				';
		}
		this.void_mainImage = mainImageFunction;

		// inject mainImage function
		glFragmentSource = glFragmentSource.replace("//!voidmainImage", void_mainImage);
		#if debug
		trace('glVertexSource\n$glFragmentSource');
		#end
		
		super();
		// init uniforms so they can be used
		// todo get iResolution from openfl stage
		iResolution.value = [800.0, 640.00, 0.0];
		iTime.value = [0.0];
		iTimeDelta.value = [0.0];
		iFrame.value = [0.0];
	}

	public function update(elapsed:Float) {
		iTime.value[0] += elapsed;
		iTimeDelta.value[0] = elapsed;
	}
}
