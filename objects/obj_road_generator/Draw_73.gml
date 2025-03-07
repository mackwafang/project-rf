
// draw roads
if (global.CAMERA_MODE_3D) {
	//shader_set(shd_lighting);
	//shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_LightPosition"), obj_controller.main_camera_pos_to.x, obj_controller.main_camera_pos_to.y, obj_controller.main_camera_pos_to.z+250);
	//shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_LightRadius"), 500);
	//shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_ViewPosition"), obj_controller.main_camera_pos.x, obj_controller.main_camera_pos.y, obj_controller.main_camera_pos.z+250);
	//shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_ambientColor"), 1.0, 1.0, 1.0);
	//shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_lightColor"), 0.0, 0.0, 0.0);
	//shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_ambientColor"), 0.1, 0.1, 0.1);
	//shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_lightColor"), 1.0, 245 / 255, 182 / 255);
	
	if (global.GAMEPLAY_LIGHTING) {cluck_apply(shd_cluck_fragment);}
	var tex = sprite_get_texture(spr_road_1_lane, 0);
	var prop_tex = sprite_get_texture(spr_tree, 0);
	var vehicle_tex = sprite_get_texture(spr_bike_3d_detail_2, 0);
	if (vertex_get_number(global.prop_vertex_buffer) > 0) {
		vertex_submit(global.prop_vertex_buffer, pr_trianglelist, prop_tex);
	}
	
	gpu_set_cullmode(cull_clockwise);
	vertex_submit(global.road_vertex_buffer, pr_trianglelist, tex);
	gpu_set_cullmode(cull_noculling);
	
	with (obj_car_parent) {
		var turn_adjust = -turn_rate * 30 / (max(1, vehicle_detail_subimage)*3);
		matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, turn_adjust, 1, 1, 1));
		vertex_submit(vehicle_vertex_buffer, pr_trianglelist, surface_get_texture(render_surface));
		matrix_set(matrix_world, global.IDENTITY_MATRIX);
	}
	
	if (global.GAMEPLAY_LIGHTING) {
		cluck_set_light_ambient($555555);
		cluck_set_spec_camera_position(
			obj_controller.main_camera_target.x,
			obj_controller.main_camera_target.y,
			obj_controller.main_camera_target.z
		)
		cluck_set_spec_strength(0);
		cluck_set_spec_exponent(64);
		cluck_set_fog(true, c_black, 1, 500, 10000);
		var light_index = 0;
		for (var i = 0; i < instance_number(obj_car_parent); i++) {
			var car = instance_find(obj_car_parent, i);
			cluck_set_light_spot(
				light_index,
				c_white,
				car.x,
				car.y,
				car.z + 8,
				dcos(car.direction),
				-dsin(car.direction),
				dsin(car.on_road_index.elevation*2),
				1000,
				35,
				10
			);
			cluck_set_light_point(
				light_index + 1,
				c_red,
				car.x+lengthdir_x(-8, car.direction),
				car.y+lengthdir_y(-8, car.direction),
				car.z+5,
				16 * (car.braking ? 3 : 1),
				4 * (car.braking ? 3 : 1)
			);
			light_index += 2;
        }
        
        // street lights
        for (var ri = max(0, (current_cp-2)*road_segments); ri < (current_cp+2)*road_segments; ri++) {
            var road = road_list[ri];
            var props = road.props;
            for (var _pi = 0; _pi < array_length(props); _pi++) {
                var prop = props[_pi];
                if (prop.object_index != obj_street_light) {continue;}
                
				if (light_index < CLUCK_MAX_LIGHTS) {
					cluck_set_light_point(
						light_index,
						 #fff5b6,
						prop.x,
						prop.y,
						prop.z + 256,
						800,
						400
					);
				
					light_index += 1;
				}
            }
		}
		// disable other lights 
		// for (var i = 0; i < CLUCK_MAX_LIGHTS; i++) {cluck_set_light_disable(i);}
	
		shader_reset();
	}
}