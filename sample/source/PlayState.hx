package;

import openfl.display.FPS;
import flixel.FlxG;
import flixel.FlxState;
import openfl.filters.ShaderFilter;

class PlayState extends FlxState
{
	override public function create()
	{
		displayInfo();
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
		updateDisplayedInfo();
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
		() -> new TestNormalisedZeroToOne(),
		
		// some more fun ones
		() -> new Flame(),
		() -> new CineShaderLava(),
		() -> new JuliaSetRotationMatrix()

	];

	function displayInfo() {
		FlxG.addChildBelowMouse(new FPS(10, 10, 0xffffff));
		#if web
		var openFlContainer = js.Browser.document.getElementById("openfl-content");
		openFlContainer.style.float = "left";
		openFlContainer.style.marginRight = "15px";
		var infoContainer = js.Browser.document.createDivElement();
		infoContainer.style.display = "table";
		js.Browser.document.body.appendChild(infoContainer);
		var help = js.Browser.document.createParagraphElement();
		help.innerText = "left/right arrow keys change active shader";
		infoContainer.appendChild(help);
		var shaderText = js.Browser.document.createParagraphElement();
		shaderText.id = "shader-program";
		shaderText.style.fontFamily = "monospace";
		shaderText.style.overflowY = "auto";
		shaderText.style.position = "absolute";
		shaderText.style.height = "90%";
		infoContainer.appendChild(shaderText);
		#end
	}

