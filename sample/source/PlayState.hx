package;

import flixel.FlxG;
import flixel.FlxState;
import openfl.filters.ShaderFilter;

class PlayState extends FlxState
{
	var shader:FlxShaderToyShader;

	override public function create()
	{
		super.create();
		shader = new FlxShaderToyShader();
		setCameraShader();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		shader.update(elapsed, FlxG.mouse);
	}

	function setCameraShader()
	{
		FlxG.camera.setFilters([new ShaderFilter(shader)]);
	}
}
