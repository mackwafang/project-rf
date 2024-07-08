
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
	vertex_submit(global.prop_vertex_buffer, pr_trianglelist, prop_tex);
	
	gpu_set_cullmode(cull_clockwise);
	vertex_submit(global.road_vertex_buffer, pr_trianglelist, tex);
	gpu_set_cullmode(cull_noculling);
	
	with (obj_car_parent) {
		vertex_submit(vehicle_vertex_buffer, pr_trianglelist, surface_get_texture(render_surface));
	}
	
	if (global.GAMEPLAY_LIGHTING) {
		cluck_set_light_ambient(c_black);
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
				car.z+16,
				dcos(car.direction),
				-dsin(car.direction),
				-dtan(car.on_road_index.elevation),
				1000,
				15,
				10
			);
			cluck_set_light_point(
				light_index + 1,
				c_red,
				car.x+lengthdir_x(-8, car.direction),
				car.y+lengthdir_y(-8, car.direction),
				car.z+5,
				16,
				4
			);
			light_index += 2;
		}
	
		for (var i = 0; i < instance_number(obj_street_light); i++) {
			var light = instance_find(obj_street_light, i);
			if ((current_cp-2 <= light.assigned_cp) & (light.assigned_cp <= current_cp+2)) {
				if (light_index < CLUCK_MAX_LIGHTS) {
					cluck_set_light_point(
						light_index,
						 #fff5b6,
						light.x,
						light.y,
						light.z + 256,
						800,
						400
					);
				
					light_index += 1;
				}
			}
		}
		// disable other lights 
		//for (var i = light_index; i < CLUCK_MAX_LIGHTS; i++) {cluck_set_light_disable(i);}
	
		shader_reset();
	}
}

if (global.DEBUG_ROAD_DRAW_CONTROL_POINTS) {
	for (var i = 0; i < array_length(control_points) - 1; i++) {
		var road = control_points[@ i];
		var next_road = control_points[@ i + 1];
		draw_line_color(
			road.x,
			road.y,
			next_road.x,
			next_road.y, 
			c_red, c_red
		);
		draw_circle_color(road.x, road.y, 4, c_red, c_red, false);
	}
}

if (global.DEBUG_ROAD_DRAW_COLLISION_POINTS) {
	for (var p = 0; p < array_length(road_list) - 1; p++) {
		var cx = road_list[p].get_collision_x();
		var cy = road_list[p].get_collision_y();
		for (var i = 0; i <= 4; i++) {
			draw_line_color(
				cx[i % 4],
				cy[i % 4],
				cx[(i+1) % 4],
				cy[(i+1) % 4],
				c_red,
				c_red
			);
		}
	}
}

// debug road information
if (global.DEBUG_ROAD_DRAW_ROAD_POINTS) {
	for (var i = 0; i < array_length(road_list) - 1; i++) {
		var road = road_list[@ i];
		var next_road = road_list[@ i + 1];
		draw_text_transformed(road.x, road.y, road.z, 1, 1, road.direction-90);
		if (!camera_in_view(road.x, road.y, 256)) {continue;}
		
		var segments = [
			new Vec2(road.x+lengthdir_x(lane_width*road.get_lanes_left(), road.direction+90), road.y+lengthdir_y(lane_width*road.get_lanes_left(), road.direction+90)),
			new Vec2(road.x+lengthdir_x(lane_width*road.get_lanes_right(), road.direction-90), road.y+lengthdir_y(lane_width*road.get_lanes_right(), road.direction-90)),
			new Vec2(next_road.x+lengthdir_x(lane_width*next_road.get_lanes_left(), next_road.direction+90), next_road.y+lengthdir_y(lane_width*next_road.get_lanes_left(), next_road.direction+90)),
			new Vec2(next_road.x+lengthdir_x(lane_width*next_road.get_lanes_right(), next_road.direction-90), next_road.y+lengthdir_y(lane_width*next_road.get_lanes_right(), next_road.direction-90)),
		];
		draw_line_color(
			road.x,
			road.y,
			next_road.x,
			next_road.y, 
			c_blue, c_blue
		);
		if (global.DEBUG_ROAD_DRAW_ROAD_LANES_POINTS) {
			draw_line_color(
				road.x,
				road.y,
				segments[0].x,
				segments[0].y,
				#00ff00, #00ff00
			);
			draw_line_color(
				road.x,
				road.y,
				segments[1].x,
				segments[1].y,
				#00ff00, #00ff00
			);
		}
		
		for (var l = 0; l <= road.get_lanes_left(); l++) {
			if (i == 0) {print($"{l * road.lane_width} {l}");}
			
			draw_line_color(
				road.x + lengthdir_x(l * road.lane_width, road.direction+90),
				road.y + lengthdir_y(l * road.lane_width, road.direction+90),
				next_road.x + lengthdir_x(l * road.lane_width, road.direction+90),
				next_road.y + lengthdir_y(l * road.lane_width, road.direction+90),
				#0000ff,
				#0000ff
			);
		}
		for (var l = 0; l <= road.get_lanes_right(); l++) {
			if (i == 0) {print($"{l * road.lane_width} {l}");}
			
			draw_line_color(
				road.x + lengthdir_x(l * road.lane_width, road.direction-90),
				road.y + lengthdir_y(l * road.lane_width, road.direction-90),
				next_road.x + lengthdir_x(l * road.lane_width, road.direction-90),
				next_road.y + lengthdir_y(l * road.lane_width, road.direction-90),
				#0000ff,
				#0000ff
			);
		}
	
		if ((i % road_segments == 0) or (i == array_length(road_list)-1)) {
			draw_circle_color(road.x, road.y, 8, c_white, c_white, false);
		}
		else {
			draw_circle_color(road.x, road.y, 2, c_white, c_white, false);
		}
	}
}