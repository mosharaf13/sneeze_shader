// // This shader is converted from 
// // Heartfelt(https://www.shadertoy.com/view/ltffzl) - by Martijn Steinrucken aka BigWings - 2017
// // countfrolic@gmail.com
// // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Shader "Custom/Raindrop" {
// 	Properties {
// 		iChannel0("Albedo (RGB)", 2D) = "gray" {}
// 	}
// 	SubShader {
// 		Tags { "RenderType"="Opaque" }
// 		LOD 200
// 		Pass{
// 			CGPROGRAM
// 			#pragma vertex vert_img
// 			#pragma fragment frag

// 			#include "UnityCG.cginc"

// 			sampler2D iChannel0;

// 			#define S(a, b, t) smoothstep(a, b, t)
// 			//#define CHEAP_NORMALS
// // 			#define HAS_HEART
// 			#define USE_POST_PROCESSING

// 			float3 N13(float p) {
// 				//  from DAVE HOSKINS
// 				float3 p3 = frac(float3(p, p, p) * float3(.1031, .11369, .13787));
// 				p3 += dot(p3, p3.yzx + 19.19);
// 				return frac(float3((p3.x + p3.y)*p3.z, (p3.x + p3.z)*p3.y, (p3.y + p3.z)*p3.x));
// 			}

// 			float4 N14(float t) {
// 				return frac(sin(t*float4(123., 1024., 1456., 264.))*float4(6547., 345., 8799., 1564.));
// 			}

// 			float N(float t) {
// 				return frac(sin(t*12345.564)*7658.76);
// 			}

// 			float Saw(float b, float t) {
// 				return S(0., b, t)*S(1., b, t);
// 			}

// 			float2 DropLayer2(float2 uv, float t) {

// 			    float2 center = float2(0.5, 0.5);
//                 float2 grid2 = float2(6., 1.);
//                 float2 id2 = floor(uv * grid2);

// 				float2 UV = uv;

// 				// To prevent upward movement and encourage slight downward drift:
//                 uv.y +=  0; // Change '+' to '-' to ensure downward movement and reduce the coefficient to slow the movement

// 				float2 a = float2(6., 1.);
// 				float2 grid = a*1.5;
// 				float2 id = floor(uv*grid);

// 				float colShift = N(id.x);
// 				uv.y += 0;

// 				id = floor(uv*grid);
// 				float3 n = N13(id.x*35.2 + id.y*2376.1);

// 				float distance = length(uv - center);  // Add this line
//                 float angle = atan2(center.y - uv.y, center.x - uv.x);  // Add this line
//                 float influence = max(0.0, 1.0 - distance * 2.5);  // Add this line

// 				float2 st = frac(uv*grid) - float2(.5, 0);

//                 float x = n.x - .5 + 0.1 * cos(angle) * influence;  // Modify this line
//                 float y = UV.y * 20. + 0.1 * sin(angle) * influence;  // Modify this line


//                 float wiggle = 0; // Reduce the amplitude of wiggle to minimize horizontal movement
//                 x += wiggle; // Adjust wiggle influence to keep droplets more static

//                 x *= .3; // Reduce horizontal spread to make droplets appear smaller

// 				float ti = frac(t + n.z);
// 				y = (Saw(.85, ti) - .5)*.9 + .5;
// 				float2 p = float2(x, y);

//                 float d = length((st - p)*a.yx*float2(1.0, 0.8)); // Make vertical shape slightly elongated

// 				float mainDrop = S(.4, .0, d);

// 				float r = sqrt(S(1., y, st.y));
// 				float cd = abs(st.x - x);
// 				float trail = 0;
// 				float trailFront = 0;
// 				trail *= trailFront*r*r;

// 				y = UV.y;
// 				float trail2 = S(.2*r, .0, cd);
// 				float droplets = max(0., (sin(y*(1. - y)*120.) - st.y))*trail2*trailFront*n.z;
// 				y = frac(y*10.) + (st.y - .5);
// 				float dd = length(st - float2(x, y));
// 				droplets = S(.3, 0., dd);
// 				float m = mainDrop;

// 				//m += st.x>a.y*.45 || st.y>a.x*.165 ? 1.2 : 0.;
// 				return float2(m, trail);
// 			}

//             float3 DropLayer3(float2 uv, float t) {
//                 // Adjust grid to make droplets larger and ensure they are visible
//                 float2 grid = float2(1.0, 0.5); // Larger grid cells for fewer, larger droplets
//                 float2 id = floor(uv * grid);

