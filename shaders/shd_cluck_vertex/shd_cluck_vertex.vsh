attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#ifdef _YY_HLSL11_
#define MAX_LIGHTS 64
#else
#define MAX_LIGHTS 32
#endif
#define LIGHT_DIRECTIONAL 1.0
#define LIGHT_POINT 2.0
#define LIGHT_SPOT 3.0
#define LIGHT_TYPES 16.0
#define PI 3.141592653

uniform int lightCount;
uniform vec3 lightAmbientColor;
uniform vec4 lightDataPrimary[MAX_LIGHTS];
uniform vec4 lightDataSecondary[MAX_LIGHTS];
uniform vec4 lightDataTertiary[MAX_LIGHTS];

varying vec3 v_FogCameraRelativePosition;

void CommonLightAndFog(inout vec4 baseColor, in vec3 position, in vec3 normal);

void CommonLightAndFog(inout vec4 baseColor, in vec3 position, in vec3 normal) {
    vec3 finalColor = lightAmbientColor;
    
    #ifdef _YY_HLSL11_
    for (int i = 0; i < lightCount; i++) {
    #else
    for (int i = 0; i < MAX_LIGHTS; i++) {
    #endif
        vec3 lightPosition = lightDataPrimary[i].xyz;
        float type = mod(lightDataPrimary[i].w, LIGHT_TYPES);
        vec4 lightExt = lightDataSecondary[i];
        vec4 lightColor = lightDataTertiary[i];
        
        if (type == LIGHT_DIRECTIONAL) {
            // directional light: [dx, dy, dz, type], [0, 0, 0, 0], [r, g, b, 0]
            float NdotL = dot(normal, lightPosition);
            finalColor += lightColor.rgb * NdotL;
        } else if (type == LIGHT_POINT) {
            // point light: [x, y, z, type], [0, 0, range_inner, range_outer], [r, g, b, 0]
            float rangeInner = lightExt.z;
            float rangeOuter = lightExt.w;
            vec3 lightIncoming = position - lightPosition;
            float dist = length(lightIncoming);
            lightIncoming = normalize(-lightIncoming);
            float att = (rangeOuter - dist) / max(rangeOuter - rangeInner, 0.000001);
            
            float NdotL = clamp(dot(normal, lightIncoming), 0.0, 1.0);
            
            finalColor += clamp(att * lightColor.rgb * NdotL, 0.0, 1.0);
        } else if (type == LIGHT_SPOT) {
            // spot light: [x, y, z, type | cutoff_inner], [dx, dy, dz, range], [r, g, b, cutoff_outer]
            vec3 sourceDir = lightExt.xyz;
            float range = lightExt.w;
            float cutoff = lightColor.w;
            float innerCutoff = ((lightDataPrimary[i].w - type) / LIGHT_TYPES) / 128.0;
            
            vec3 lightIncoming = position - lightPosition;
            float dist = length(lightIncoming);
            lightIncoming = -normalize(lightIncoming);
            float NdotL = max(dot(normal, lightIncoming), 0.0);
            float lightAngleDifference = max(dot(lightIncoming, sourceDir), 0.0);
            
            float f = clamp((lightAngleDifference - cutoff) / max(innerCutoff - cutoff, 0.000001), 0.0, 1.0);
            float att = f * (range - dist) / range;
            
            finalColor += clamp(att * lightColor.rgb * NdotL, 0.0, 1.0);
        }
    }
    
    baseColor.rgb *= clamp(finalColor, vec3(0), vec3(1));
    
    v_FogCameraRelativePosition = (gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0)).xyz;
}

void main() {
    vec4 object_space_position = vec4(in_Position, 1.0);
    vec4 worldPosition = gm_Matrices[MATRIX_WORLD] * object_space_position;
    vec4 worldNormal = gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0);
    vec4 finalColor = in_Colour;
    
    CommonLightAndFog(finalColor, worldPosition.xyz, worldNormal.xyz);
    
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_position;
    v_vTexcoord = in_TextureCoord;
    v_vColour = finalColor;
}