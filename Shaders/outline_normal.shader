Shader "KD/Outline_Normal"
{
	Properties
	{
		_Color("Main Color", Color) = (.5,.5,.5,1)
		_MainTex("Texture", 2D) = "white" {}
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_Outline("Outline width", Range(0.0, 100)) = .005
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent" }

		Pass
		{
			Name "OUTLINE"
			Tags{ "LightMode" = "Always" }
			Cull Off
			ZWrite Off
			ZTest Always
			ColorMask RGB // alpha not used
			Blend SrcAlpha OneMinusSrcAlpha // Normal

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : POSITION;
				float4 color : COLOR;
			};

			uniform float _Outline;
			uniform float4 _OutlineColor;

			v2f vert(appdata_full v)
			{
				// just make a copy of incoming vertex data but scaled according to normal direction
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				float3 norm = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal.xyz);
				float2 offset = TransformViewToProjection(norm.xy);
				o.pos.xy += offset * o.pos.z * _Outline;

				//float3 norm = mul((float3x3)UNITY_MATRIX_MVP, v.tangent.xyz);
				//float2 offset = normalize(norm.xy) / _ScreenParams.xy * _Outline * o.pos.w;
				//o.pos.xy += offset;
				o.color = _OutlineColor;
				return o;
			}
			half4 frag(v2f i) :COLOR
			{
				return i.color;
			}
			ENDCG
		}
		Tags{"RenderType" = "Opaque"}

		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows

		sampler2D _MainTex;

		struct Input
		{
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
}