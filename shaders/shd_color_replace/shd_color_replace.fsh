//
// Simple passthrough fragment shader
//
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform bool replace_color;
uniform vec3 src_color[10];
uniform vec3 dst_color[10];

void main()
{
	vec4 texColor = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = v_vColour * texColor;
	
	if (replace_color) {
		for (int i = 0; i < 10; i++) {
			if (texColor.rgb == src_color[i].rgb) {
				gl_FragColor = vec4(dst_color[i].rgb, texColor.a);
			}
		}
	}
	if (gl_FragColor.a < 0.1) {
		discard;
	}
}
