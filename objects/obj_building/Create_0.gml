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
	var x0 = x + lengthdir_x(building_width / 2 , direction+45);
	var y0 = y + lengthdir_y(building_width / 2, direction+45);
	var x1 = x + lengthdir_x(building_width / 2, direction+135);
	var y1 = y + lengthdir_y(building_width / 2, direction+135);
	var x2 = x + lengthdir_x(building_length / 2, direction-135);
	var y2 = y + lengthdir_y(building_length / 2, direction-135);
	var x3 = x + lengthdir_x(building_length / 2, direction-45);
	var y3 = y + lengthdir_y(building_length / 2, direction-45);
	//matrix = matrix_build(x, y, z, 0, 0, direction, 1, 1, 1);
	image_xscale = building_width / 2;
	image_yscale = building_length / 2;
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
    var points = [];
	// -y
    points = array_concat(
        points, 
        polygon_create_square_points_3d(
            new Point3D(x0, y0, z_end + building_height),
            new Point3D(x1, y1, z_start + building_height),
            new Point3D(x1, y1, z_start),
            new Point3D(x0, y0, z_end),
          building_uv 
      )
    );

	// +y
    points = array_concat(
        points, 
        polygon_create_square_points_3d(
            new Point3D(x2, y2, z_start + building_height),
            new Point3D(x3, y3, z_end + building_height),
            new Point3D(x3, y3, z_end),
            new Point3D(x2, y2, z_start),
            building_uv 
        )
    );

	// -x
    points = array_concat(
        points, 
        polygon_create_square_points_3d(
            new Point3D(x1, y1, z_start + building_height),
            new Point3D(x2, y2, z_start + building_height),
            new Point3D(x2, y2, z_start),
            new Point3D(x1, y1, z_start),
            building_uv 
        )
    );

	// +x
    points = array_concat(
        points, 
        polygon_create_square_points_3d(
            new Point3D(x3, y3, z_end + building_height),
            new Point3D(x0, y0, z_end + building_height),
            new Point3D(x0, y0, z_end),
            new Point3D(x3, y3, z_end),
            building_uv 
        )
    );
    
    // add points to vertex buffer
    for (var i = 0; i < array_length(points); i++) {
        var data = points[@ i];
        var point = data[@ 0];
        var uv = data[@ 1];
        vertex_position_3d_uv(
            global.road_vertex_buffer,
            point.x,
            point.y,
            point.z,
            uv.u,
            uv.v
        );
    }
}