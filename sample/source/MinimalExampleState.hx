import flixel.FlxG;
import flixel.FlxState;
import openfl.filters.ShaderFilter;

class MinimalExampleState extends FlxState
{
	var shader:FlxShaderToyHack;

	override public function create()
	{
		super.create();
		
		// init FlxShaderToyHack with shadertoy compatible glsl function
		// the example here colors every pixel green
		shader = new FlxShaderToyHack('
		void mainImage( out vec4 fragColor, in vec2 fragCoord )
		{
			float green = 1.0;
			fragColor = vec4(0.0, green, 0.0, 1.0);
		}');

		// set the camera filter (also works on FlxSprite shader)
		FlxG.camera.setFilters([new ShaderFilter(shader)]);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// call update on the shader to keep time etc up to date
		shader.update(elapsed, FlxG.mouse);
	}
}
