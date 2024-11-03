z = 0;
image_speed = 0;
image_alpha = 0;

building_height = 256;
building_width = 32;
building_length = 256;
building_color = c_white;//make_color_rgb(irandom(255), irandom(255), irandom(255));
z_start = 0;
z_end = 32;
display_image_index = 0;
floors = 1;

function init_vertex_buffer() {
	var x0 = x;
	var y0 = y;
	var x1 = x + lengthdir_x(building_width, direction);
	var y1 = y + lengthdir_y(building_width, direction);
	var x2 = x + lengthdir_x(building_length, direction-90);
	var y2 = y + lengthdir_y(building_length, direction-90);
	var x3 = x1 + lengthdir_x(building_length, direction-90);
	var y3 = y1 + lengthdir_y(building_length, direction-90);
	//matrix = matrix_build(x, y, z, 0, 0, direction, 1, 1, 1);
	image_xscale = building_width;
	image_yscale = building_length;
	image_angle = direction;
	building_height = 128 * floors;
	
	var building_color_drk = make_color_hsv(color_get_hue(building_color), color_get_saturation(building_color), color_get_value(building_color) - $11);
	var building_sprite = spr_building_front_1_floor;
	var uv = sprite_get_uvs(spr_building_side, 0);
	switch(floors) {
		case 1: 
			building_sprite = spr_building_front_1_floor;
			uv = sprite_get_uvs(building_sprite, display_image_index);
			break;
		case 2: 
			building_sprite = spr_building_front_2_floors;
			uv = sprite_get_uvs(building_sprite, display_image_index);
			break;
		default:
			if (floors > 2) {
				building_sprite = spr_building_front_3_floors;
				uv = sprite_get_uvs(building_sprite, display_image_index);
			}
			break;
	}
	var building_uv = sprite_get_uvs(building_sprite, display_image_index);
	//bottom
	//vertex_position_3d_uv(global.road_vertex_buffer, xx, yy-128, z_start, uv[0], uv[1]);
	//vertex_position_3d_uv(global.road_vertex_buffer, xx+building_width, yy-128, z_end, uv[2], uv[1]);
	//vertex_position_3d_uv(global.road_vertex_buffer, xx+building_width, yy+128, z_end, uv[2], uv[3]);
	//vertex_position_3d_uv(global.road_vertex_buffer, xx+building_width, yy+128, z_end, uv[2], uv[3]);
	//vertex_position_3d_uv(global.road_vertex_buffer, xx, yy+128, z_start, uv[0], uv[3]);
	//vertex_position_3d_uv(global.road_vertex_buffer, xx, yy-128, z_start, uv[0], uv[1]);

	//top
	//vertex_position_3d_uv(global.road_vertex_buffer, xx, yy-128, z_start+building_height, uv[0], uv[1]);
	//vertex_position_3d_uv(global.road_vertex_buffer, xx, yy+128, z_start+building_height, uv[0], uv[3]);
	//vertex_position_3d_uv(global.road_vertex_buffer, xx+building_width, yy+128, z_end+building_height, uv[2], uv[3]);
	//vertex_position_3d_uv(global.road_vertex_buffer, xx+building_width, 128, z_end+building_height, uv[2], uv[3]);
	//vertex_position_3d_uv(global.road_vertex_buffer, xx+building_width, yy-128, z_end+building_height, uv[2], uv[1]);
	//vertex_position_3d_uv(global.road_vertex_buffer, xx, yy-128, z_start+building_height, uv[0], uv[1]);

	// +y
	vertex_position_3d_uv(global.road_vertex_buffer, x2, y2, z_start+building_height, uv[0], uv[1], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x2, y2, z_start, uv[0], uv[3], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x3, y3, z_end, uv[2], uv[3], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x3, y3, z_end, uv[2], uv[3], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x3, y3, z_end+building_height, uv[2], uv[1], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x2, y2, z_start+building_height, uv[0], uv[1], building_color_drk);

	// -y
	vertex_position_3d_uv(global.road_vertex_buffer, x1, y1, z_end+building_height, building_uv[0], building_uv[1], building_color);
	vertex_position_3d_uv(global.road_vertex_buffer, x1, y1, z_end, building_uv[0], building_uv[3], building_color);
	vertex_position_3d_uv(global.road_vertex_buffer, x0, y0, z_start, building_uv[2], building_uv[3], building_color);
	vertex_position_3d_uv(global.road_vertex_buffer, x0, y0, z_start, building_uv[2], building_uv[3], building_color);
	vertex_position_3d_uv(global.road_vertex_buffer, x0, y0, z_start+building_height, building_uv[2], building_uv[1], building_color);
	vertex_position_3d_uv(global.road_vertex_buffer, x1, y1, z_end+building_height, building_uv[0], building_uv[1], building_color);

	// -x
	vertex_position_3d_uv(global.road_vertex_buffer, x0, y0, z_start+building_height, uv[0], uv[1], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x0, y0, z_start, uv[0], uv[3], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x2, y2, z_start, uv[2], uv[3], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x2, y2, z_start, uv[2], uv[3], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x2, y2, z_start+building_height, uv[2], uv[1], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x0, y0, z_start+building_height, uv[0], uv[1], building_color_drk);

	// +x
	vertex_position_3d_uv(global.road_vertex_buffer, x3, y3, z_end+building_height, uv[0], uv[1], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x3, y3, z_end, uv[0], uv[3], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x1, y1, z_end, uv[2], uv[3], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x1, y1, z_end, uv[2], uv[3], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x1, y1, z_end+building_height, uv[2], uv[1], building_color_drk);
	vertex_position_3d_uv(global.road_vertex_buffer, x3, y3, z_end+building_height, uv[0], uv[1], building_color_drk);
}