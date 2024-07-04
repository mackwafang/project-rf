var main_camera = obj_controller.main_camera;
var main_camera_pos = {
	x: camera_get_view_x(main_camera),
	y: camera_get_view_y(main_camera)
};
var main_camera_angle = camera_get_view_angle(main_camera);
var main_camera_size = {
	width: camera_get_view_width(main_camera),
	height: camera_get_view_height(main_camera)
};
var port_width = view_wport[main_camera];
var port_height = view_hport[main_camera];

#region Health Bar
if (ai_behavior.part_of_race) {
	// 2d data
	if (!global.CAMERA_MODE_3D) {
		draw_set_valign(fa_top);
		draw_set_halign(fa_left);
		var original_coord = {
			x1: main_camera_size.width/2,
			y1: main_camera_size.height/2,
			x2: x - main_camera_pos.x + lengthdir_x(-sprite_width + 2, image_angle),
			y2: y - main_camera_pos.y + lengthdir_y(-sprite_width + 2, image_angle),
		}
		var dist = point_distance(original_coord.x1, original_coord.y1, original_coord.x2, original_coord.y2);
		var dir = point_direction(original_coord.x1, original_coord.y1, original_coord.x2, original_coord.y2) + main_camera_angle;
		var draw_x = (main_camera_size.width/2) + lengthdir_x(dist, dir);
		var draw_y = (main_camera_size.height/2) + lengthdir_y(dist, dir);
		draw_sprite_ext(spr_health_bar_small, 0, draw_x, draw_y, 1, 1, 0, c_white, 1);
		draw_sprite_general(spr_health_bar_small, 1, 0, 0, 16, 8, draw_x, draw_y, 1, 1, 0, c_red, c_red, c_red, c_red, 1);
		var health_bar = max(0, hp/max_hp) * 13;
		draw_rectangle_color(draw_x + 1, draw_y+2, draw_x+1 + health_bar, draw_y+5, c_green, c_green, c_green, c_green, false);

		if (ai_behavior.part_of_race) {
			if (race_rank > 0) {
				var rank_str = string(race_rank);
				for (var i = 0; i < string_length(rank_str); i++) {
					draw_sprite(spr_rank_font_small, ord(string_char_at(rank_str, i+1)) - 48, draw_x - ((string_length(rank_str) - i)*4), draw_y);
				}
			}
		}
	}
	else {
		#region draw data around driver on screen
		if (obj_controller.main_camera_target.id != id) {
			var screen_coord = world_to_screen(x, y, z+30, global.view_matrix, global.projection_matrix);
			if (screen_coord[0] != -1 && screen_coord[1] != -1) {
				var dist_alpha = 1 - (abs(dist_along_road - obj_controller.main_camera_target.dist_along_road) / 1024);
				var rank_display = is_completed ? completed_race_rank : race_rank;
				// var bar_border = 2;
				// var bar_height = 8;
				// var bar_width = 30;
		
				// screen_coord[0] -= bar_width / 2;
		
				//draw_bar_color_border(screen_coord[0], screen_coord[1], hp, max_hp, bar_width, bar_height, bar_border, c_yellow, c_yellow, c_yellow, c_yellow, 0);
				shader_set(shd_outline);
				shader_set_uniform_f(global.outline_shader_pixel_w, 2*texture_get_texel_width(sprite_get_texture(spr_race_rank, race_rank-1)));
				shader_set_uniform_f(global.outline_shader_pixel_h, 2*texture_get_texel_height(sprite_get_texture(spr_race_rank, race_rank-1)));
				shader_set_uniform_f(global.outline_shader_alpha_override, dist_alpha);
				draw_sprite_ext(spr_race_rank, rank_display-1, screen_coord[0], screen_coord[1], 0.5, 0.5, 0, c_white, dist_alpha);
				shader_reset();
			}
		}
		#endregion
	}
}
//else {
//	var screen_coord = world_to_screen(x, y, z+30, global.view_matrix, global.projection_matrix);
//	if (screen_coord[0] != -1 && screen_coord[1] != -1) {
//		var dist_alpha = 1 - (abs(dist_along_road - obj_controller.main_camera_target.dist_along_road) / 1024);
//		draw_set_alpha(dist_alpha);
//		draw_set_valign(fa_top);
//		draw_set_halign(fa_center);
//		draw_text(screen_coord[0], screen_coord[1], turn_rate);
//		draw_set_alpha(1);
//	}
//}
#endregion

