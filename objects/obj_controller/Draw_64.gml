
var port_width = view_wport[obj_controller.main_camera];
var port_height = view_hport[obj_controller.main_camera];
var dist_unit = (global.GAMEPLAY_MEASURE_METRICS == MEASURE.METRIC ? "km" : "mi");
var dist_scale = (global.GAMEPLAY_MEASURE_METRICS == MEASURE.METRIC ? 1 : KMH_TO_MPH);	

with (main_camera_target) {
	event_perform(ev_draw, ev_gui);
}

draw_set_font(fnt_game);

draw_set_valign(fa_top);
draw_set_halign(fa_left);
draw_text(0, 0, $"{fps}\n{instance_number(obj_car)}");

// draw race length
draw_set_valign(fa_top);
draw_set_halign(fa_right);
draw_text(main_camera_size.width, 0, $"{global.race_length / global.WORLD_TO_REAL_SCALE * dist_scale / 10000} {dist_unit}");

var ranking_verticle_cap = 20;
for (var rank = 0; rank < array_length(global.car_ranking); rank++) {
	var vehicle = global.car_ranking[rank];
	
	var dist = vehicle.dist_along_road;
	//if (rank > 0) {
	//	dist = vehicle.dist_along_road - car_ranking[0].dist_along_road;
	//}
	var distance_display = dist / global.WORLD_TO_REAL_SCALE * dist_scale / 10000;
	var text_color = c_white;
	if (vehicle.is_completed) {
		text_color = c_green;
	}
	draw_set_color(text_color);
	draw_text(main_camera_size.width - 32, 16 + (rank * ranking_verticle_cap), vehicle.race_rank);
	draw_text(main_camera_size.width - 48, 16 + (rank * ranking_verticle_cap), $"{distance_display} {dist_unit}");
	draw_set_color(c_white);
	draw_sprite_ext(vehicle.sprite_index, vehicle.image_index, main_camera_size.width - 16, 24 + (rank * ranking_verticle_cap), 1, 1, 90, vehicle.image_blend, 1);
	if (vehicle.is_respawning) {
		draw_sprite_ext(spr_cross, 0, main_camera_size.width - 16, 24 + (rank * ranking_verticle_cap), 1, 1, 90, c_white, 1);
	}
	vehicle.ai_behavior.race_rank = rank + 1;
	// draw_sprite_ext(spr_bike, vehicle.image_index, main_camera_size.width - 16, 24 + (rank * ranking_verticle_cap), 1, 1, 90, c_white, 1);
}


// starting timer
if (alarm[0] > 0 || global.game_state_paused) {
	draw_set_alpha(0.6);
	draw_rectangle_color(0, 0, main_camera_size.width, main_camera_size.height, 0, 0, 0, 0, false);
	draw_set_alpha(1);
}

if (0 < alarm[0] && alarm[0] < 3 * global.display_freq) {
	draw_set_valign(fa_middle);
	draw_set_halign(fa_center);
	draw_sprite_ext(spr_starting_number, (alarm[0] div global.display_freq), main_camera_size.width / 2, main_camera_size.height / 2, 1, 2, 0, c_white, 1);
}

if (alarm[0] > 0) {
	// starting black screen
	draw_set_color(0);
	draw_set_alpha((alarm[0] - (5 * global.display_freq)) / 100);
	draw_rectangle(0, 0, port_width, port_height, false);
	draw_set_color(c_white);
	draw_set_alpha(1);	
}

