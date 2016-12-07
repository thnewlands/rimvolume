Shader "RimVolumetric/Rim-Texture-Unlit" {
    Properties {
	  _MainTex ("XYZ Texture", 2D) = "white" {}
	  _RimTex ("Height Texture", 2D) = "white" {}

	  _MainColor ("Main Color", Color) = (1.0,1.0,1.0,0.0)
	  _DepthContrast ("Depth Contrast", Range(0,1)) = 0.5
      _RimPower ("Rim Power", Range(0,15)) = 3.0
    }
    SubShader {


      Tags { "Queue" = "Transparent" }
	  Cull Back
      CGPROGRAM
	  
       #pragma surface surf Lambert alpha:auto

      struct Input {
          float2 uv_MainTex;
		  float2 uv_RimTex;
		  float3 worldPos;
		  float3 viewDir;
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
		  
		  //main texture + rimtexture and some contrast
          o.Emission = _MainColor*tex + no *_DepthContrast;
		  
		  //the normals used in this rim function are deformed by our rimtexture giving part of the main effect of the shader
          half rim = 1 - saturate(dot (normalize(IN.viewDir), o.Normal * 1/no));
		  
		  //the extra sampling of the rimtexture here helps add a soft layer to our alpha 
		  o.Alpha = 1 - no * 10 * pow (rim, _RimPower); 
	  }
      ENDCG
	  }
	  //FallBack "Diffuse"
  }