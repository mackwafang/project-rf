z = 0;
z_end = 0;
height = 32;
length = 0;
display_image_index = 0;
image_alpha = 0;

init_vertex_buffer = function() {
	var x0 = x;
	var y0 = y;
	var x1 = x + lengthdir_x(length, direction);
	var y1 = y + lengthdir_y(length, direction);
		
	var tex = sprite_get_texture(spr_railing, display_image_index);
	var uv = sprite_get_uvs(spr_railing, display_image_index);
	switch (display_image_index) {
		case 0: case 1:
			uv[1] += (uv[3] - uv[1]) * 0.75;
			break;
	}
	
	var tw = texture_get_texel_width(tex);
	var th = texture_get_texel_height(tex);
	var w = abs(uv[2] - uv[0]) / tw;
	var h = height;// abs(uv[3] - uv[1]) / th;
	
	vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z_end + h, uv[0], uv[1]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z + h, uv[2], uv[1]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z_end, uv[0], uv[3]);
		
	vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z + h, uv[2], uv[1]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z, uv[2], uv[3]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z_end, uv[0], uv[3]);
}