if (global.DEBUG_DRAW_MINIMAP) {
	if (!surface_exists(minimap_surface)) {
		minimap_surface = surface_create(minimap_config.surface_width, minimap_config.surface_height);
		surface_set_target(minimap_surface);
		draw_clear_alpha(c_white, 0);
		surface_reset_target();
	}

	surface_set_target(minimap_surface);
	draw_clear_alpha(0, 0);
	//draw_rectangle_color(
	//	0, 
	//	0,
	//	obj_road_generator.grid_width * minimap_config.border,
	//	obj_road_generator.grid_height * minimap_config.border,
	//	0, 0, 0, 0, false
	//)

	// draw control path
	var cam_vehicle_map_pos = new Point(0, 0);
	var cp = find_nearest_cp(main_camera_target.x, main_camera_target.y) - 2;
	var ri_start = max(0, (cp - 2) * obj_road_generator.road_segments);
	var ri_end = min(global.road_list_length, max(1, cp+6) * obj_road_generator.road_segments);
	
	var top_cp = obj_road_generator.grid_height; // keep the high most y-axis of the path
	for (var i = 0; i < array_length(obj_road_generator.control_path)-1; i++) {
		var point = obj_road_generator.control_path[i];
		if (point div obj_road_generator.grid_height < top_cp) {
			top_cp = point div obj_road_generator.grid_height;
		}
	}
	var init_road_coord = new Point(
		((obj_road_generator.control_path[0] % obj_road_generator.grid_width)*minimap_config.border),
		((obj_road_generator.control_path[0] div obj_road_generator.grid_width)*minimap_config.border)
	);
	var last_road_coord = new Point(
		init_road_coord.x,
		init_road_coord.y
	);
	var scaling_factor = obj_road_generator.control_points_dist / minimap_config.border;
	for (var i = 0; i < array_length(obj_road_generator.road_list) - 1; i++) {
		var road = obj_road_generator.road_list[@i];
		var next_road = obj_road_generator.road_list[@i+1];
		var x1 = last_road_coord.x;
		var y1 = last_road_coord.y;
		var x2 = last_road_coord.x + lengthdir_x(road.length / scaling_factor, road.direction);
		var y2 = last_road_coord.y + lengthdir_y(road.length / scaling_factor, road.direction);
		
		last_road_coord.x = x2;
		last_road_coord.y = y2;
		
		if (ri_start > i || i > ri_end) {
			continue;
		}
		
		draw_line_width_color(
			x1, 
			y1, 
			x2, 
			y2, 
			5, c_white, c_white
		);
	}
	
	vehicle_current_pos_ping = (vehicle_current_pos_ping+1) % 100;
	for (var i = 0; i < global.total_participating_vehicles; i++) {
		var vehicle = participating_vehicles[i];
		if (vehicle != undefined) {
			var road = vehicle.on_road_index;
			var x1 = init_road_coord.x + ((vehicle.x - obj_road_generator.road_list[@ 0].x) / scaling_factor);
			var y1 = init_road_coord.y + ((vehicle.y - obj_road_generator.road_list[@ 0].y) / scaling_factor);
			if (main_camera_target.car_id == vehicle.car_id) {
				cam_vehicle_map_pos.x = x1;
				cam_vehicle_map_pos.y = y1;
			}
			
			var dot_data = {
				size: vehicle.is_player ? 4 : 2,
				color: vehicle.vehicle_color.primary,
			}
			draw_sprite_ext(spr_racer_minimap, 0, x1, y1, 1, 1, vehicle.direction, dot_data.color, 1);
		
			if (vehicle.is_player) {
				var anic = animcurve_get(anic_ping);
				var scale = animcurve_channel_evaluate(animcurve_get_channel(anic, 0), vehicle_current_pos_ping/100) / 2;
				var alpha = animcurve_channel_evaluate(animcurve_get_channel(anic, 1), vehicle_current_pos_ping/100);
				draw_sprite_ext(spr_ping, 0, x1, y1, scale, scale, 0, c_red, alpha);
			}
		}
	}
	surface_reset_target();
	//draw_surface_general(
	//	minimap_surface,
	//	0, 0,
	//	minimap_config.surface_width,
	//	minimap_config.surface_height,
	//	256, 256,
	//	1,
	//	1,
	//	0,
	//	c_white,
	//	c_white,
	//	c_white,
	//	c_white,
	//	1
	//);
	draw_surface_general(
		minimap_surface,
		(cam_vehicle_map_pos.x) - (minimap_config.width / 2),
		(cam_vehicle_map_pos.y) - (minimap_config.height / 2),
		minimap_config.width,
		minimap_config.height,
		minimap_config.x + lengthdir_x(minimap_config.width * 0.75, -main_camera_target.direction+135 + 90),
		minimap_config.y + lengthdir_y(minimap_config.height * 0.75, -main_camera_target.direction+135 + 90),
		1,
		1,
		-main_camera_target.direction + 90,
		c_white,
		c_white,
		c_white,
		c_white,
		1
	);
}

// race timer
draw_set_valign(fa_top);
draw_set_halign(fa_center);
var race_minute = round(global.race_timer) div 60;
var race_second = round(global.race_timer) % 60;
draw_text(port_width / 2, 32, $"{string_replace(string_format(race_minute, 2, 0), " ", 0)}:{string_replace(string_format(race_second, 2, 0), " ", 0)}");

// race difficulty

draw_text(port_width / 2, 12, $"Level {round((global.difficulty - 1) / 0.25) + 1}");