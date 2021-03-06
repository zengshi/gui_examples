// ======================================================================================
// File         : AlphaBlendVertColorClipping.shader
// Author       : Wu Jie 
// Last Change  : 10/29/2013 | 19:44:51 PM | Tuesday,October
// Description  : 
// ======================================================================================

///////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////

Shader "ex2D/Alpha Blended (Use Vertex Color) (Clipping)" {
    Properties {
        _MainTex ("Atlas Texture", 2D) = "white" {}
        _ClipRect ("Clip Rect", Vector) = ( 0, 0, 0, 0 )
    }

    // ======================================================== 
    // cg 
    // ======================================================== 

    SubShader {
        Tags { 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent" 
        }
        Cull Off 
        Lighting Off 
        ZWrite Off 
        Fog { Mode Off }
        Blend SrcAlpha OneMinusSrcAlpha

        pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			float4 _ClipRect = float4(0.0, 0.0, 1.0, 1.0);
			float4x4 _ClipMatrix;

			struct appdata_t {
				float4 vertex   : POSITION;
				fixed4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex        : POSITION;
				fixed4 color         : COLOR;
				float2 texcoord      : TEXCOORD0;
				float2 worldPosition : TEXCOORD1;
			};

			v2f vert ( appdata_t v ) {
				v2f o;
                float4 wpos = mul(_Object2World, v.vertex);
                o.worldPosition = mul(_ClipMatrix, wpos).xy;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				return o;
			}

			fixed4 frag ( v2f v ) : COLOR {
                float2 half_wh = _ClipRect.zw * 0.5f;
				float2 factor = abs ( v.worldPosition - _ClipRect.xy ) / half_wh;
				fixed4 outColor = tex2D ( _MainTex, v.texcoord );
                outColor.rgb = v.color.rgb;
                outColor.a = outColor.a * v.color.a;
                if ( 1.0 - max ( factor.x, factor.y ) <= 0.0f )
                    outColor.a = 0.0f;
                return outColor; 
                // clip ( 1.0 - max ( factor.x, factor.y ) );
			}
			ENDCG
        }
    }

    // ======================================================== 
    // fallback 
    // ======================================================== 

    SubShader {
        Tags { 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent" 
        }
        Cull Off 
        Lighting Off 
        ZWrite Off 
        Fog { Color (0,0,0,0) }
        Blend SrcAlpha OneMinusSrcAlpha

        BindChannels {
            Bind "Color", color
            Bind "Vertex", vertex
            Bind "TexCoord", texcoord
        }

        Pass {
            SetTexture [_MainTex] {
                combine texture * primary
            }
        }
    }
}
