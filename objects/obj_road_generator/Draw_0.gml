// draw roads
if (global.CAMERA_MODE_3D) {
	shader_set(shd_lighting);
	shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_LightPosition"), obj_controller.main_camera_pos_to.x, obj_controller.main_camera_pos_to.y, obj_controller.main_camera_pos_to.z+250);
	shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_LightRadius"), 500);
	shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_ViewPosition"), obj_controller.main_camera_pos.x, obj_controller.main_camera_pos.y, obj_controller.main_camera_pos.z+250);
	shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_ambientColor"), 1.0, 1.0, 1.0);
	shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_lightColor"), 0.0, 0.0, 0.0);
	//shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_ambientColor"), 0.1, 0.1, 0.1);
	//shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_lightColor"), 1.0, 245 / 255, 182 / 255);
	
	var tex = sprite_get_texture(spr_road, 0);
	var prop_tex = sprite_get_texture(spr_tree, 0);
	vertex_submit(global.prop_vertex_buffer, pr_trianglelist, prop_tex);
	
	gpu_set_cullmode(cull_clockwise);
	vertex_submit(global.road_vertex_buffer, pr_trianglelist, tex);
	gpu_set_cullmode(cull_noculling);
	shader_reset();
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