z = 0;
image_speed = 0;

// tree_vertex_buffer = create_tree_vertex(sprite_index, image_index);
use_billboard = true;
render_scale = {
	x: 1,
	y: 1,
	z: 1
}

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
	var width = abs(uv[2] - uv[0]) / tw;//sprite_get_width(spr_tree);
	var height = abs(uv[3] - uv[1]) / th;//sprite_get_height(spr_tree);
	
	if (display_sprite_index == spr_tree) {
		switch(display_image_index) {
			case 0: case 1: case 2: case 5:
				width *= 1;
				height *= 1;
				break
			case 3: case 4:
				width *= 0.5;
				height *= 1;
				break
			case 6:
				width *= 0.5;
				height *= 0.5;
				break
		}
	}
	
	var x0 = x + lengthdir_x(width, direction+90);
	var y0 = y + lengthdir_y(width, direction+90);
	var x1 = x + lengthdir_x(width, direction-90);
	var y1 = y + lengthdir_y(width, direction-90);
	//matrix = matrix_build(x, y, z, 0, 0, direction, 1, 1, 1);
	image_angle = direction;

	vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z+height	, uv[0], uv[1]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z			, uv[0], uv[3]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z+height	, uv[2], uv[1]);
	
	vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z+height, uv[2], uv[1]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z, uv[0], uv[3]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z, uv[2], uv[3]);
}