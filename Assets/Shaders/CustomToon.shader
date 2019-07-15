// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CustomToon"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Glossiness("Glossiness", Range( 0 , 100)) = 0
		_SpecularColor("SpecularColor", Color) = (0,0,0,0)
		_Color("Color", Color) = (0,0,0,0)
		_MainTex("MainTex", 2D) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 texcoord_0;
			float3 worldNormal;
			float3 worldPos;
			float3 viewDir;
			INTERNAL_DATA
		};

		uniform sampler2D _MainTex;
		uniform float4 _Color;
		uniform float4 _SpecularColor;
		uniform float _Glossiness;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 normalizeResult41 = normalize( i.worldNormal );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float dotResult3 = dot( normalizeResult41 , ase_worldlightDir );
			float smoothstepResult10 = smoothstep( 0.0 , 0.01 , dotResult3);
			float3 normalizeResult52 = normalize( i.worldNormal );
			float dotResult6 = dot( normalizeResult52 , i.viewDir );
			float4 normalizeResult33 = normalize( ( _WorldSpaceLightPos0 + float4( i.viewDir , 0.0 ) ) );
			float3 normalizeResult44 = normalize( i.worldNormal );
			float dotResult36 = dot( normalizeResult33 , float4( normalizeResult44 , 0.0 ) );
			float smoothstepResult49 = smoothstep( 0.005 , 0.01 , pow( ( smoothstepResult10 * dotResult36 ) , pow( _Glossiness , 2.0 ) ));
			o.Emission = ( tex2D( _MainTex, i.texcoord_0 ) * ( _Color * ( ( _LightColor0 * smoothstepResult10 ) + ( float4(1,1,1,0) * ( pow( dotResult3 , 0.1 ) * ( 1.0 - dotResult6 ) ) ) + ( _SpecularColor * smoothstepResult49 ) ) ) ).rgb;
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
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
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
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
531;329;2546;905;1428.386;957.3148;1.019309;True;False
Node;AmplifyShaderEditor.CommentaryNode;45;-1355.951,435.784;Float;False;1094.169;657.9629;N * H;4;34;36;35;44;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-1081.58,-910.416;Float;False;1195.4;544.6006;Light;6;7;11;10;9;13;12;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;34;-1305.951,485.784;Float;False;769.2922;383.9472;HalfVector;4;33;32;31;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;7;-1031.581,-860.416;Float;False;500.0001;368.0002;N * L;4;4;1;3;41;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;30;-1255.951,535.784;Float;False;0;3;FLOAT4;FLOAT3;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;54;-1320.537,-262.1819;Float;False;842.0576;467.9997;Rim;2;8;53;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-1029.579,-823.2159;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;31;-1218.032,716.754;Float;False;World;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-895.7338,640.9188;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.WorldNormalVector;35;-1124.651,914.7469;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;8;-1270.537,-212.182;Float;False;506.399;369.9995;N * V;4;6;2;5;52;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalizeNode;41;-825.3969,-822.6987;Float;False;1;0;FLOAT3;0.0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;4;-1026.38,-607.217;Float;False;1;0;FLOAT;0.0;False;1;FLOAT3
Node;AmplifyShaderEditor.NormalizeNode;44;-798.3884,914.6481;Float;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.RangedFloatNode;12;-527.603,-439.6456;Float;False;Constant;_max;max;0;0;0.01;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;11;-525.9097,-517.9519;Float;False;Constant;_min;min;0;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.DotProductOpNode;3;-653.5807,-698.4164;Float;False;2;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.WorldNormalVector;5;-1265.336,-174.9821;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.NormalizeNode;33;-694.0818,642.6422;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SmoothstepOpNode;10;-329.8584,-530.33;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;2;-1266.937,21.8177;Float;False;World;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DotProductOpNode;36;-415.7813,725.3712;Float;False;2;0;FLOAT4;0,0,0;False;1;FLOAT3;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.NormalizeNode;52;-1082.893,-174.8929;Float;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.RangedFloatNode;14;-225.0145,695.8557;Float;False;Property;_Glossiness;Glossiness;0;0;0;0;100;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;48;-99.22552,771.351;Float;False;Constant;_Float0;Float 0;5;0;2;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;56;-412.9888,-158.8791;Float;False;Constant;_Float3;Float 3;5;0;0.1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-106.9839,231.8635;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.DotProductOpNode;6;-874.9922,-59.90412;Float;False;2;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.PowerNode;47;75.77448,716.351;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.PowerNode;16;220.696,314.9664;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;50;248.8427,440.8955;Float;False;Constant;_Float1;Float 1;5;0;0.005;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;53;-665.4791,-60.10444;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;51;264.8423,546.4966;Float;False;Constant;_Float2;Float 2;5;0;0.01;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.PowerNode;55;-175.5349,-231.0777;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;61.91882,-138.0217;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;18;402.6826,70.62151;Float;False;Property;_SpecularColor;SpecularColor;1;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SmoothstepOpNode;49;551.2429,396.0956;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;59;172.6231,-361.0352;Float;False;Constant;_RimColor;RimColor;5;0;1,1,1,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LightColorNode;9;-499.5301,-857.2711;Float;False;0;3;COLOR;FLOAT3;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;773.2811,166.9345;Float;False;2;2;0;COLOR;0.0;False;1;FLOAT;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-89.78307,-746.1306;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;493.5072,-237.4948;Float;False;2;2;0;COLOR;0.0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;21;699.9807,-654.0983;Float;False;Property;_Color;Color;2;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;231.3815,-928.5977;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;61;1155.124,-344.6618;Float;False;3;3;0;COLOR;0.0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SamplerNode;24;557.6799,-912.9973;Float;True;Property;_MainTex;MainTex;3;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;1326.318,-446.4784;Float;False;2;2;0;COLOR;0.0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;1507.467,-608.5494;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1689.38,-689.5854;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;CustomToon;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;32;0;30;0
WireConnection;32;1;31;0
WireConnection;41;0;1;0
WireConnection;44;0;35;0
WireConnection;3;0;41;0
WireConnection;3;1;4;0
WireConnection;33;0;32;0
WireConnection;10;0;3;0
WireConnection;10;1;11;0
WireConnection;10;2;12;0
WireConnection;36;0;33;0
WireConnection;36;1;44;0
WireConnection;52;0;5;0
WireConnection;46;0;10;0
WireConnection;46;1;36;0
WireConnection;6;0;52;0
WireConnection;6;1;2;0
WireConnection;47;0;14;0
WireConnection;47;1;48;0
WireConnection;16;0;46;0
WireConnection;16;1;47;0
WireConnection;53;0;6;0
WireConnection;55;0;3;0
WireConnection;55;1;56;0
WireConnection;57;0;55;0
WireConnection;57;1;53;0
WireConnection;49;0;16;0
WireConnection;49;1;50;0
WireConnection;49;2;51;0
WireConnection;19;0;18;0
WireConnection;19;1;49;0
WireConnection;13;0;9;0
WireConnection;13;1;10;0
WireConnection;60;0;59;0
WireConnection;60;1;57;0
WireConnection;61;0;13;0
WireConnection;61;1;60;0
WireConnection;61;2;19;0
WireConnection;24;1;23;0
WireConnection;62;0;21;0
WireConnection;62;1;61;0
WireConnection;26;0;24;0
WireConnection;26;1;62;0
WireConnection;0;2;26;0
ASEEND*/
//CHKSM=A494CEB7C6A5D333344F242C7690ED25F5546D3A