	function updateDisplayedInfo() {
		#if web
		var shaderText = js.Browser.document.getElementById("shader-program");
		shaderText.innerText = shader.shaderToyFragment;
		#end
	}
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

class Flame extends FlxShaderToyShader
{
	// see https://www.shadertoy.com/view/MdX3zr
	public function new()
	{
		super('
		// Created by anatole duprat - XT95/2013
		// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

		float noise(vec3 p) //Thx to Las^Mercury
		{
			vec3 i = floor(p);
			vec4 a = dot(i, vec3(1., 57., 21.)) + vec4(0., 57., 21., 78.);
			vec3 f = cos((p-i)*acos(-1.))*(-.5)+.5;
			a = mix(sin(cos(a)*a),sin(cos(1.+a)*(1.+a)), f.x);
			a.xy = mix(a.xz, a.yw, f.y);
			return mix(a.x, a.y, f.z);
		}

		float sphere(vec3 p, vec4 spr)
		{
			return length(spr.xyz-p) - spr.w;
		}

		float flame(vec3 p)
		{
			float d = sphere(p*vec3(1.,.5,1.), vec4(.0,-1.,.0,1.));
			return d + (noise(p+vec3(.0,iTime*2.,.0)) + noise(p*3.)*.5)*.25*(p.y) ;
		}

		float scene(vec3 p)
		{
			return min(100.-length(p) , abs(flame(p)) );
		}

		vec4 raymarch(vec3 org, vec3 dir)
		{
			float d = 0.0, glow = 0.0, eps = 0.02;
			vec3  p = org;
			bool glowed = false;
			
			for(int i=0; i<64; i++)
			{
				d = scene(p) + eps;
				p += d * dir;
				if( d>eps )
				{
					if(flame(p) < .0)
						glowed=true;
					if(glowed)
						glow = float(i)/64.;
				}
			}
			return vec4(p,glow);
		}

		void mainImage( out vec4 fragColor, in vec2 fragCoord )
		{
			vec2 v = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
			v.x *= iResolution.x/iResolution.y;
			
			vec3 org = vec3(0., -2., 4.);
			vec3 dir = normalize(vec3(v.x*1.6, -v.y, -1.5));
			
			vec4 p = raymarch(org, dir);
			float glow = p.w;
			
			vec4 col = mix(vec4(1.,.5,.1,1.), vec4(0.1,.5,1.,1.), p.y*.02+.4);
			
			fragColor = mix(vec4(0.), col, pow(glow*2.,4.));
			//fragColor = mix(vec4(1.), mix(vec4(1.,.5,.1,1.),vec4(0.1,.5,1.,1.),p.y*.02+.4), pow(glow*2.,4.));

		}
		');
	}
}

class CineShaderLava extends FlxShaderToyShader
{
	// see https://www.shadertoy.com/view/3sySRK
	public function new()
	{
		super('
		float opSmoothUnion( float d1, float d2, float k )
		{
			float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
			return mix( d2, d1, h ) - k*h*(1.0-h);
		}
		
		float sdSphere( vec3 p, float s )
		{
		  return length(p)-s;
		} 
		
		float map(vec3 p)
		{
			float d = 2.0;
			for (int i = 0; i < 16; i++) {
				float fi = float(i);
				float time = iTime * (fract(fi * 412.531 + 0.513) - 0.5) * 2.0;
				d = opSmoothUnion(
					sdSphere(p + sin(time + fi * vec3(52.5126, 64.62744, 632.25)) * vec3(2.0, 2.0, 0.8), mix(0.5, 1.0, fract(fi * 412.531 + 0.5124))),
					d,
					0.4
				);
			}
			return d;
		}
		
		vec3 calcNormal( in vec3 p )
		{
			const float h = 1e-5; // or some other value
			const vec2 k = vec2(1,-1);
			return normalize( k.xyy*map( p + k.xyy*h ) + 
							  k.yyx*map( p + k.yyx*h ) + 
							  k.yxy*map( p + k.yxy*h ) + 
							  k.xxx*map( p + k.xxx*h ) );
		}
		
		void mainImage( out vec4 fragColor, in vec2 fragCoord )
		{
			vec2 uv = fragCoord/iResolution.xy;
			
			// screen size is 6m x 6m
			vec3 rayOri = vec3((uv - 0.5) * vec2(iResolution.x/iResolution.y, 1.0) * 6.0, 3.0);
			vec3 rayDir = vec3(0.0, 0.0, -1.0);
			
			float depth = 0.0;
			vec3 p;
			
			for(int i = 0; i < 64; i++) {
				p = rayOri + rayDir * depth;
				float dist = map(p);
				depth += dist;
				if (dist < 1e-6) {
					break;
				}
			}
			
			depth = min(6.0, depth);
			vec3 n = calcNormal(p);
			float b = max(0.0, dot(n, vec3(0.577)));
			vec3 col = (0.5 + 0.5 * cos((b + iTime * 3.0) + uv.xyx * 2.0 + vec3(0,2,4))) * (0.85 + b * 0.35);
			col *= exp( -depth * 0.15 );
			
			// maximum thickness is 2m in alpha channel
			fragColor = vec4(col, 1.0 - (depth - 0.5) / 2.0);
		}
		
		/** SHADERDATA
		{
			"title": "My Shader 0",
			"description": "Lorem ipsum dolor",
			"model": "person"
		}
		*/
		');
	}
}

class JuliaSetRotationMatrix extends FlxShaderToyShader
{
	// see https://www.shadertoy.com/view/fsBGRG
	public function new()
	{
		super('
		#define ITR 100
		#define PI 3.1415926
		
		mat2 rot(float a){
			float c=cos(a);
			float s=sin(a);
			return mat2(c,-s,s,c);
		}
		
		vec2 pmod(vec2 p,float n){
			float np=PI*2.0/n;
			float r=atan(p.x,p.y)-0.5*np;
			r=mod(r,np)-0.5*np;
			return length(p)*vec2(cos(r),sin(r));
		}
		
		float julia(vec2 uv){
			int j;
			for(int i=0;i<ITR;i++){
				j++;
				vec2 c=vec2(-0.345,0.654);
				vec2 d=vec2(iTime*0.005,0.0);
				uv=vec2(uv.x*uv.x-uv.y*uv.y,2.0*uv.x*uv.y)+c+d;
				if(length(uv)>float(ITR)){
					break;
				}
			}
			return float(j)/float(ITR);
		}
		
		void mainImage(out vec4 fragColor,in vec2 fragCoord){
			vec2 uv=(2.0*fragCoord.xy-iResolution.xy)/iResolution.y;
		
			uv.xy*=rot(iTime*0.5);
			//uv=pmod(uv.xy,6.0);
			uv*=abs(sin(iTime*0.2));
			float f=julia(uv);
		
			fragColor=vec4(f-0.4,(f-(fract(iTime*0.1))),f,1.0);
		}
		');
	}
}