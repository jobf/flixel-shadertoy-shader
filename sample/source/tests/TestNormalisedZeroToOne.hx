package tests;

class TestNormalisedZeroToOne extends FlxShaderToyHack
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