//                 // Apply a strong noise function for random droplet positioning
//                 float3 noise = N13(id.x * 57.2 + id.y * 78.1);

//                 // Calculate droplet position within the grid
//                 float2 st = frac(uv * grid) - float2(0.5, 0.5) + 0.15 * noise.yz;

//                 // Define droplet shape
//                 float d = length(st - float2(noise.x - 0.5, 0.5));

//                 // Use a smooth step to create soft edges for the droplets
//                 float visibility = smoothstep(0.3, 0.1, d); // Soft edges

//                 // Set a base color for the mucus, incorporating a bit of red
//                 float3 baseColor = float3(0.761, 0.792, 0.757); // Mucus color
//                 float3 bloodColor = float3(0.8, 0.1, 0.1); // Blood color

//                 // Mix mucus and blood colors based on noise
//                 float3 color = lerp(baseColor, bloodColor, noise.x * 0.3); // Slight mix with blood

//                 // Return the color modulated by visibility
//                 return color * visibility;
//             }   



// 			float StaticDrops(float2 uv, float t) {
// 				uv *= 40.;

// 				float2 id = floor(uv);
// 				uv = frac(uv) - .5;
// 				float3 n = N13(id.x*107.45 + id.y*3543.654);
// 				float2 p = (n.xy - .5)*.7;
// 				float d = length(uv - p);

// 				float fade = 1.0;
// 				float c = S(.3, 0., d)*frac(n.z*10.)*fade;
// 				return c;
// 			}

//             float2 Drops(float2 uv, float t, float l0, float l1, float l2, float l3) {
//                 float s = StaticDrops(uv, t) * l0; // Static droplet layer
//                 float2 m1 = DropLayer2(uv, t) * l1; // Dynamic droplet layer 1
//                 float2 m2 = DropLayer2(uv * 1.85, t) * l2; // Scaled dynamic droplet layer 2
//                 float3 m3 = DropLayer3(uv , t) * l3; // Mucus-like dynamic droplet layer 3, assuming m3 is a float3

//                 float c = s + m1.x + m2.x; // Add m3.x assuming it holds a similar droplet effect value
//                 c = S(0.3, 1.0, c); // Smoothing function to blend all contributions

// //                 float additionalEffect = max(max(m1.y * l0, m2.y * l1), m3.y * l3); // Incorporate m3.y if it represents an additional droplet effect, such as glossiness or stickiness
//                 float additionalEffect = max(m1.y * l0, m2.y * l1); // Incorporate m3.y if it represents an additional droplet effect, such as glossiness or stickiness

//                 return float2(c, additionalEffect); // Combine color and effect intensities
//             }


// 			float mucus(float2 uv) {
// 			    // color = #C2CAC1
//                 // Generate stretched noise for mucus trails
//                 float2 smearedUV = uv * float2(1.0, 10.0); // Stretched in the vertical direction
//                 float mucusTrail = noise(smearedUV); // Your noise function here
//                 return smoothstep(0.4, 0.6, mucusTrail); // Threshold for mucus visibility
//             }


// 			fixed4 frag(v2f_img i) : SV_Target{

// 				float2 uv = ((i.uv * _ScreenParams.xy) - .5*_ScreenParams.xy) / _ScreenParams.y;

//                 float2 dropData = Drops(uv, _Time.y, 1.0, 1.0, 1.0, 1.0);
//                 float dropVisibility = dropData.x; // The visibility of droplets

//                 float mucusVisibility = mucus(uv);


//                 // Generate a noise value based on the UV coordinates to decide which droplets get the yellow tint
//                 float noise = frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
//                 float isYellow = step(0.5, noise); // 50% chance to be yellow

//                 // Define the yellow tint
//                 float3 yellowTint = float3(1.0, 1.0, 0.5); // A soft yellow
//                 float3 dropletColor = lerp(float3(0.9, 0.9, 0.9), yellowTint, isYellow * dropVisibility);

//                 float alpha = dropVisibility > 0.1 ? 1.0 : 0.0; // Make droplet visible or invisible



// 				float2 UV = i.uv.xy;


// 				//float3 M = iMouse.xyz / iResolution.xyz;
// 				// for now
// 				float3 M = float3(0.0, 0.0, 0.0);
// 				float T = _Time.y + M.x*2.;


// 				float t = 0;

