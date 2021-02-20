// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water"
{
	Properties
	{
		_NormalMap("Normal Map", 2D) = "white" {}
		_LerpStrenght("Lerp Strenght", Range( 0 , 1)) = 0
		_AnimetUV1XYUV2ZW("Animet UV1 (XY) UV2(ZW)", Vector) = (0,0,0,0)
		_UV1TilingXYScaleZW("UV1 Tiling(XY) Scale(ZW)", Vector) = (0,0,0,0)
		_UV2TilingXYScaleZW("UV2 Tiling(XY) Scale(ZW)", Vector) = (0,0,0,0)
		_NormalMapStrenght2("Normal Map Strenght 2", Float) = 0
		_FresnelPower("Fresnel Power", Range( 0 , 4)) = 0
		_Tint("Tint", Color) = (0,0,0,0)
		_DepthFadeDistance("Depth Fade Distance", Float) = 0
		_CameraDepthFadeLength("Camera Depth Fade Length", Float) = 0
		_CameraDepthFadeOffset("Camera Depth Fade Offset", Float) = 0
		_FoamColor("Foam Color", Color) = (0,0,0,0)
		_FoamSinValue("Foam Sin Value", Float) = 0
		_FoamTimeScale("Foam TimeScale", Float) = 0
		_FoamNormalMap("Foam Normal Map", Float) = 0
		_FoamDepth("Foam Depth", Float) = 0.5
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Off
		GrabPass{ }
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float eyeDepth;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _FoamColor;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform sampler2D _NormalMap;
		uniform float4 _AnimetUV1XYUV2ZW;
		uniform float4 _UV1TilingXYScaleZW;
		uniform float4 _UV2TilingXYScaleZW;
		uniform float _NormalMapStrenght2;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthFadeDistance;
		uniform float _LerpStrenght;
		uniform float4 _Tint;
		uniform float _FresnelPower;
		uniform float _CameraDepthFadeLength;
		uniform float _CameraDepthFadeOffset;
		uniform float _FoamDepth;
		uniform float _FoamNormalMap;
		uniform float _FoamSinValue;
		uniform float _FoamTimeScale;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 appendResult66 = (float4(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g , 0.0 , 0.0));
			float3 ase_worldPos = i.worldPos;
			float2 temp_output_80_0 = (ase_worldPos).xz;
			float2 appendResult85 = (float2(( _Time.x * _AnimetUV1XYUV2ZW.x ) , ( _Time.x * _AnimetUV1XYUV2ZW.y )));
			float2 appendResult90 = (float2(_UV1TilingXYScaleZW.x , _UV1TilingXYScaleZW.y));
			float2 appendResult91 = (float2(_UV1TilingXYScaleZW.z , _UV1TilingXYScaleZW.w));
			float2 UV193 = ( ( ( temp_output_80_0 + appendResult85 ) * appendResult90 ) / appendResult91 );
			float simplePerlin2D154 = snoise( UV193 );
			simplePerlin2D154 = simplePerlin2D154*0.5 + 0.5;
			float2 temp_cast_0 = (simplePerlin2D154).xx;
			float2 appendResult94 = (float2(( _Time.x * _AnimetUV1XYUV2ZW.z ) , ( _Time.x * _AnimetUV1XYUV2ZW.w )));
			float2 appendResult104 = (float2(_UV2TilingXYScaleZW.x , _UV2TilingXYScaleZW.y));
			float2 appendResult105 = (float2(_UV2TilingXYScaleZW.z , _UV2TilingXYScaleZW.w));
			float2 UV2101 = ( ( ( temp_output_80_0 + appendResult94 ) * appendResult104 ) / appendResult105 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth136 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth136 = saturate( abs( ( screenDepth136 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFadeDistance ) ) );
			float depthFade137 = distanceDepth136;
			float4 lerpResult68 = lerp( tex2D( _NormalMap, temp_cast_0 ) , float4( UnpackScaleNormal( tex2D( _NormalMap, UV2101 ), ( _NormalMapStrenght2 * depthFade137 ) ) , 0.0 ) , _LerpStrenght);
			float4 normalMapping70 = lerpResult68;
			float4 screenUV71 = ( appendResult66 - float4( ( 0.1 * (normalMapping70).rga ) , 0.0 ) );
			float4 screenColor62 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,screenUV71.xy);
			float3 indirectNormal133 = WorldNormalVector( i , normalMapping70.rgb );
			Unity_GlossyEnvironmentData g133 = UnityGlossyEnvironmentSetup( 0.0, data.worldViewDir, indirectNormal133, float3(0,0,0));
			float3 indirectSpecular133 = UnityGI_IndirectSpecular( data, 1.0, indirectNormal133, g133 );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float2 appendResult126 = (float2(ase_vertexNormal.x , ase_vertexNormal.y));
			float2 temp_output_128_0 = (normalMapping70).rg;
			float3 appendResult130 = (float3(( appendResult126 - temp_output_128_0 ) , ase_vertexNormal.z));
			float dotResult116 = dot( ase_worldViewDir , appendResult130 );
			float Fresnel122 = pow( ( 1.0 - saturate( abs( dotResult116 ) ) ) , _FresnelPower );
			float cameraDepthFade142 = (( i.eyeDepth -_ProjectionParams.y - _CameraDepthFadeOffset ) / _CameraDepthFadeLength);
			float cameraDepthFade145 = saturate( cameraDepthFade142 );
			float4 lerpResult111 = lerp( screenColor62 , ( float4( indirectSpecular133 , 0.0 ) + _Tint ) , ( Fresnel122 * cameraDepthFade145 ));
			float4 temp_cast_6 = (_FoamDepth).xxxx;
			float mulTime174 = _Time.y * _FoamTimeScale;
			float4 lerpResult163 = lerp( _FoamColor , lerpResult111 , step( temp_cast_6 , ( ( normalMapping70 * _FoamNormalMap ) + ( ( _FoamSinValue * ( ( 2.0 + sin( mulTime174 ) ) / 2.0 ) ) * depthFade137 ) ) ));
			c.rgb = saturate( lerpResult163 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
-1024;-72;1024;1219;1594.534;462.4138;1.354027;False;False
Node;AmplifyShaderEditor.CommentaryNode;106;-4081.613,-202.9209;Inherit;False;1595.869;1203.746;Animated UV´s;24;90;87;79;102;85;83;84;82;91;88;99;81;93;96;97;98;94;104;100;101;86;89;80;105;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TimeNode;82;-3954.352,301.4341;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;86;-4031.613,465.3134;Inherit;False;Property;_AnimetUV1XYUV2ZW;Animet UV1 (XY) UV2(ZW);2;0;Create;True;0;0;False;0;False;0,0,0,0;10,10,5,5;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-3691.2,268.686;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-3694.707,377.4565;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;79;-3858.614,85.81184;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;89;-3618.274,-152.9209;Inherit;False;Property;_UV1TilingXYScaleZW;UV1 Tiling(XY) Scale(ZW);3;0;Create;True;0;0;False;0;False;0,0,0,0;50000,50000,50000,50000;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;85;-3511.083,309.6211;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-3697.49,524.6217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-3700.234,631.628;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;80;-3615.176,129.5063;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;90;-3302.869,-146.8903;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-3307.411,175.2859;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;94;-3488.015,536.7648;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;139;-2146.037,-839.9199;Inherit;False;886.6479;185;Depth Fade;3;138;136;137;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;102;-3789.027,788.8256;Inherit;False;Property;_UV2TilingXYScaleZW;UV2 Tiling(XY) Scale(ZW);4;0;Create;True;0;0;False;0;False;0,0,0,0;50000,50000,50000,50000;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;104;-3299.445,634.559;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;91;-3085.869,-107.8903;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;98;-3307.878,446.4251;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-2096.037,-777.028;Inherit;False;Property;_DepthFadeDistance;Depth Fade Distance;9;0;Create;True;0;0;False;0;False;0;1.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-3104.767,117.2345;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;88;-2881.697,122.3528;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-3103.471,458.7721;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DepthFade;136;-1811.545,-789.9199;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;105;-3101.81,706.7811;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;73;-2461.492,389.3475;Inherit;False;1541.4;753.9883;Normal Mapping;14;152;70;68;69;64;63;108;107;150;149;151;109;110;154;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;100;-2899.061,486.2095;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-2728.347,128.7247;Inherit;False;UV1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;137;-1483.389,-775.39;Inherit;False;depthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-2410.894,439.0776;Inherit;False;93;UV1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-2353.168,986.6022;Inherit;False;137;depthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-2418.849,866.3604;Inherit;False;Property;_NormalMapStrenght2;Normal Map Strenght 2;6;0;Create;True;0;0;False;0;False;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-2709.743,513.6469;Inherit;False;UV2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-2120.697,892.8451;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-2412.432,789.3658;Inherit;False;101;UV2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;154;-2171.38,435.5801;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;63;-1957.002,439.3475;Inherit;True;Property;_NormalMap;Normal Map;0;0;Create;True;0;0;False;0;False;-1;None;5546f1777d9fa404b854abb12a99b04c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;64;-1959.007,660.1462;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;63;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;69;-1933.17,875.3561;Inherit;False;Property;_LerpStrenght;Lerp Strenght;1;0;Create;True;0;0;False;0;False;0;0.999;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;68;-1530.86,575.4526;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-1168.02,579.1255;Inherit;False;normalMapping;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;123;-3409.104,-639.3674;Inherit;False;2335.51;407.1072;Fresnel;14;122;120;119;121;118;117;116;115;114;126;127;128;129;130;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;-3292.86,-359.036;Inherit;False;70;normalMapping;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;114;-3305.226,-596.8849;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;128;-3055.335,-360.8854;Inherit;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;126;-2986.633,-558.9173;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;132;-2746.687,-399.1071;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;115;-2403.593,-589.3674;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;187;-1891.087,1204.848;Inherit;False;1567.277;639.8645;Foam;13;182;174;173;171;172;176;175;186;141;170;185;181;184;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;130;-2526.202,-397.4436;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;72;-2458.618,-223.5645;Inherit;False;1391.313;579.2015;Screen UV´s;8;71;67;66;75;78;74;65;76;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;116;-2186.593,-519.3674;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-1841.087,1728.712;Inherit;False;Property;_FoamTimeScale;Foam TimeScale;14;0;Create;True;0;0;False;0;False;0;1.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;174;-1614.311,1674.999;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;117;-2012.594,-528.3674;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;146;-2302.078,-1122.987;Inherit;False;1306.691;251.0598;Camera Depth Fade;5;145;142;143;144;148;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-2372.122,220.3573;Inherit;False;70;normalMapping;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-2234.078,-987.9872;Inherit;False;Property;_CameraDepthFadeOffset;Camera Depth Fade Offset;11;0;Create;True;0;0;False;0;False;0;1.68;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;65;-2039.301,-173.5645;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;173;-1397.806,1600.837;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;118;-1834.595,-516.3674;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;78;-2023.617,203.0092;Inherit;False;True;True;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-1991.406,57.97247;Inherit;False;Constant;_constant01;constant 0.1;2;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-2252.078,-1072.987;Inherit;False;Property;_CameraDepthFadeLength;Camera Depth Fade Length;10;0;Create;True;0;0;False;0;False;0;2.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;66;-1705.683,-128.1198;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;171;-1227.371,1460.687;Inherit;False;2;2;0;FLOAT;2;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-1740.504,107.8285;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;119;-1662.595,-501.3673;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1828.595,-409.367;Inherit;False;Property;_FresnelPower;Fresnel Power;7;0;Create;True;0;0;False;0;False;0;0.51;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;142;-1836.209,-1029.137;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;148;-1533.412,-1019.781;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;120;-1465.595,-497.3673;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;67;-1490.854,-107.4631;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;172;-1077.385,1473.767;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;176;-1117.194,1362.184;Inherit;False;Property;_FoamSinValue;Foam Sin Value;13;0;Create;True;0;0;False;0;False;0;3.89;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;141;-1007.761,1615.917;Inherit;False;137;depthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;122;-1297.595,-509.3674;Inherit;False;Fresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;145;-1334.057,-1011.889;Inherit;False;cameraDepthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;-992.4198,145.0074;Inherit;False;70;normalMapping;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;186;-860.1859,1342.643;Inherit;False;Property;_FoamNormalMap;Foam Normal Map;15;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-1291.305,-103.2719;Inherit;False;screenUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;-849.4991,1254.848;Inherit;False;70;normalMapping;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;-918.7417,1418.875;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-783.4393,1476.17;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;-627.6125,1302.638;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-834.4781,589.796;Inherit;False;122;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-871.0417,752.9496;Inherit;False;145;cameraDepthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;-976.0021,1.675119;Inherit;False;71;screenUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.IndirectSpecularLight;133;-778.3481,196.322;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;113;-842.9002,391.0024;Inherit;False;Property;_Tint;Tint;8;0;Create;True;0;0;False;0;False;0,0,0,0;0.1916607,0.482126,0.6886792,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;135;-555.958,312.4955;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;62;-747.2686,-40.45919;Inherit;False;Global;_GrabScreen0;Grab Screen 0;0;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;-588.4278,629.7131;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;181;-475.81,1347.998;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-348.5952,558.5449;Inherit;False;Property;_FoamDepth;Foam Depth;16;0;Create;True;0;0;False;0;False;0.5;0.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;156;-428.7569,-129.2943;Inherit;False;Property;_FoamColor;Foam Color;12;0;Create;True;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;167;-149.9916,600.311;Inherit;False;2;0;FLOAT;0.9098039;False;1;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;111;-285.2046,264.1412;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;163;-3.999329,241.1733;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;164;269.9174,271.1738;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;-2159.4,619.5015;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;129;-2779.063,-509.443;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;-2409.272,700.1589;Inherit;False;137;depthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-2426.086,597.7953;Inherit;False;Property;_NormalMapStrenght1;Normal Map Strenght 1;5;0;Create;True;0;0;False;0;False;0;0.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;444.651,62.64839;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;83;0;82;1
WireConnection;83;1;86;1
WireConnection;84;0;82;1
WireConnection;84;1;86;2
WireConnection;85;0;83;0
WireConnection;85;1;84;0
WireConnection;96;0;82;1
WireConnection;96;1;86;3
WireConnection;97;0;82;1
WireConnection;97;1;86;4
WireConnection;80;0;79;0
WireConnection;90;0;89;1
WireConnection;90;1;89;2
WireConnection;81;0;80;0
WireConnection;81;1;85;0
WireConnection;94;0;96;0
WireConnection;94;1;97;0
WireConnection;104;0;102;1
WireConnection;104;1;102;2
WireConnection;91;0;89;3
WireConnection;91;1;89;4
WireConnection;98;0;80;0
WireConnection;98;1;94;0
WireConnection;87;0;81;0
WireConnection;87;1;90;0
WireConnection;88;0;87;0
WireConnection;88;1;91;0
WireConnection;99;0;98;0
WireConnection;99;1;104;0
WireConnection;136;0;138;0
WireConnection;105;0;102;3
WireConnection;105;1;102;4
WireConnection;100;0;99;0
WireConnection;100;1;105;0
WireConnection;93;0;88;0
WireConnection;137;0;136;0
WireConnection;101;0;100;0
WireConnection;149;0;110;0
WireConnection;149;1;151;0
WireConnection;154;0;107;0
WireConnection;63;1;154;0
WireConnection;64;1;108;0
WireConnection;64;5;149;0
WireConnection;68;0;63;0
WireConnection;68;1;64;0
WireConnection;68;2;69;0
WireConnection;70;0;68;0
WireConnection;128;0;127;0
WireConnection;126;0;114;1
WireConnection;126;1;114;2
WireConnection;132;0;126;0
WireConnection;132;1;128;0
WireConnection;130;0;132;0
WireConnection;130;2;114;3
WireConnection;116;0;115;0
WireConnection;116;1;130;0
WireConnection;174;0;182;0
WireConnection;117;0;116;0
WireConnection;173;0;174;0
WireConnection;118;0;117;0
WireConnection;78;0;76;0
WireConnection;66;0;65;1
WireConnection;66;1;65;2
WireConnection;171;1;173;0
WireConnection;75;0;74;0
WireConnection;75;1;78;0
WireConnection;119;0;118;0
WireConnection;142;0;143;0
WireConnection;142;1;144;0
WireConnection;148;0;142;0
WireConnection;120;0;119;0
WireConnection;120;1;121;0
WireConnection;67;0;66;0
WireConnection;67;1;75;0
WireConnection;172;0;171;0
WireConnection;122;0;120;0
WireConnection;145;0;148;0
WireConnection;71;0;67;0
WireConnection;175;0;176;0
WireConnection;175;1;172;0
WireConnection;170;0;175;0
WireConnection;170;1;141;0
WireConnection;185;0;184;0
WireConnection;185;1;186;0
WireConnection;133;0;134;0
WireConnection;135;0;133;0
WireConnection;135;1;113;0
WireConnection;62;0;77;0
WireConnection;140;0;124;0
WireConnection;140;1;147;0
WireConnection;181;0;185;0
WireConnection;181;1;170;0
WireConnection;167;0;189;0
WireConnection;167;1;181;0
WireConnection;111;0;62;0
WireConnection;111;1;135;0
WireConnection;111;2;140;0
WireConnection;163;0;156;0
WireConnection;163;1;111;0
WireConnection;163;2;167;0
WireConnection;164;0;163;0
WireConnection;150;0;109;0
WireConnection;150;1;152;0
WireConnection;129;0;126;0
WireConnection;129;1;128;0
WireConnection;0;13;164;0
ASEEND*/
//CHKSM=A944BF301E5D804BC4F082305E971377514215F5