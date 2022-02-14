package;

import flixel.FlxG;
import flixel.FlxState;
import openfl.filters.ShaderFilter;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();
		setCameraShader();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// IMPORTANT !!! call update on the shader
		shader.update(elapsed, FlxG.mouse);
		
		// change active shader to previous/next with left/right arrow keys
		if(FlxG.keys.justPressed.LEFT)
		{
			shaderIndex--;
			if(shaderIndex < 0)
				shaderIndex = shaders.length - 1;
			setCameraShader();
		}
		
		if(FlxG.keys.justPressed.RIGHT)
		{
			shaderIndex++;
			if(shaderIndex > shaders.length -1)
				shaderIndex = 0;
			setCameraShader();
		}
	}

	var shaderIndex:Int = 0;
	var shader:FlxShaderToyShader;
	function setCameraShader()
	{
		shader = shaders[shaderIndex]();
		FlxG.camera.setFilters([new ShaderFilter(shader)]);
	}

	/** 
		Collection of functions so we can easily change to different examples.
		Each funtion returns a new instance of FlxShaderToyShader.
	**/
	var shaders:Array<Void -> FlxShaderToyShader> = [
		// no shader passed in, loads default mainImage function as seen here - https://www.shadertoy.com/new
		() -> new FlxShaderToyShader(),

		// mainImage function passed in
		() -> new FlxShaderToyShader('
		void mainImage( out vec4 fragColor, in vec2 fragCoord )
		{
			float green = 1.0;
			fragColor = vec4(0.0, green, 0.0, 1.0);
		}
		'),

		// mainImage function in a class
		() -> new TestNormalisedZeroToOne()			
	];
}

class TestNormalisedZeroToOne extends FlxShaderToyShader
{
	// testing fragCoord and iResolution are correctly translated
	// should look same as first image in this post - https://stackoverflow.com/a/58691860
	public function new()
	{
		super('
		void mainImage( out vec4 fragColor, in vec2 fragCoord )
		{
			// Normalized pixel coordinates (from 0 to 1)
			vec2 uv = fragCoord/iResolution.xy;

			vec3 col = vec3(uv.x, uv.y, 0.0);

			fragColor = vec4(col, 1.0);
		}
		');
	}
}