// 				//float rainAmount = iMouse.z>0. ? M.y : sin(T*.05)*.3 + .7;
// 				// fixed rain amount
// 				float rainAmount = 1.0;

// 				float maxBlur = 5;
// 				float minBlur = 3;

// 				float story = 0.;
// 				float heart = 0.;


// 				float zoom = -cos(T*.2);
// 				uv *= 1;


// 				UV = (UV - .5)*(.9 + zoom*.1) + .5;

// 				float staticDrops = S(-.5, 1., rainAmount)*2.;
// 				float layer1 = S(.25, .75, rainAmount);
// 				float layer2 = S(.0, .5, rainAmount);
// 				float layer3 = S(.0, .2, rainAmount);


// 				float2 c = Drops(uv, 0, staticDrops, layer1, layer2, layer3);

// 				#ifdef CHEAP_NORMALS
// 				float2 n = float2(0,0);// cheap normals (3x cheaper, but 2 times shittier ;))
// 				#else
//                     float2 e = float2(.001, 0.);
//                     float cx = Drops(uv + e, t, staticDrops, layer1, layer2, layer3).x;
//                     float cy = Drops(uv + e.yx, t, staticDrops, layer1, layer2, layer3).x;
//                     float2 n = float2(cx - c.x, cy - c.x);		// expensive normals
// 				#endif


// 				float focus = maxBlur;
// 				// textureLod to tex2Dlod(ref: https://msdn.microsoft.com/en-us/library/windows/desktop/bb509680(v=vs.85).aspx)
// 				//float3 col = textureLod(iChannel0, UV + n, focus).rgb;
// 				float4 texCoord = float4(UV.x + n.x, UV.y + n.y, 0, focus);
// 				float4 lod = tex2Dlod(iChannel0, texCoord);
// 				float3 col = lod.rgb * float3(0.9, 0.9, 0.9);
// 				col *= float3(0.9, 0.9, 0.9); // Apply a slight uniform reduction in brightness for a more 'wet' look


// 				#ifdef USE_POST_PROCESSING
// 				t = (T + 3.)*.5;										// make time sync with first lightnoing
// 				float colFade = sin(t*.2)*.5 + .5 + story;
//                 col *= lerp(float3(1., 1., 1.), float3(0.8, 0.85, 0.9), colFade); // Shift towards gray/blue
// 				float fade = 1.0;							// fade in at the start
// 				col *= 1. - dot(UV -= .5, UV);							// vignette

// 				#endif

// 																	//col = vec3(heart);
// 				return fixed4(col, 1);
// 			}
// 			ENDCG
// 		}
// 	}
// 	FallBack "Diffuse"
// }


// This shader is converted from 
// Heartfelt(https://www.shadertoy.com/view/ltffzl) - by Martijn Steinrucken aka BigWings - 2017
// countfrolic@gmail.com
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

