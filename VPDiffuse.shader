Shader "DevgammExpo/VPDiffuse" {
   Properties 
   {
      _Color ("Diffuse Material Color", Color) = (1,1,1,1) 
      _MainTex("Main texture", 2D) = "white"
   }
   SubShader 
   {
      Pass 
      {      
         Tags { "LightMode" = "ForwardBase" }
 
         CGPROGRAM
         #pragma multi_compile_fwdbase 
         #pragma vertex vert
         #pragma fragment frag
         #pragma target 3.0
 
         #include "UnityCG.cginc" 
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform float4 _Color; 
         uniform float4 _SpecColor; 
         uniform float _Shininess;
 
         struct vertexInput 
         {
            float4 vertex : POSITION0;
            float4 uv : TEXCOORD0;
            float3 normal : NORMAL0;
         };
         struct vertexOutput 
         {
            float4 pos : POSITION0;
            float2 uv : TEXCOORD0;
            float4 posWorld : TEXCOORD1;
            float3 normalDir : TEXCOORD2;
         };
 
         vertexOutput vert(vertexInput input)
         {          
            vertexOutput output;
 
            output.posWorld = mul(_Object2World, input.vertex);
            output.normalDir = normalize(mul(float4(input.normal, 0.0), _World2Object).xyz);
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            
            output.uv = input.uv.xy;
            
            return output;
         }
         
         uniform sampler2D _MainTex;
 
         float4 frag(vertexOutput input) : COLOR0
         {
            float3 viewDirection = normalize(_WorldSpaceCameraPos - input.posWorld.xyz);
            
            // input.normalDir can be affected by bump maps
            
            float3 output = float3(0.0, 0.0, 0.0);
            
            int index = 0;
            while (index < 4)
            {    
               float4 lightPosition = float4(unity_4LightPosX0[index],
                							 unity_4LightPosY0[index], 
                							 unity_4LightPosZ0[index], 1.0);
 
               float3 vertexToLightSource = lightPosition.xyz - input.posWorld.xyz;        
               float3 lightDirection = normalize(vertexToLightSource);
               
               float squaredDistance =  dot(vertexToLightSource, vertexToLightSource);
               float attenuation = 1.0 / (1.0 + unity_4LightAtten0[index] * squaredDistance);
               
               float3 diffuseReflection = attenuation * unity_LightColor[index].rgb * 
               		_Color.rgb * max(0.0, dot(input.normalDir, lightDirection));         
 
               output += diffuseReflection;
               index++;
            }
            
            float dirDirection = normalize(_WorldSpaceLightPos0.xyz);
            output += dot(input.normalDir, dirDirection) * _LightColor0;
 
 			// ambient lighting
            output += UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
 
            return float4(output, 1.0) * tex2D(_MainTex, input.uv);
         }
         ENDCG
      }
   }
   Fallback Off
}