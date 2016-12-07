Shader "RimVolumetric/Rim-Clouds" {
    Properties {
	  _MainColor ("Main Color", Color) = (0.26,0.19,0.16,0.0)
	  _DepthContrast ("Depth Contrast", Range(0,.25)) = 0.5
      _RimPower ("Rim Power", Range(0,15)) = 3.0

	  _NoiseOffsets ("Noise Offsets", 2D) = "white" {}
	  _NoiseScale ("Noise Scale", vector) = (0,0,0,0)
	  _Seed ("Seed", float) = .1

	  _SSScale ("SSS Scale", Range(0,1.5)) = 1
	  _Offset("SSS Offset", Range(0,1)) = 0.5
    }

    SubShader {

      Tags { "Queue" = "Transparent" }
	  Cull Back
      CGPROGRAM

       #pragma surface surf WrapLambert alpha:auto

	   float _SSScale;
	   float _Offset;
	   
	   //custom half lambert which accounts for the size of the object and fakes sub surface scattering
		half4 LightingWrapLambert (SurfaceOutput s, half3 lightDir, half atten) {

			//measure the scale of the object by comparing local bounds to world positions
			float4 modelX = float4(1.0, 0.0, 0.0, 0.0);
			float4 modelY = float4(0.0, 1.0, 0.0, 0.0);
			float4 modelZ = float4(0.0, 0.0, 1.0, 0.0);
			float4 modelXInWorld = mul(unity_ObjectToWorld, modelX);
			float4 modelYInWorld = mul(unity_ObjectToWorld, modelY);
			float4 modelZInWorld = mul(unity_ObjectToWorld, modelZ);
			float4 scale = 0;
			scale.x = length(modelXInWorld);
			scale.y = length(modelYInWorld);
			scale.z = length(modelZInWorld);

			//scale is clamped to my liking, otherwise it gets out of control (too dark / too bright)
			float sc = clamp(scale*.2-lightDir,.7,1);
			half NdotL = dot (s.Normal, lightDir);

			//key component of the half lambert function (spreading) mixed with scale
			half diff = NdotL * _SSScale * sc + _Offset / sc;
			half4 c;

			atten *= s.Albedo*s.Alpha;
			c.rgb = s.Albedo *  _LightColor0.rgb * (diff) *_SSScale;
			c.a = s.Alpha;
			return c;
		} 

      struct Input {
          float2 uv_MainTex;
		  float2 uv_RimMap;
          float3 viewDir;
		  float3 worldPos;
		  float4 pos : SV_POSITION;

      };

      sampler2D _MainTex;
	  float4 _MainColor;
      float4 _DepthColor;
	  float _DepthContrast;
      float _RimPower;
	  sampler2D _NoiseOffsets;
	  float _Seed;
	  float4 _NoiseScale;

	  //noise from inigo quilez's Noise - value - 3D demo https://www.shadertoy.com/view/4sfGzS
	  float noise(float3 x) { x *= 4.0; float3 p = floor(x); float3 f = frac(x); f = f*f*(3.0 - 2.0*f); float2 uv = (p.xy + float2(37.0, 17.0)*p.z) + f.xy; float2 rg = tex2D(_NoiseOffsets, (uv + 0.5) / 256.0).yx; return lerp(rg.x, rg.y, f.z); }
      
	  void surf (Input IN, inout SurfaceOutput o) {		  

		  float t = _Seed;

		  //method for sampling from the noise based on world position.
		  half4 uv = 0;
		  uv.x = IN.uv_MainTex.x + t - IN.worldPos.x * _NoiseScale.x;
		  uv.y = IN.uv_MainTex.y + t - IN.worldPos.y * _NoiseScale.y;
		  uv.z = IN.uv_MainTex.x + t - IN.worldPos.z * _NoiseScale.z;

		  //give out top and bottom layers of noise for a parallax effect 
		  float no = smoothstep(noise(uv.xyz*.5 + t*.025 * uv.y * .45),0, .25) * 1;
		  no += smoothstep(noise(uv.xyz*.25 + t*.05 * 1 * .6),0, .55);

		  //half lambert for the inner layers! 
		  half NdotL = dot (o.Normal, _WorldSpaceLightPos0);
		  half innerdiff = NdotL * 1 * _SSScale - .5;
		  
		  //main texture + rimtexture and some contrast and the lighting difference
          o.Albedo = _MainColor + no*_DepthContrast*innerdiff;
		  
		  //the normals used in this rim function are deformed by our rimtexture giving part of the main effect of the shader
          half rim = 1 - saturate(dot (normalize(IN.viewDir), o.Normal * 1/no));
		  
		  //the extra sampling of the rimtexture here helps add a soft layer to our alpha 
		  o.Alpha = 1 - no * 10 * pow (rim, _RimPower); 
	  }
      ENDCG
	  }
	  //FallBack "Diffuse"
  }