//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 c;
	c = vec4(v_vColour.rgb * 0.8, v_vColour.a);
    gl_FragColor = c * texture2D( gm_BaseTexture, v_vTexcoord );
}
