Shader "Custom/CubeFacesToEquirectangular"
{
	Properties
	{
		_TexPosX("+X (right)", 2D) = "white" {}
		_TexNegX("-X (left)", 2D) = "white" {}
		_TexPosY("+Y (up)", 2D) = "white" {}
		_TexNegY("-Y (down)", 2D) = "white" {}
		_TexPosZ("+Z (forward)", 2D) = "white" {}
		_TexNegZ("-Z (back)", 2D) = "white" {}
		_Exposure("Exposure", Float) = 1.0
		_Gamma("Gamma (for output)", Float) = 1.0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				sampler2D _TexPosX;
				sampler2D _TexNegX;
				sampler2D _TexPosY;
				sampler2D _TexNegY;
				sampler2D _TexPosZ;
				sampler2D _TexNegZ;

				float _Exposure;
				float _Gamma;

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					return o;
				}

				// helper: sample a face texture given face uv in [-1..1] coords turned to [0..1]
				inline float4 SampleFace(int faceIdx, float2 st)
				{
					// st expected in [-1,1] range where +x is right and +y is up.
					float2 uv = (st * 0.5) + 0.5; // map from [-1,1] -> [0,1]
					if (faceIdx == 0) return tex2D(_TexPosX, uv); // +X
					if (faceIdx == 1) return tex2D(_TexNegX, uv); // -X
					if (faceIdx == 2) return tex2D(_TexPosY, uv); // +Y
					if (faceIdx == 3) return tex2D(_TexNegY, uv); // -Y
					if (faceIdx == 4) return tex2D(_TexPosZ, uv); // +Z
					return tex2D(_TexNegZ, uv);                   // -Z
				}

				// Convert longitude/latitude UV (u in [0..1], v in [0..1]) to direction
				inline float3 LatLongToDir(float2 uv)
				{
					// longitude (lon) ranges -PI..PI across u
					// latitude (lat) ranges -PI/2..PI/2 across v
					float lon = uv.x * UNITY_PI * 2.0 - UNITY_PI;            // -pi .. +pi
					float lat = uv.y * UNITY_PI - UNITY_PI * 0.5;           // -pi/2 .. +pi/2

					float cosLat = cos(lat);
					float x = cosLat * sin(lon);
					float y = sin(lat);
					float z = cosLat * cos(lon);

					return float3(x, y, z);
				}

				// Map direction to cube-face and 2D coords in [-1..1]
				inline void DirToCubeFaceUV(float3 dir, out int faceIndex, out float2 sc_tc)
				{
					float absX = abs(dir.x);
					float absY = abs(dir.y);
					float absZ = abs(dir.z);

					// Determine major axis
					if (absX >= absY && absX >= absZ)
					{
						// X major
						if (dir.x > 0.0)
						{
							// +X face (faceIndex 0)
							faceIndex = 0;
							// sc = -z / x, tc = -y / x  (range approx [-1..1])
							sc_tc.x = -dir.z / absX;
							sc_tc.y = -dir.y / absX;
						}
						else
						{
							// -X face (faceIndex 1)
							faceIndex = 1;
							// sc = z / -x, tc = -y / -x  => sc = z/absX, tc = -y/absX
							sc_tc.x = dir.z / absX;
							sc_tc.y = -dir.y / absX;
						}
					}
					else if (absY >= absX && absY >= absZ)
					{
						// Y major
						if (dir.y > 0.0)
						{
							// +Y face (faceIndex 2)
							faceIndex = 2;
							// sc = dir.x / absY, tc = dir.z / absY
							sc_tc.x = dir.x / absY;
							sc_tc.y = dir.z / absY;
						}
						else
						{
							// -Y face (faceIndex 3)
							faceIndex = 3;
							// sc = dir.x / absY, tc = -dir.z / absY
							sc_tc.x = dir.x / absY;
							sc_tc.y = -dir.z / absY;
						}
					}
					else
					{
						// Z major
						if (dir.z > 0.0)
						{
							// +Z face (faceIndex 4)
							faceIndex = 4;
							// sc = dir.x / absZ, tc = -dir.y / absZ
							sc_tc.x = dir.x / absZ;
							sc_tc.y = -dir.y / absZ;
						}
						else
						{
							// -Z face (faceIndex 5)
							faceIndex = 5;
							// sc = -dir.x / absZ, tc = -dir.y / absZ
							sc_tc.x = -dir.x / absZ;
							sc_tc.y = -dir.y / absZ;
						}
					}
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// i.uv.x is horizontal panorama (0..1 across 2:1 image)
					// Assume the output texture is 2:1 equirectangular; uv in [0,1]^2
					float2 uv = i.uv;

					uv.x = 1.0 - uv.x;

					// Convert UV into lat-long direction
					float3 dir = LatLongToDir(uv);

					// Choose cube face and get face-local coords (sc, tc in [-1,1])
					int faceIdx;
					float2 st;
					DirToCubeFaceUV(dir, faceIdx, st);

					// sample the chosen face (maps st [-1..1] -> uv [0..1])
					float4 col = SampleFace(faceIdx, st);

					// apply simple exposure/gamma
					col.rgb *= _Exposure;
					if (_Gamma != 1.0)
					{
						col.rgb = pow(col.rgb, 1.0 / _Gamma);
					}
					return col;
				}
				ENDCG
			}
		}
			FallBack Off
}
