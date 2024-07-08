#ifdef _YY_HLSL11_
#define MAX_LIGHTS 64
#else
#define MAX_LIGHTS 32
#endif
#define LIGHT_NONE 0.0
#define LIGHT_DIRECTIONAL 1.0
#define LIGHT_POINT 2.0
#define LIGHT_SPOT 3.0
#define LIGHT_TYPES 16.0
#define PI 3.141592653

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

// not sure why gm_AlphaRefValue does not work so we have to do this ourselves
uniform float alphaRef;

uniform int lightCount;
uniform vec3 lightAmbientColor;
uniform vec4 lightDataPrimary[MAX_LIGHTS];
uniform vec4 lightDataSecondary[MAX_LIGHTS];
uniform vec4 lightDataTertiary[MAX_LIGHTS];

uniform float fogStrength;
uniform float fogStart;
uniform float fogEnd;
uniform vec3 fogColor;
uniform float fogUseGradient;
uniform sampler2D fogGradient;

uniform vec3 cameraPosition;
uniform float specularStrength;
uniform float specularExponent;

varying vec3 v_LightWorldNormal;
varying vec3 v_LightWorldPosition;
varying vec3 v_FogCameraRelativePosition;

void CommonLightAndFog(inout vec3 baseColor);

void CommonLightAndFog(inout vec3 baseColor) {
    vec3 ambientColor = lightAmbientColor;
    vec3 diffuseColor = vec3(0);
    vec3 specularColor = vec3(0);
    
    vec3 viewDir = normalize(cameraPosition - v_LightWorldPosition);
    
    #ifdef _YY_HLSL11_
    for (int i = 0; i < lightCount; i++) {
    #else
    for (int i = 0; i < MAX_LIGHTS; i++) {
        if (i >= lightCount) continue;
    #endif
        vec3 lightPosition = lightDataPrimary[i].xyz;
        float type = mod(lightDataPrimary[i].w, LIGHT_TYPES);
        vec4 lightExt = lightDataSecondary[i];
        vec4 lightColor = lightDataTertiary[i];
        
        if (type == LIGHT_DIRECTIONAL) {
            // directional light: [dx, dy, dz, type], [0, 0, 0, 0], [r, g, b, 0]
            float NdotL = max(-dot(v_LightWorldNormal, lightPosition), 0.0);
            diffuseColor += lightColor.rgb * NdotL;
            
            vec3 reflectDir = -reflect(lightPosition, v_LightWorldNormal);
            vec3 halfDir = normalize(viewDir - lightPosition);
            float specularIntensity = pow(max(0.0, dot(v_LightWorldNormal, halfDir)), specularExponent);
            
            specularColor += specularStrength * specularIntensity * lightColor.rgb;
        } else if (type == LIGHT_POINT) {
            // point light: [x, y, z, type], [0, 0, range_inner, range_outer], [r, g, b, 0]
            float rangeInner = lightExt.z;
            float rangeOuter = lightExt.w;
            vec3 lightIncoming = normalize(v_LightWorldPosition - lightPosition);
            float dist = distance(v_LightWorldPosition, lightPosition);
            float att = (rangeOuter - dist) / max(rangeOuter - rangeInner, 0.000001);
            
            float NdotL = max(-dot(v_LightWorldNormal, lightIncoming), 0.0);
            diffuseColor += clamp(att * lightColor.rgb * NdotL, 0.0, 1.0);
            
            vec3 reflectDir = reflect(lightIncoming, v_LightWorldNormal);
            vec3 halfDir = normalize(viewDir - lightIncoming);
            float specularIntensity = pow(max(0.0, dot(v_LightWorldNormal, halfDir)), specularExponent);
            
            specularColor += specularStrength * specularIntensity * lightColor.rgb;
        } else if (type == LIGHT_SPOT) {
            // spot light: [x, y, z, type | cutoff_inner], [dx, dy, dz, range], [r, g, b, cutoff_outer]
            vec3 sourceDir = lightExt.xyz;
            float range = lightExt.w;
            float cutoff = lightColor.w;
            float innerCutoff = ((lightDataPrimary[i].w - type) / LIGHT_TYPES) / 128.0;
            vec3 lightIncoming = normalize(v_LightWorldPosition - lightPosition);
            float dist = distance(v_LightWorldPosition, lightPosition);
            
            float NdotL = max(-dot(v_LightWorldNormal, lightIncoming), 0.0);
            float lightAngleDifference = max(-dot(lightIncoming, sourceDir), 0.0);
            float f = clamp((lightAngleDifference - cutoff) / max(innerCutoff - cutoff, 0.000001), 0.0, 1.0);
            float att = f * max((range - dist) / range, 0.0);
            
            diffuseColor += clamp(att * lightColor.rgb * NdotL * 5.0, 0.0, 1.0);
            
            vec3 reflectDir = reflect(lightIncoming, v_LightWorldNormal);
            vec3 halfDir = normalize(-lightIncoming + viewDir);
            float specularIntensity = pow(max(0.0, dot(v_LightWorldNormal, halfDir)), specularExponent);
            
            specularColor += specularStrength * specularIntensity * lightColor.rgb;
        }
    }
    
    baseColor *= clamp(ambientColor + diffuseColor + specularColor, 0.0, 1.0);
    
    float dist = length(v_FogCameraRelativePosition);
    float f = clamp((dist - fogStart) / (fogEnd - fogStart), 0.0, 1.0);
    
    if (fogUseGradient > 0.5) {
        vec4 fogGradientColor = texture2D(fogGradient, vec2(f, 0.0));
        baseColor = mix(baseColor, fogGradientColor.rgb, fogGradientColor.a * fogStrength);
    } else {
        baseColor = mix(baseColor, fogColor, f * fogStrength);
    }
}

void main() {
    gl_FragColor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    CommonLightAndFog(gl_FragColor.rgb);
    if (gl_FragColor.a < alphaRef) discard;
}