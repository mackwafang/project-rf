

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