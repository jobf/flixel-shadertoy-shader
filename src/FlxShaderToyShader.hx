package;

import flixel.FlxG;
import flixel.input.mouse.FlxMouse;
import flixel.math.FlxPoint;
#if FLX_DRAW_QUADS
import openfl.display.GraphicsShader;

/**
	An alternate FlxGraphicsShader that enables easy use of Shadertoy glsl programs in haxe flixel
	original https://github.com/HaxeFlixel/flixel/blob/dev/flixel/graphics/tile/FlxGraphicsShader.hx
**/
class FlxShaderToyShader extends GraphicsShader
{
	/**
		copied from FlxGraphicsShader
	**/
	@:glVertexSource("
		#pragma header
		
		attribute float alpha;
		attribute vec4 colorMultiplier;
		attribute vec4 colorOffset;
		uniform bool hasColorTransform;
		
		void main(void)
		{
			#pragma body
			
			openfl_Alphav = openfl_Alpha * alpha;
			
			if (hasColorTransform)
			{
				openfl_ColorOffsetv = colorOffset / 255.0;
				openfl_ColorMultiplierv = colorMultiplier;
			}
		}")
	/**
		copied from FlxGraphicsShader with additional shader toy uniforms added
	**/
	@:glFragmentHeader("
		// flixel specific uniforms
		uniform bool hasTransform;
		uniform bool hasColorTransform;
   	
		// flixel specific texture2D
		vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
		{
			vec4 color = texture2D(bitmap, coord);
			if (!hasTransform)
			{
				return color;
			}

			if (color.a == 0.0)
			{
				return vec4(0.0, 0.0, 0.0, 0.0);
			}

			if (!hasColorTransform)
			{
				return color * openfl_Alphav;
			}

			color = vec4(color.rgb / color.a, color.a);

			mat4 colorMultiplier = mat4(0);
			colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
			colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
			colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
			colorMultiplier[3][3] = openfl_ColorMultiplierv.w;

			color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

			if (color.a > 0.0)
			{
				return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
			}
			return vec4(0.0, 0.0, 0.0, 0.0);
		}

		// shader toy uniforms
        uniform vec3 iResolution;
        uniform float iTime;
        uniform float iTimeDelta;
        uniform float iFrame;
        uniform vec4 iMouse;
        // uniform float iChannelTime[4]; todo !
        // uniform vec3 iChannelResolution[4]; ! todo
        // uniform sampler2D iChanneli; ! todo
	")
	/** 
		note that we only have #pragma header here so that the header section is injected properly
		the actual shader code is added when collateFragmentSource is called
	**/
	@:glFragmentSource("
		#pragma header

	")
	public function new(shaderToyFragment:String = "")
	{
		this.shaderToyFragment = shaderToyFragment.length > 0 ? shaderToyFragment : exampleShaderToyFragment;
		collateFragmentSource();
		super();
		// init uniforms so they can be used
		iResolution.value = [FlxG.camera.width, FlxG.camera.height, 0.0];
		iTime.value = [0.0];
		iTimeDelta.value = [0.0];
		iFrame.value = [0.0];
		mousePosition = FlxPoint.get();
		iMouse.value = [0.0, 0.0, 0.0, 0.0];
	}

	/** the default glsl function that shadertoy uses when you make a new one **/
	var exampleShaderToyFragment = '
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

	/** the main function that will convert openfl coordinate to shader toy compatible coord and calls the shader toy function **/
	var mainFragment = '
		void main()
		{
			// set the color untouched (do nothing), 
			gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

			// store coord so it can be altered (openfl_TextureCoordv is read only)
			vec2 coord = openfl_TextureCoordv;
			
			// flip y axis to match shader toy
			coord.y = 1.0 - coord.y;
			
			// convert to shader toy expected fragCoord
			vec2 fragCoord = (coord * openfl_TextureSize);
			
			// then process gl_FragColor with our copy of the shader toy mainImage function
			mainImage(gl_FragColor, fragCoord);
		}
	';

	public var shaderToyFragment(default, null):String;

	/** set up the glFragmentSource **/
	function collateFragmentSource():Void
	{
		var sb = new StringBuf();
		// collect the shader toy fragment
		sb.add(shaderToyFragment);
		// collect the main function that will call the shader toy fragment
		sb.add(mainFragment);
		// add collated glsl code to glFragmentSource so it runs
		glFragmentSource += sb.toString();
	}

	public function update(elapsed:Float, mouse:FlxMouse)
	{
		iTime.value[0] += elapsed;
		iTimeDelta.value[0] = elapsed;
		update_iMouse(mouse);
	}


	var mousePosition:FlxPoint;
	inline function update_iMouse(mouse:FlxMouse)
	{
		mouse.getPosition(mousePosition);
		// iMouse.xy is position of mouse
		iMouse.value[0] = mousePosition.x;
		iMouse.value[1] = mousePosition.y;

		// todo ! implement mouse click/release
		// // iMouse.zw is last clicked position 
		// iMouse.value[2] = -1.0;
		// iMouse.value[3] = -1.0;
		// if (mouse.justReleased)
		// {
		// 	iMouse.value[2] = mousePosition.x;
		// 	iMouse.value[3] = mousePosition.y;
		// }
	}
}
#end
