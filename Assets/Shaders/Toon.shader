// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "KD/Toon"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Rambert("Rambert", Range( 0 , 1)) = 0
		_MatCap("MatCap", 2D) = "white" {}
		_MainTex("MainTex", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		_Hit("Hit", Float) = 0
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 texcoord_0;
			float3 worldNormal;
			float3 worldPos;
		};

		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform sampler2D _MatCap;
		uniform float _Rambert;
		uniform float _Hit;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 normalizeResult52 = normalize( i.worldNormal );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float dotResult32 = dot( normalizeResult52 , ase_worldlightDir );
			float2 temp_cast_0 = (( ( dotResult32 * _Rambert ) + ( 1.0 - _Rambert ) )).xx;
			o.Emission = ( ( ( _Color * ( tex2D( _MainTex, i.texcoord_0 ) * tex2D( _MatCap, temp_cast_0 ).r ) ) * 1.0 ) + _Hit ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			# include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD6;
				float3 worldNormal : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			fixed4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
0;92;1126;475;1126.674;736.4187;2.034523;True;False
Node;AmplifyShaderEditor.CommentaryNode;43;-1818.853,-218.5257;Float;False;579.9983;375.9989;N * L;4;30;31;32;52;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;31;-1768.852,-168.5258;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.NormalizeNode;52;-1558.715,-150.2613;Float;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;30;-1765.653,47.47256;Float;False;1;0;FLOAT;0.0;False;1;FLOAT3
Node;AmplifyShaderEditor.RangedFloatNode;34;-1411.116,262.1399;Float;False;Property;_Rambert;Rambert;0;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.DotProductOpNode;32;-1392.852,-43.72688;Float;False;2;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;37;-1021.114,259.3326;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1016.095,89.0239;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-727.3849,177.1831;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-970.9432,-203.6348;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;39;-665.7602,-227.8877;Float;True;Property;_MainTex;MainTex;2;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;38;-508.6423,135.2118;Float;True;Property;_MatCap;MatCap;1;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-100.7081,3.926522;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;41;-327.4124,-472.4257;Float;False;Property;_Color;Color;3;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;49;81.3739,-98.58887;Float;False;Constant;_Float0;Float 0;5;0;1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;76.51951,-191.106;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;47;66.65372,-26.88638;Float;False;Property;_Hit;Hit;4;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;45;-2168.308,276.1598;Float;False;531.542;346.4106;N * V;3;24;23;20;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;247.3739,-175.5889;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;23;-2115.982,468.0096;Float;False;World;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.WorldNormalVector;20;-2118.308,326.1601;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;46;432.5763,-139.468;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.DotProductOpNode;24;-1798.615,400.0251;Float;False;2;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;672.8057,-214.5694;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;KD/Toon;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;52;0;31;0
WireConnection;32;0;52;0
WireConnection;32;1;30;0
WireConnection;37;0;34;0
WireConnection;35;0;32;0
WireConnection;35;1;34;0
WireConnection;36;0;35;0
WireConnection;36;1;37;0
WireConnection;39;1;28;0
WireConnection;38;1;36;0
WireConnection;40;0;39;0
WireConnection;40;1;38;1
WireConnection;42;0;41;0
WireConnection;42;1;40;0
WireConnection;48;0;42;0
WireConnection;48;1;49;0
WireConnection;46;0;48;0
WireConnection;46;1;47;0
WireConnection;24;0;20;0
WireConnection;24;1;23;0
WireConnection;0;2;46;0
ASEEND*/
//CHKSM=54091F2CBF2B36193A102334CF231BE16BA2700A