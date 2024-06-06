

// This shader is converted from 
// Heartfelt(https://www.shadertoy.com/view/ltffzl) - by Martijn Steinrucken aka BigWings - 2017
// countfrolic@gmail.com
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

Shader "Custom/Raindrop" {
	Properties {
		iChannel0("Albedo (RGB)", 2D) = "white" {}
		_MainTex("Texture", 2D) = "white" {}
		_Layer4BaseColor("Layer 4 Base Color", Color) = (0.75, 0.65, 0.55, 1) // Warm beige, adjust as needed
		_Layer4HighlightColor("Layer 4 Highlight Color", Color) = (0.95, 0.85, 0.75, 1) // Light warm beige, adjust as needed
	}
	
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Pass{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma target 5.0

			#include "UnityCG.cginc"

			sampler2D iChannel0;
			sampler2D _MainTex;
			float4 _Layer4BaseColor;
			float4 _Layer4HighlightColor;
			

			#define S(a, b, t) smoothstep(a, b, t)
			// #define CHEAP_NORMALS
			#define HAS_HEART
			#define USE_POST_PROCESSING

			float3 N13(float p) {
				//  from DAVE HOSKINS
				float3 p3 = frac(float3(p, p, p) * float3(.1031, .11369, .13787));
				p3 += dot(p3, p3.yzx + 19.19);
				return frac(float3((p3.x + p3.y)*p3.z, (p3.x + p3.z)*p3.y, (p3.y + p3.z)*p3.x));
			}

			float4 N14(float t) {
				return frac(sin(t*float4(123., 1024., 1456., 264.))*float4(6547., 345., 8799., 1564.));
			}
			float N(float t) {
				return frac(sin(t*12345.564)*7658.76);
			}

			float Saw(float b, float t) {
				return S(0., b, t)*S(1., b, t);
			}

			float2 DropLayer2(float2 uv, float t) {
				float2 UV = uv;

				uv.y += t*0.75;
				float2 a = float2(6., 1.);
				float2 grid = a*2.;
				float2 id = floor(uv*grid);

				float colShift = N(id.x);
				uv.y += colShift;

				id = floor(uv*grid);
				float3 n = N13(id.x*35.2 + id.y*2376.1);
				float2 st = frac(uv*grid) - float2(.5, 0);

				float x = n.x - .5;
				
				float y = UV.y*20.;
				float wiggle = sin(y + sin(y));
				x += wiggle*(.5 - abs(x))*(n.z - .5);
				x *= .7;
				float ti = frac(t + n.z);
				y = (Saw(.85, ti) - .5)*.9 + .5;
				float2 p = float2(x, y);

				float d = length((st - p)*a.yx);

				float mainDrop = S(.4, .0, d);

				float r = sqrt(S(1., y, st.y));
				float cd = abs(st.x - x);
				float trail = S(.23*r, .15*r*r, cd);
				float trailFront = S(-.02, .02, st.y - y);
				trail *= trailFront*r*r;

				y = UV.y;
				float trail2 = S(.2*r, .0, cd);
				float droplets = max(0., (sin(y*(1. - y)*120.) - st.y))*trail2*trailFront*n.z;
				y = frac(y*10.) + (st.y - .5);
				float dd = length(st - float2(x, y));
				droplets = S(.3, 0., dd);
				float m = mainDrop + droplets*r*trailFront;

				float3 dropletColor = float3(1, 0, 0);

				//m += st.x>a.y*.45 || st.y>a.x*.165 ? 1.2 : 0.;
				return float2(m, trail);
			}

			float4 DropLayer4(float2 uv, float t) {
				float2 grid = float2(6., 1.);  // Define the grid size for droplet calculation
				float2 id = floor(uv * grid);  // Determine the grid cell id
				uv.y += t * 0.75 + N(id.x);    // Simulate motion in the droplet field
			
				float3 n = N13(id.x * 35.2 + id.y * 2376.1);  // Get a pseudo-random number based on position
				float2 st = frac(uv * grid) - float2(0.5, 0);  // Get the fractional part of the UV for local droplet position
				float2 p = float2(n.x - 0.5, frac(t + n.z) - 0.5) * 0.9 + 0.5;  // Position of the droplet within the grid cell
			
				float d = length(st - p);  // Distance from center of the droplet, used to calculate visibility
				float visibility = S(0.4, 0.0, d);  // Smoothstep to soften edges of droplets
				float beigeInfluence = S(0.0, 1.0, 1-d);  // Calculate how much beige color is influenced by the droplet 'stickiness'
			
				// Defining colors
				float3 baseColor = float3(0.75, 0.65, 0.55);  // Soft beige base color
				float3 highlightColor = float3(0.95, 0.85, 0.75);  // Lighter beige for highlighted parts
			
				// Compute the droplet color by blending between base and highlight colors
				float3 dropletColor = lerp(baseColor, highlightColor, beigeInfluence);
			
				// The function now returns a float4 containing the RGBA color of the droplet
				// `visibility` affects the alpha component, controlling the transparency of the droplet
				return float4(dropletColor * visibility, visibility);
			}
			
						
						

			float StaticDrops(float2 uv, float t) {
				uv *= 40.;

				float2 id = floor(uv);
				uv = frac(uv) - .5;
				float3 n = N13(id.x*107.45 + id.y*3543.654);
				float2 p = (n.xy - .5)*.7;
				float d = length(uv - p);

				float fade = Saw(.015, frac(t + n.z));
				float c = S(.3, 0., d)*frac(n.z*10.);
				return c;
			}

			// float2 Drops(float2 uv, float t, float l0, float l1, float l2) {
			// 	float s = StaticDrops(uv, t)*l0;
			// 	float2 m1 = DropLayer2(uv*0.5, t)*l1;
			// 	// float2 m2 = DropLayer2(uv*1.85, t)*l2;
			// 	float2 m2 = DropLayer2(uv*1.15, t)*l2;
			// 	float2 m3 = DropLayer4(uv, t);

			// 	float c = s + m1.x + m2.x + m3.x;
			// 	c = S(.3, 1., c);

			// 	return float2(c, max(m1.y*l0, m2.y*l1));
			// }

			// float2 Drops(float2 uv, float t, float l0, float l1, float l2) {
			// 	float s = StaticDrops(uv, t) * l0;
			// 	float2 m1 = DropLayer2(uv * 0.5, t) * l1;
			// 	float2 m2 = DropLayer2(uv * 1.15, t) * l2;
			// 	float2 m3 = DropLayer4(uv, t);  // Assume DropLayer4 also returns a float2
			
			// 	float visibility = s + m1.x + m2.x + m3.x;
			// 	visibility = S(0.3, 1., visibility);
			
			// 	// Assume m3.y represents the stickiness factor, which influences color in the frag function
			// 	float stickiness = max(m1.y, max(m2.y, m3.y));
			
			// 	return float2(visibility, stickiness);
			// }

			// float4 Drops(float2 uv, float t, float l0, float l1, float l2) {
			// 	float s = StaticDrops(uv, t) * l0;
			// 	float2 m1 = DropLayer2(uv * 0.5, t) * l1;
			// 	float2 m2 = DropLayer2(uv * 1.15, t) * l2;
			// 	float3 m3 = DropLayer4(uv, t);  // Updated to return float3
			
			// 	float totalVisibility = s + m1.x + m2.x + m3.x;
			// 	totalVisibility = S(0.3, 1.0, totalVisibility);
			
			// 	float beigeInfluence = m3.y;  // Use the second component for beige influence
			
			// 	return float4(totalVisibility, beigeInfluence, 0, 1);  // Return visibility, beige influence, unused, and full opacity
			// }

			float4 Drops(float2 uv, float t, float l0, float l1, float l2) {
				float s = StaticDrops(uv, t) * l0;
				float2 m1 = DropLayer2(uv * 0.5, t) * l1;
				float2 m2 = DropLayer2(uv * 1.15, t) * l2;
				// float4 m3 = DropLayer4(uv, t);  // Ensure this is a float4 as mentioned
			
				float2 totalVisibility = s + m1.x + m2.x;  // Use alpha from m3 for visibility
				totalVisibility = S(0.3, 1.0, totalVisibility);
			
				// Compute a combined color weighted by the visibility contributions of each layer
				// Assuming m1 and m2 return colors or you can set default colors for them
				float4 beigeColor = float4(0.76, 0.7, 0.5, 0.5);  // Dirty beige with 50% transparency
				// float2 baseColor2 = float4(0.76, 0.7, 0.5, 0.5);
				// float2 combinedColor = (baseColor1) / totalVisibility;
				beigeColor.x *= totalVisibility;

				return beigeColor;
			}
			


			fixed4 frag(v2f_img i) : SV_Target{

				float2 uv = ((i.uv * _ScreenParams.xy) - .5*_ScreenParams.xy) / _ScreenParams.y;
				float2 noiseCoord = uv * 5.0; // Scale for noise texture
				float4 texColor = tex2D(_MainTex, uv); // Properly sample texture

				// Implement a fallback color in case the texture is missing or invalid
				float3 fallbackColor = float3(0.5, 0.5, 0.5); // Neutral grey
				float3 textureColor = texColor.rgb; // Use RGB channels


				// Use the sampled color or a fallback if the texture sample is too uniform or invalid
				// float3 color = lerp(fallbackColor, textureColor, step(0.1, length(texColor.rgb - 0.5)));


				float2 UV = i.uv.xy;
				//float3 M = iMouse.xyz / iResolution.xyz;
				// for now
				float3 M = float3(0.0, 0.0, 0.0);
				// float T = _Time.y + M.x*200.;
				float T = _Time.y;


				float t = T*.9;

				//float rainAmount = iMouse.z>0. ? M.y : sin(T*.05)*.3 + .7;
				// fixed rain amount
				float rainAmount = M.y;

				float maxBlur = lerp(3., 6., rainAmount);
				float minBlur = 2.;

				float story = 0.;
				float heart = 0.;

				#ifdef HAS_HEART
				story = S(0., 70., T);

				t = min(1., T / 70.);						// remap drop time so it goes slower when it freezes
				t = 1. - t;
				t = (1. - t*t)*70.;

				float2 hv = uv - float2(.0, -.1);				// build heart
				hv.x *= .5;

				heart = length(hv);
				heart = S(.4, .2, heart);
				rainAmount = heart;						// the rain is where the heart is

				t *= .015;
				#else

				
				#endif
				float rainAmountTimesFour = rainAmount*4;
				float staticDrops = S(-.5, 1., rainAmount)*2.;
				float layer1 = S(.25, .75, rainAmountTimesFour);
				float layer2 = S(.0, .5, rainAmountTimesFour);


				// float2 c = Drops(uv, t, staticDrops, layer1, layer2);
				float2 c = Drops(uv, t, staticDrops, layer1, layer2);

				#ifdef CHEAP_NORMALS
				float2 n = float2(dFdx(c.x), dFdy(c.x));// cheap normals (3x cheaper, but 2 times shittier ;))
				#else
				float2 e = float2(.001, 0.);
				float cx = Drops(uv + e, t, staticDrops, layer1, layer2).x;
				float cy = Drops(uv + e.yx, t, staticDrops, layer1, layer2).x;
				float2 n = float2(cx - c.x, cy - c.x);		// expensive normals
				#endif

				// Existing layers
				float2 dropData = Drops(uv, _Time.y*0.001, 1.0, 1.0, 1.0);
				float dropVisibility = dropData.x;
				float combinedColor = dropData.y;

				// Defining beige color
				

				float focus = lerp(maxBlur - c.y, minBlur, S(.1, .2, c.x));
				float4 texCoord = float4(UV.x + n.x, UV.y + n.y, 0, focus);
				float4 lod = tex2Dlod(iChannel0, texCoord);

				// float3 col = lod.rgb;
				// Blending sampled color with beige color based on the influence factor

				// float beigeInfluence = 0.5; // Start with a subtle influence
				
			
				float3 beigeColor = float3(0.95, 0.85, 0.75);  // A more saturated beige

				// beigeInfluence = smoothstep(0.6, 1.0, beigeColor);
				float3 col = lerp(lod.rgb, beigeColor, dropVisibility);

				#ifdef USE_POST_PROCESSING
				t = (T + 3.)*.5;										// make time sync with first lightnoing
				float colFade = sin(t*.2)*.5 + .5 + story;
				col *= lerp(float3(1., 1., 1.), float3(.8, .9, 1.3), colFade);	// subtle color shift
				col *= 1. - dot(UV -= .5, UV);							// vignette
				#endif
																	
				return fixed4(col, 1);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}