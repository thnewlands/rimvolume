Shader "RimVolumetric/Rim-Texture-Softlight" {
    Properties {
	  _MainTex ("XYZ Texture", 2D) = "white" {}
	  _RimTex ("Height Texture", 2D) = "white" {}

	  _MainColor ("Main Color", Color) = (0.26,0.19,0.16,0.0)
	  _DepthContrast ("Depth Contrast", Range(0,1)) = 0.5
      _RimPower ("Rim Power", Range(0,15)) = 3.0

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
	   uniform float _ShadowIntensity;
	   	
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

			float sc = clamp(scale*scale*.05-lightDir,.5,1);
			half NdotL = dot (s.Normal, lightDir);
			
			//key component of the half lambert function (spreading) mixed with scale
			half diff = NdotL * _SSScale * sc + _Offset / sc;
			half4 c;

			atten *= s.Albedo*s.Alpha;
			c.rgb = s.Albedo *  _LightColor0.rgb * (diff) *_SSScale; //diff*atten
			c.a = s.Alpha;
			return c;
		} 

      struct Input {
          float2 uv_MainTex;
		  float2 uv_RimTex;
          float3 viewDir;
		  float3 worldPos;
		  float4 pos : SV_POSITION;

      };

      sampler2D _MainTex;
	  sampler2D _RimTex;
	  float4 _MainColor;
	  float _DepthContrast;
      float _RimPower;

      void surf (Input IN, inout SurfaceOutput o) {		  
		  half4 tex = tex2D(_MainTex,IN.uv_MainTex);
		  half4 rimtex = tex2D(_RimTex,IN.uv_RimTex);
		  
		  //this eases the transition on the edge
		  float no = smoothstep(rimtex,0, .25) * 1;

		  //another round of half lambert for the inner layer
		  half NdotL = dot (o.Normal, _WorldSpaceLightPos0);
		  half innerdiff = NdotL * 1 * _SSScale - .5;
		  
		  //main texture + rimtexture and some contrast / more sss for for depth
          o.Albedo = _MainColor*tex + no *_DepthContrast*innerdiff;

		  //the normals used in this rim function are deformed by our rimtexture giving part of the main effect of the shader
          half rim = 1 - saturate(dot (normalize(IN.viewDir), o.Normal * 1/no));
		  
		  //the extra sampling of the rimtexture here helps add a soft layer to our alpha 
		  o.Alpha = 1 - no * 10 * pow (rim, _RimPower); 
	  }
      ENDCG
	  }
	  //FallBack "Diffuse"
  }