# FlxShaderToyHack

This allows use of glsl code from shadertoy in haxe flixel without needing to port it.

It's a hack, probably don't use this in your production code.

Demo here https://jobf.github.io/flixel-shadertoy-shader/

## How it works 

Introduce the missing shadertoy uniforms to glFragmentSource.

Inject the shadertoy function before main function in the glFragmentSource.

Sync shadertoy uniforms with openfl uniforms in main function;

Call shadertoy function from main function to set gl_FragColor;

Update some uniforms each game loop update.

### Caveats

There's a neglible performance cost due to the extra uniforms and processing. Probably not enough to worry about.

However I encourage you to properly port shadertoy code using the openfl uniforms to a class which extends FlxShader. This will lets you define custom extra uniforms too!

## Install

```shell
haxelib git flixel-shadertoy-shader https://github.com/jobf/flixel-shadertoy-shader/
```
## Use

Reference in project.xml

```xml
<haxelib name="flixel-shadertoy-shader" />
```

### Examples

Check the `sample` directory in this repo for a flixel project using this.

A minimal example is shown below with minimum requirements to run a FlxShaderToyHack.

```hx
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
```