z = 0;
image_speed = 0;

// tree_vertex_buffer = create_tree_vertex(sprite_index, image_index);
use_billboard = true;
render_scale = {
	x: 1,
	y: 1,
	z: 1
}
height = 0
display_sprite_index = 0;
display_image_index = 0;
matrix = matrix_build(0,0,0,0,0,0,0,0,0);
identity_matrix = matrix_build_identity();
assigned_cp = undefined; // assigned cp to render when camera on said 
image_alpha = 0;
alarm[0] = 1;

function init_vertex_buffer() {
	var tex = sprite_get_texture(display_sprite_index, display_image_index)
	var uv = sprite_get_uvs(display_sprite_index, display_image_index);
	var tw = texture_get_texel_width(tex);
	var th = texture_get_texel_height(tex);
	var w = abs(uv[2] - uv[0]) / tw;//sprite_get_w(spr_tree);
	var h = abs(uv[3] - uv[1]) / th;//sprite_get_h(spr_tree);
	var is_tree = display_sprite_index == spr_tree;
	if (is_tree) {
		switch(display_image_index) {
			case 0: case 1: case 2: case 5:
				w *= 1;
				h *= 1;
				break
			case 3: case 4:
				w *= 0.5;
				h *= 1;
				break
			case 6:
				w *= 0.5;
				h *= 0.5;
				break
		}
	}
	
	var x0 = x + lengthdir_x(w, direction+90);
	var y0 = y + lengthdir_y(w, direction+90);
	var x1 = x + lengthdir_x(w, direction-90);
	var y1 = y + lengthdir_y(w, direction-90);
	
	// for cross polygons
	var x2 = x + lengthdir_x(w, direction);
	var y2 = y + lengthdir_y(w, direction);
	var x3=  x + lengthdir_x(w, direction+180);
	var y3 = y + lengthdir_y(w, direction+180);
	//matrix = matrix_build(x, y, z, 0, 0, direction, 1, 1, 1);
	image_angle = direction;
	height = image_xscale;

	vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z+h	, uv[0], uv[1]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z		, uv[0], uv[3]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z+h	, uv[2], uv[1]);
	
	vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z+h, uv[2], uv[1]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z, uv[0], uv[3]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z, uv[2], uv[3]);
	
	if (is_tree) {
		vertex_position_3d_uv(global.prop_vertex_buffer, x2, y2, z+h	, uv[0], uv[1]);
		vertex_position_3d_uv(global.prop_vertex_buffer, x2, y2, z		, uv[0], uv[3]);
		vertex_position_3d_uv(global.prop_vertex_buffer, x3, y3, z+h	, uv[2], uv[1]);
	
		vertex_position_3d_uv(global.prop_vertex_buffer, x3, y3, z+h, uv[2], uv[1]);
		vertex_position_3d_uv(global.prop_vertex_buffer, x2, y2, z, uv[0], uv[3]);
		vertex_position_3d_uv(global.prop_vertex_buffer, x3, y3, z, uv[2], uv[3]);
	}
}