#region Draw UI elements
if (obj_controller.main_camera_target.id == id) {
	//draw_text(16, 16, $"onroad: {on_road ? "true" : "false"}");
	//draw_set_valign(fa_top);
	//draw_set_halign(fa_left);
	//draw_text(port_width - 256, 16, $"accel: {accelerating}");
	//draw_text(port_width - 256, 32, $"boost: {boosting}");
	//draw_text(port_width - 256, 48, $"brake: {braking}");
	//draw_text(port_width - 256, 64, $"finish: {is_completed}");
	//draw_text(port_width - 256, 80, $"turn: {turn_rate}");
	//draw_text(16, 16, $"{x}, {y}, {z}");
	//draw_text(16, 32, $"{direction}");
	//for (var i = 0; i < max_gear; i++) {
	//	draw_text(16, 48 + (i * 16), $"gear {i} {gear_shift_rpm[i]}");
	//}
	//draw_text(16, 144, $"mass: {mass}");
	//draw_text(16, 160, $"transfer eff.: {transfer_eff}");
	//draw_text(16, 176, $"engine power: {engine_power}");
	
	//draw_set_valign(fa_top);
	//draw_set_halign(fa_left);
	//draw_text(64, 80, $"to_stand: {string_replace(crash_timer, ":", "\n")}");
	// draw_text(64, 96, $"walking: {crash_timer}");
		
	// health bar
	var bar_border = 2;
	var bar_x = (port_width / 2) - 75;
	var bar_y = port_height - 56;
	var bar_height = 16;
	var bar_width = 150;
	var bar_color = c_green;
	hp_display += ((hp / max_hp) - hp_display) * 0.05;
	draw_bar_color_border(bar_x, bar_y, max(0, hp_display*max_hp), max_hp, bar_width, bar_height, bar_border, c_red, c_red, c_red, c_red, 0);
	draw_bar_color_border_no_bkg(bar_x, bar_y, max(0, hp), max_hp, bar_width, bar_height, bar_border, bar_color, bar_color, bar_color, bar_color);
	draw_set_valign(fa_top);
	draw_set_halign(fa_center);
	draw_text(bar_x + (bar_width / 2) + 2, bar_y, $"{hp}/{max_hp}");
	
	// boost bar 
	bar_border = 2;
	bar_x = (port_width / 2) - 75;
	bar_y = port_height - 72;
	bar_height = 8;
	bar_width = 150;
	draw_bar_color_border(bar_x, bar_y, boost_juice, 100, bar_width, bar_height, bar_border, c_yellow, c_yellow, c_yellow, c_yellow, 0);
	draw_set_valign(fa_middle);
	draw_set_halign(fa_left);

	// rpm odometer
	var odometer_x = 64;
	var odometer_y = port_height - 80;
	odometer_rpm += ((engine_rpm / engine_rpm_max) - odometer_rpm) * 0.1;
	draw_sprite(spr_odometer_bkg, 0, odometer_x, odometer_y);
	draw_line_width_color(
		odometer_x,
		odometer_y,
		odometer_x + lengthdir_x(32,180 - (odometer_rpm * 180)),
		odometer_y + lengthdir_y(32,180 - (odometer_rpm * 180)),
		3,
		c_red,
		c_red
	)
	draw_set_valign(fa_bottom);
	draw_set_halign(fa_center);
	draw_text(odometer_x, odometer_y - 64, $"{round(odometer_rpm * 10000)} RPM");
	
	// speed odometer
	odometer_x = 192;
	odometer_y = port_height - 80;
	odometer_speed += ((velocity / 3000) - odometer_speed) * 0.1;
	var speed_odometer_spr_index = 0;
	switch (global.GAMEPLAY_MEASURE_METRICS) {
		case MEASURE.METRIC:
			speed_odometer_spr_index = 1;
			break;
		case MEASURE.IMPERIAL:
			speed_odometer_spr_index = 2;
			break;
	}
	draw_sprite(spr_odometer_bkg, speed_odometer_spr_index, odometer_x, odometer_y);
	draw_line_width_color(
		odometer_x,
		odometer_y,
		odometer_x + lengthdir_x(32,180 - (odometer_speed * 180)),
		odometer_y + lengthdir_y(32,180 - (odometer_speed * 180)),
		3,
		c_red,
		c_red
	)
	draw_set_valign(fa_bottom);
	draw_set_halign(fa_right);
	var speed_unit = (global.GAMEPLAY_MEASURE_METRICS == MEASURE.METRIC ? "KMH" : "MPH");
	var speed_scale = (global.GAMEPLAY_MEASURE_METRICS == MEASURE.METRIC ? 1 : KMH_TO_MPH);
	draw_text(odometer_x, odometer_y - 64, $"{round(velocity * speed_scale * global.WORLD_TO_REAL_SCALE / 10)} ");
	
	draw_set_valign(fa_top);
	draw_set_halign(fa_right);
	draw_text(odometer_x + 32, odometer_y, $"Max: {round(max_velocity * speed_scale * global.WORLD_TO_REAL_SCALE / 10)} ");
	
	draw_set_valign(fa_bottom);
	draw_set_halign(fa_left);
	draw_text(odometer_x, odometer_y - 64, $"{speed_unit}");
	
	// gear
	draw_set_valign(fa_top);
	draw_set_halign(fa_center);
	draw_text(64,port_height - 64,$"{gear} gear");
	
	// race rank
	draw_set_valign(fa_bottom);
	draw_set_halign(fa_center);
	draw_text(port_width / 2, port_height - 80, $"{race_rank}");
	
	// distance
	draw_set_valign(fa_top);
	draw_set_halign(fa_center);
	var dist_scale = (global.GAMEPLAY_MEASURE_METRICS == MEASURE.METRIC ? 1 : KMH_TO_MPH);	
	var distance_display = string_format(dist_along_road / global.WORLD_TO_REAL_SCALE * dist_scale / 10000, 2, 1);
	var dist_unit = "km";
	if (global.GAMEPLAY_MEASURE_METRICS == MEASURE.IMPERIAL) {
		dist_unit = "mi";
	}
	draw_text(port_width / 2, port_height - 32, $"{distance_display} {dist_unit}");
	draw_bar_color_border(port_width / 2 - 64, port_height, dist_along_road, global.race_length, 128, 8, 2, c_white, c_white, c_white, c_white, 0);
	
	// draw info to nearest vehicle
	var dist_to_closest = infinity;
	var closest_car_index = noone;
	var ahead = -1;
	for (var diff = -1; diff <= 2; diff += 2) {
		var rank = race_rank + diff - 1;
		if ((0 <= rank) && (rank < global.total_participating_vehicles)) {
			var dist = abs(global.car_ranking[rank].dist_along_road - dist_along_road);
			if (dist < dist_to_closest) {
				dist_to_closest = dist;
				closest_car_index = global.car_ranking[rank];
				ahead = diff;
			}
		}
	}
	
	draw_set_valign(fa_bottom);
	draw_set_halign(fa_right);
	draw_sprite(spr_ui_ahead_behind, (ahead == -1) ? 0 : 1, port_width - 32, port_height - 66);
	var real_dist = dist_to_closest / global.WORLD_TO_REAL_SCALE;
	var scale = (real_dist < 10000) ? 10 : 10000;
	var unit = (real_dist < 10000) ? "m" : "km";
	draw_text(port_width - 48, port_height - 64, $"{real_dist / scale} {unit}");
	draw_text(port_width - 32, port_height - 48, closest_car_index);
}
#endregion