Shader "FX/Laser Beam"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,0,1,1)
		_MainTex ("Gradient (R) Dust (G) Noise (B)", 2D) = "white" {}
		_DustScroll ("Scroll Dust", Float) = 0
		_NoiseScroll ("Scroll Noise", Float) = 0
		_DustScale ("Dust Scale", Float) = 0.1
		_DepthFade ("Edge Fade", Float) = 1
		_Gamma ("Gamma", Range(1, 5)) = 1
		_EmissionGain ("Emission Gain", Range(0, 1)) = 0.5
	}

	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 100

		CGPROGRAM
		#pragma surface surf NoLighting alpha noambient nolightmap

		sampler2D _MainTex;
		sampler2D _CameraDepthTexture;
		float4 _Color;
		fixed _DustScroll;
		fixed _NoiseScroll;
		fixed _DustScale;
		fixed _DepthFade;
		float _Gamma;
		float _EmissionGain;
		
		fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
	    {
	        fixed4 c;
	        c.rgb = s.Albedo;
	        c.a = s.Alpha;
	        return c;
	    }

		struct Input
		{
			float2 uv_MainTex;
			float4 screenPos : TEXCOORD1;
			INTERNAL_DATA
		};

		void surf (Input IN, inout SurfaceOutput o)
		{
			float2 uv_gradient = float2(IN.uv_MainTex.x, IN.uv_MainTex.y);
			
			float dustY = IN.uv_MainTex.y * _DustScale + _DustScroll * _Time;
			float2 uv_dust = float2(IN.uv_MainTex.x * _DustScale, dustY);
			
			float noiseX = IN.uv_MainTex.x + _NoiseScroll * _Time;
			float2 uv_noise = float2(noiseX, IN.uv_MainTex.y);
			
			fixed4 gradient = tex2D(_MainTex, uv_gradient);
			fixed4 dust = tex2D(_MainTex, uv_dust);
			fixed4 noise = tex2D(_MainTex, uv_noise);
			
			o.Alpha = gradient.r * (dust.g * (1 - noise.b)); // using the noise texture as a mask for the dust, so we don't lose too much of the gradient
			o.Alpha *= _Gamma; // pretty straightforward boost that's mainly useful for getting the laser's intensity back in gamma lighting mode
			
			// SOFT EDGES
			float4 depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos));
			float destDepth = LinearEyeDepth(depth) * _DepthFade;
			float diff = saturate((destDepth - IN.screenPos.z));
			o.Alpha *= diff;
			
			o.Emission = _Color * o.Alpha * (exp(_EmissionGain * 10.0f));
		}
		ENDCG
	}
}