Shader "Custom/Raindrop" {
	Properties {
		iChannel0("Albedo (RGB)", 2D) = "white" {}
		_MainTex("Texture", 2D) = "white" {}
		_BaseColor("Base Color", Color) = (0.8, 0.7, 0.6, 1) // Beige color
		_HighlightColor("Highlight Color", Color) = (1, 0.9, 0.8, 1) // Light beige for highlights
	}
	
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Pass{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D iChannel0;
			sampler2D _MainTex;
			float4 _BaseColor;
			float4 _HighlightColor;


			#define S(a, b, t) smoothstep(a, b, t)
			//#define CHEAP_NORMALS
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

				//m += st.x>a.y*.45 || st.y>a.x*.165 ? 1.2 : 0.;
				return float2(m, trail);
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

			float2 Drops(float2 uv, float t, float l0, float l1, float l2) {
				float s = StaticDrops(uv, t)*l0;
				float2 m1 = DropLayer2(uv*0.5, t)*l1;
				// float2 m2 = DropLayer2(uv*1.85, t)*l2;
				float2 m2 = DropLayer2(uv*1.15, t)*l2;

				float c = s + m1.x + m2.x;
				c = S(.3, 1., c);

				return float2(c, max(m1.y*l0, m2.y*l1));
			}


			fixed4 frag(v2f_img i) : SV_Target{

				float2 uv = ((i.uv * _ScreenParams.xy) - .5*_ScreenParams.xy) / _ScreenParams.y;
				float2 noiseCoord = uv * 10.0; // Scale for noise texture
				float4 texColor = tex2D(_MainTex, uv); // Properly sample texture

				// Implement a fallback color in case the texture is missing or invalid
				float3 fallbackColor = float3(0.5, 0.5, 0.5); // Neutral grey
				float3 textureColor = texColor.rgb; // Use RGB channels


				// Use the sampled color or a fallback if the texture sample is too uniform or invalid
				float3 color = lerp(fallbackColor, textureColor, step(0.1, length(texColor.rgb - 0.5)));


				float2 UV = i.uv.xy;
				//float3 M = iMouse.xyz / iResolution.xyz;
				// for now
				float3 M = float3(0.0, 0.0, 0.0);
				// float T = _Time.y + M.x*200.;
				float T = _Time.y;

				#ifdef HAS_HEART
				// T = fmod(_Time.y, 102.);
				// T = lerp(T, M.x*102., M.z>0. ? 1. : 0.);
				#endif


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

				// float zoom = lerp(.3, 1.2, story);		// slowly zoom out
				// uv *= zoom;
				// minBlur = 4. + S(.5, 1., story)*3.;		// more opaque glass towards the end
				maxBlur = 6. + S(.5, 1., story)*1.5;

				float2 hv = uv - float2(.0, -.1);				// build heart
				hv.x *= .5;
				float s = S(110., 70., T);				// heart gets smaller and fades towards the end
				// hv.y -= sqrt(abs(hv.x))*.5*s;
				heart = length(hv);
				heart = S(.4*s, .2*s, heart)*s;
				rainAmount = heart;						// the rain is where the heart is

				// maxBlur -= heart;							// inside the heart slighly less foggy
				// uv *= 1.5;								// zoom out a bit more
				t *= .015;
				#else
				// float zoom = -cos(T*.2);
				// uv *= .7 + zoom*.3;
				
				#endif
				// UV = (UV - .5)*(.9 + zoom*.1) + .5;

				float staticDrops = S(-.5, 1., rainAmount)*2.;
				float layer1 = S(.25, .75, rainAmount*4);
				float layer2 = S(.0, .5, rainAmount*4);


				float2 c = Drops(uv, t, staticDrops, layer1, layer2);
				#ifdef CHEAP_NORMALS
				float2 n = float2(dFdx(c.x), dFdy(c.x));// cheap normals (3x cheaper, but 2 times shittier ;))
				#else
				float2 e = float2(.001, 0.);
				float cx = Drops(uv + e, t, staticDrops, layer1, layer2).x;
				float cy = Drops(uv + e.yx, t, staticDrops, layer1, layer2).x;
				float2 n = float2(cx - c.x, cy - c.x);		// expensive normals
				#endif


				#ifdef HAS_HEART
				// n *= 1. - S(60., 85., T);
				// c.y *= 1. - S(80., 100., T)*.8;
				#endif

				float focus = lerp(maxBlur - c.y, minBlur, S(.1, .2, c.x));
				// textureLod to tex2Dlod(ref: https://msdn.microsoft.com/en-us/library/windows/desktop/bb509680(v=vs.85).aspx)
				//float3 col = textureLod(iChannel0, UV + n, focus).rgb;
				float4 texCoord = float4(UV.x + n.x, UV.y + n.y, 0, focus);
				float4 lod = tex2Dlod(iChannel0, texCoord);
				float3 col = lod.rgb;

				
				// Interpolate between base and highlight color based on noise
			 	// col = lerp(_BaseColor.rgb, _HighlightColor.rgb, noise);

				#ifdef USE_POST_PROCESSING
				t = (T + 3.)*.5;										// make time sync with first lightnoing
				float colFade = sin(t*.2)*.5 + .5 + story;
				col *= lerp(float3(1., 1., 1.), float3(.8, .9, 1.3), colFade);	// subtle color shift
				// float fade = S(0., 10., T);							// fade in at the start
				//float lightning = sin(t*sin(t*10.));				// lighting flicker
				//lightning *= pow(max(0., sin(t + sin(t))), 10.);		// lightning flash
				//col *= 1. + lightning*fade*lerp(1., .1, story*story);	// composite lightning
				col *= 1. - dot(UV -= .5, UV);							// vignette

				#ifdef HAS_HEART
				// col = lerp(pow(col, float3(1.2, 1.2, 1.2)), col, heart);
				// fade *= S(102., 97., T);
				#endif

				// col *= fade;										// composite start and end fade
				#endif

																	//col = vec3(heart);
				return fixed4(col, 1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}