// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Yass Creations/HologramShader"
{
	Properties
	{
		_Diffuse("Diffuse", 2D) = "white" {}
		_Tint("Tint", Color) = (0,0.751724,1,0)
		_SSSsize("SSS size", Float) = 0
		_HoloMask("HoloMask", 2D) = "white" {}
		[Toggle]_UseScreenSpaceScanlines("Use Screen Space Scanlines?", Float) = 1
		_BigScanFreq("Big Scan Freq", Float) = 0.6
		_OSSsize("OSS size", Float) = 5
		_Scale("Scale", Float) = 0
		_Power("Power", Float) = 5
		_Bias("Bias", Float) = 0
		_NoiseLevel("Noise Level", Float) = 0
		_RandomNoiseLevel("Random Noise Level", Range( 0 , 1)) = 0
		_BigScanSpeed("Big Scan Speed", Float) = 0
		_Normal("Normal", 2D) = "bump" {}
		[Toggle]_DisplacementSwitch("DisplacementSwitch", Float) = 1
		[Toggle]_ToggleGlitch("ToggleGlitch", Float) = 1
		[Toggle]_ToggleScanlineDeform("ToggleScanlineDeform", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha noshadow exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPos;
		};

		uniform float _DisplacementSwitch;
		uniform float _ToggleGlitch;
		uniform sampler2D _HoloMask;
		uniform float _NoiseLevel;
		uniform float _RandomNoiseLevel;
		uniform float _ToggleScanlineDeform;
		uniform float _BigScanSpeed;
		uniform float _BigScanFreq;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
		uniform float4 _Tint;
		uniform float _Bias;
		uniform float _Scale;
		uniform float _Power;
		uniform float _UseScreenSpaceScanlines;
		uniform float _OSSsize;
		uniform float _SSSsize;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles63 = 5.0 * 5.0;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset63 = 1.0f / 5.0;
			float fbrowsoffset63 = 1.0f / 5.0;
			// Speed of animation
			float fbspeed63 = _Time[ 1 ] * 20.0;
			// UV Tiling (col and row offset)
			float2 fbtiling63 = float2(fbcolsoffset63, fbrowsoffset63);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex63 = round( fmod( fbspeed63 + 0.0, fbtotaltiles63) );
			fbcurrenttileindex63 += ( fbcurrenttileindex63 < 0) ? fbtotaltiles63 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox63 = round ( fmod ( fbcurrenttileindex63, 5.0 ) );
			// Multiply Offset X by coloffset
			float fboffsetx63 = fblinearindextox63 * fbcolsoffset63;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy63 = round( fmod( ( fbcurrenttileindex63 - fblinearindextox63 ) / 5.0, 5.0 ) );
			// Multiply Offset Y by rowoffset
			float fboffsety63 = fblinearindextoy63 * fbrowsoffset63;
			// UV Offset
			float2 fboffset63 = float2(fboffsetx63, fboffsety63);
			// Flipbook UV
			half2 fbuv63 = ( (( ase_screenPosNorm * _ScreenParams * _NoiseLevel )).xy * _NoiseLevel ) * fbtiling63 + fboffset63;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode48 = tex2Dlod( _HoloMask, float4( fbuv63, 0, 0.0) );
			float clampResult124 = clamp( ( tex2DNode48.a - _RandomNoiseLevel ) , 0.0 , 1.0 );
			float4 appendResult76 = (float4(ase_vertexNormal.x , (float)0 , ase_vertexNormal.z , 0.0));
			float2 appendResult128 = (float2((float)0 , _BigScanSpeed));
			float2 appendResult41 = (float2((float)0 , _BigScanFreq));
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 temp_output_10_0 = (ase_worldPos).xy;
			float2 panner28 = ( 1.0 * _Time.y * appendResult128 + ( appendResult41 * temp_output_10_0 ));
			float4 tex2DNode29 = tex2Dlod( _HoloMask, float4( panner28, 0, 0.0) );
			float clampResult82 = clamp( (0.0 + (tex2DNode29.g - 0.6) * (5.0 - 0.0) / (1.0 - 0.6)) , 0.0 , 0.1 );
			v.vertex.xyz += lerp(float4( 0,0,0,0 ),( float4( lerp(float3( 0,0,0 ),( ase_vertexNormal * clampResult124 ),_ToggleGlitch) , 0.0 ) + lerp(float4( 0,0,0,0 ),( appendResult76 * clampResult82 ),_ToggleScanlineDeform) ),_DisplacementSwitch).xyz;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = tex2D( _Normal, uv_Normal ).rgb;
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			float4 tex2DNode2 = tex2D( _Diffuse, uv_Diffuse );
			float4 temp_output_3_0 = ( tex2DNode2 * _Tint );
			o.Albedo = temp_output_3_0.rgb;
			o.Emission = temp_output_3_0.rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV1 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode1 = ( _Bias + _Scale * pow( 1.0 - fresnelNdotV1, _Power ) );
			float2 appendResult128 = (float2((float)0 , _BigScanSpeed));
			float2 appendResult41 = (float2((float)0 , _BigScanFreq));
			float2 temp_output_10_0 = (ase_worldPos).xy;
			float2 panner28 = ( 1.0 * _Time.y * appendResult128 + ( appendResult41 * temp_output_10_0 ));
			float4 tex2DNode29 = tex2D( _HoloMask, panner28 );
			float clampResult21 = clamp( ( fresnelNode1 * tex2DNode29.g ) , 0.0 , 1.0 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 panner13 = ( 1.0 * _Time.y * float2( 0,0.1 ) + lerp(( temp_output_10_0 * _OSSsize ),( (( ase_screenPosNorm * _ScreenParams * _SSSsize )).xy * _SSSsize ),_UseScreenSpaceScanlines));
			float clampResult61 = clamp( ( tex2DNode29.g * tex2D( _HoloMask, panner13 ).b ) , 0.0 , 1.0 );
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles63 = 5.0 * 5.0;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset63 = 1.0f / 5.0;
			float fbrowsoffset63 = 1.0f / 5.0;
			// Speed of animation
			float fbspeed63 = _Time[ 1 ] * 20.0;
			// UV Tiling (col and row offset)
			float2 fbtiling63 = float2(fbcolsoffset63, fbrowsoffset63);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex63 = round( fmod( fbspeed63 + 0.0, fbtotaltiles63) );
			fbcurrenttileindex63 += ( fbcurrenttileindex63 < 0) ? fbtotaltiles63 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox63 = round ( fmod ( fbcurrenttileindex63, 5.0 ) );
			// Multiply Offset X by coloffset
			float fboffsetx63 = fblinearindextox63 * fbcolsoffset63;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy63 = round( fmod( ( fbcurrenttileindex63 - fblinearindextox63 ) / 5.0, 5.0 ) );
			// Multiply Offset Y by rowoffset
			float fboffsety63 = fblinearindextoy63 * fbrowsoffset63;
			// UV Offset
			float2 fboffset63 = float2(fboffsetx63, fboffsety63);
			// Flipbook UV
			half2 fbuv63 = ( (( ase_screenPosNorm * _ScreenParams * _NoiseLevel )).xy * _NoiseLevel ) * fbtiling63 + fboffset63;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode48 = tex2D( _HoloMask, fbuv63 );
			float clampResult136 = clamp( ( tex2DNode2.a * ( ( 1.0 - ( ( 1.0 - clampResult21 ) * ( 1.0 - clampResult61 ) ) ) * ( 1.0 - tex2DNode48.r ) ) ) , 0.0 , 1.0 );
			o.Alpha = clampResult136;
		}

		ENDCG
	}
	CustomEditor "HoloGramInspector"
}
/*ASEBEGIN
Version=16400
200;73.6;1452;725;1351.183;704.2554;1.426942;True;False
Node;AmplifyShaderEditor.ScreenPosInputsNode;36;-3041.591,-108.6264;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-2759.128,154.3936;Float;False;Property;_SSSsize;SSS size;3;0;Create;True;0;0;False;0;0;0.07;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenParams;34;-3000.693,62.43166;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;9;-2630.095,-107.9435;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-2584.025,39.68892;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-2375.241,36.33326;Float;False;Property;_OSSsize;OSS size;7;0;Create;True;0;0;False;0;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;37;-2415.466,127.717;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2213.18,-152.0374;Float;False;Property;_BigScanFreq;Big Scan Freq;6;0;Create;True;0;0;False;0;0.6;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;10;-2423.29,-113.4697;Float;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;44;-2179.259,-225.3387;Float;False;Constant;_Int0;Int 0;7;0;Create;True;0;0;False;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.DynamicAppendNode;41;-2019.839,-168.4774;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-2953.155,336.1721;Float;False;Property;_NoiseLevel;Noise Level;11;0;Create;True;0;0;False;0;0;0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-2203.95,-53.38445;Float;False;Property;_BigScanSpeed;Big Scan Speed;13;0;Create;True;0;0;False;0;0;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-2186.26,19.46742;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-2180.383,132.3733;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1877.538,-131.2034;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-2750.161,266.5558;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;128;-1874.805,-38.98932;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;46;-2021.356,61.35403;Float;False;Property;_UseScreenSpaceScanlines;Use Screen Space Scanlines?;5;0;Create;True;0;0;False;0;1;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1730.81,-250.3369;Float;False;Property;_Power;Power;9;0;Create;True;0;0;False;0;5;3.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;13;-1731.233,65.9939;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1724.989,-416.8603;Float;False;Property;_Bias;Bias;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1721.234,-331.7318;Float;False;Property;_Scale;Scale;8;0;Create;True;0;0;False;0;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;28;-1733.283,-130.8466;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;67;-2242.551,259.5947;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;27;-1785.44,451.6704;Float;True;Property;_HoloMask;HoloMask;4;0;Create;True;0;0;False;0;None;d7a3678ac74ab9e478c79cd820f852cc;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-1950.016,261.6332;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;1;-1445.484,-336.7855;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-1501.51,37.28297;Float;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;29;-1501.601,-159.17;Float;True;Property;_TextureSample2;Texture Sample 2;5;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;63;-1802.256,259.9988;Float;False;1;0;6;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;5;False;3;FLOAT;20;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WireNode;125;-1206.556,561.9437;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-1157.269,-229.7676;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1156.344,-9.303195;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;61;-933.1616,-10.20676;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;21;-935.1414,-229.8729;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-1166.708,430.498;Float;False;Property;_RandomNoiseLevel;Random Noise Level;12;0;Create;True;0;0;False;0;0;0.851;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-1499.666,231.3962;Float;True;Property;_TextureSample3;Texture Sample 3;8;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;126;-1170.769,607.2754;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;121;-888.5729,328.8896;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;25;-678.6909,176.0667;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;81;-1023.785,588.9232;Float;False;5;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;79;-571.7469,568.6132;Float;False;Constant;_Int1;Int 1;12;0;Create;True;0;0;False;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.OneMinusNode;56;-783.4422,-230.0463;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;59;-770.4251,-9.942111;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-567.3191,-134.4532;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;124;-730.4781,326.0414;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;76;-387.3481,549.5612;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;82;-791.5997,587.4869;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-433.2686,176.0726;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-230.7592,659.4191;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;74;-1148.494,259.897;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;58;-414.3145,-134.0293;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-237.5248,-135.174;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;133;-260.9575,56.06126;Float;False;Property;_ToggleGlitch;ToggleGlitch;16;0;Create;True;0;0;False;0;1;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;134;-193.3573,265.3615;Float;False;Property;_ToggleScanlineDeform;ToggleScanlineDeform;17;0;Create;True;0;0;False;0;1;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;2;-278.2958,-525.123;Float;True;Property;_Diffuse;Diffuse;1;0;Create;True;0;0;False;0;None;c0b60f152d1968341963cfaa4c95baab;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;129;-280.3,-727.8164;Float;True;Property;_Normal;Normal;14;0;Create;True;0;0;False;0;None;None;True;0;False;bump;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;4;-190.0632,-322.632;Float;False;Property;_Tint;Tint;2;0;Create;True;0;0;False;0;0,0.751724,1,0;0,0.8344827,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;46.32783,-150.6843;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;14.12038,38.34683;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;131;188.4832,-645.4267;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;81.84613,-342.552;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;136;234.8022,-149.4195;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;130;-2024.684,-6.112854;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;132;152.2455,11.30219;Float;False;Property;_DisplacementSwitch;DisplacementSwitch;15;0;Create;True;0;0;False;0;1;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;445.0866,-344.9805;Float;False;True;6;Float;HoloGramInspector;0;0;Standard;Yass Creations/HologramShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;3.3;10;25;True;0.68;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;35;0;36;0
WireConnection;35;1;34;0
WireConnection;35;2;11;0
WireConnection;37;0;35;0
WireConnection;10;0;9;0
WireConnection;41;0;44;0
WireConnection;41;1;40;0
WireConnection;47;0;10;0
WireConnection;47;1;45;0
WireConnection;12;0;37;0
WireConnection;12;1;11;0
WireConnection;31;0;41;0
WireConnection;31;1;10;0
WireConnection;65;0;36;0
WireConnection;65;1;34;0
WireConnection;65;2;66;0
WireConnection;128;0;44;0
WireConnection;128;1;127;0
WireConnection;46;0;47;0
WireConnection;46;1;12;0
WireConnection;13;0;46;0
WireConnection;28;0;31;0
WireConnection;28;2;128;0
WireConnection;67;0;65;0
WireConnection;68;0;67;0
WireConnection;68;1;66;0
WireConnection;1;1;50;0
WireConnection;1;2;49;0
WireConnection;1;3;51;0
WireConnection;6;0;27;0
WireConnection;6;1;13;0
WireConnection;29;0;27;0
WireConnection;29;1;28;0
WireConnection;63;0;68;0
WireConnection;125;0;29;2
WireConnection;32;0;1;0
WireConnection;32;1;29;2
WireConnection;60;0;29;2
WireConnection;60;1;6;3
WireConnection;61;0;60;0
WireConnection;21;0;32;0
WireConnection;48;0;27;0
WireConnection;48;1;63;0
WireConnection;126;0;125;0
WireConnection;121;0;48;4
WireConnection;121;1;120;0
WireConnection;81;0;126;0
WireConnection;56;0;21;0
WireConnection;59;0;61;0
WireConnection;57;0;56;0
WireConnection;57;1;59;0
WireConnection;124;0;121;0
WireConnection;76;0;25;1
WireConnection;76;1;79;0
WireConnection;76;2;25;3
WireConnection;82;0;81;0
WireConnection;123;0;25;0
WireConnection;123;1;124;0
WireConnection;83;0;76;0
WireConnection;83;1;82;0
WireConnection;74;0;48;1
WireConnection;58;0;57;0
WireConnection;72;0;58;0
WireConnection;72;1;74;0
WireConnection;133;1;123;0
WireConnection;134;1;83;0
WireConnection;135;0;2;4
WireConnection;135;1;72;0
WireConnection;119;0;133;0
WireConnection;119;1;134;0
WireConnection;131;0;129;0
WireConnection;3;0;2;0
WireConnection;3;1;4;0
WireConnection;136;0;135;0
WireConnection;130;0;127;0
WireConnection;132;1;119;0
WireConnection;0;0;3;0
WireConnection;0;1;131;0
WireConnection;0;2;3;0
WireConnection;0;9;136;0
WireConnection;0;11;132;0
ASEEND*/
//CHKSM=FBE7E4100A1E1AB2263FA824C3380C94FD2439DA