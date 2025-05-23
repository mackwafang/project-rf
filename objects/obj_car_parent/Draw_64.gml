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
var port_width_half = port_width / 2;

// disable ui if mode is 0
if (global.gameplay_race_interface_mode == INTERFACE_MODE.NONE) {exit;}

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
				var dist_alpha = max(0, 1 - (abs(dist_along_road - obj_controller.main_camera_target.dist_along_road) / 1024));
				if (global.race_timer < 15) {
					dist_alpha *= max(-1, global.race_timer - 15)+1;
				}
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
	#region Globally available U
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
	draw_text(64, 64, $"{drive_force}");
	//draw_text(16, 16, $"accel: {accelerating}");
	//draw_text(16, 32, $"boost: {boosting}");
	//draw_text(16, 48, $"brake: {braking}");
	//draw_text(16, 64, $"finish: {is_completed}");
	//draw_text(16, 80, $"turn: {turn_rate}");
	//draw_text(16, 96, $"elevation: {on_road_index.elevation}");
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
	var hp_frac = (hp / max_hp);
	
	// distance
	draw_set_valign(fa_bottom);
	draw_set_halign(fa_center);
	var dist_scale = (global.gameplay_measure_metrics == MEASURE.METRIC ? 1 : KMH_TO_MPH);	
	var distance_display = string_format(dist_along_road / global.WORLD_TO_REAL_SCALE * dist_scale / 10000, 2, 1);
	var dist_unit = "km";
	if (global.gameplay_measure_metrics == MEASURE.IMPERIAL) {
		dist_unit = "mi";
	}
	draw_text(port_width / 2, port_height - 8, $"{distance_display} {dist_unit}");
	draw_bar_color_border(port_width / 2 - 64, port_height-4, dist_along_road, global.race_length, 128, 4, 2, c_white, c_white, c_white, c_white, 0);
	
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
	
	draw_sprite(spr_ui_ahead_behind, (ahead == -1) ? 0 : 1, port_width_half + 144, port_height - 64);
	var real_dist = dist_to_closest / global.WORLD_TO_REAL_SCALE;
	var scale = 10000;
	var unit = "km";
	var dist = real_dist / scale * dist_scale;
	if (global.gameplay_measure_metrics == MEASURE.IMPERIAL) {
		scale = 10000;
		unit = "mi";
		dist = real_dist / scale * dist_scale
	}
	dist = string_format(dist, 0, 3);
	draw_set_valign(fa_bottom);
	draw_set_halign(fa_left);
	draw_text(port_width_half + 160, port_height - 64, $"{dist} {unit}");
	
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
	draw_text(port_width_half + 160, port_height - 64, (instance_exists(closest_car_index) ? closest_car_index.name : ""));
	
	draw_sprite(spr_race_rank, race_rank-1, port_width_half, port_height - 128);
	
	if (braking) {draw_circle_color(port_width_half-8, port_height - 124, 4, c_red, c_red, false);}
	if (boost_active) {draw_circle_color(port_width_half, port_height - 124, 4, c_yellow, c_yellow, false);}
	if (accelerating) {draw_circle_color(port_width_half+8, port_height - 124, 4, c_green, c_green, false);}
	
	#endregion
	
	#region Full UI
	if (global.gameplay_race_interface_mode == INTERFACE_MODE.FULL) {
		// health bar
		var bar_border = 2;
		var bar_x = port_width_half - 75;
		var bar_y = port_height - 32;
		var bar_height = 18;
		var bar_width = 150;
		var bar_color = c_green;//(hit_immune ? c_gray : c_green);
		if (is_nan(hp_display)) {hp_display = 0;}
	
		if (hp_frac < hp_display) {
			hp_display += max((hp_frac - hp_display) * 0.025, sign(hp_frac - hp_display) * 0.005);
			draw_bar_color_border(bar_x, bar_y, max(0, hp_display*max_hp), max_hp, bar_width, bar_height, bar_border, c_red, c_red, c_red, c_red, 0);
			draw_bar_color_border_no_bkg(bar_x, bar_y, max(0, hp), max_hp, bar_width, bar_height, bar_border, bar_color, bar_color, bar_color, bar_color);
		}
		else {
			hp_display += min((hp_frac - hp_display) * 0.025, sign(hp_frac - hp_display) * 0.005);
			draw_bar_color_border(bar_x, bar_y, max(0, hp), max_hp, bar_width, bar_height, bar_border, c_red, c_red, c_red, c_red, 0);
			draw_bar_color_border_no_bkg(bar_x, bar_y, max(0, hp_display*max_hp), max_hp, bar_width, bar_height, bar_border, bar_color, bar_color, bar_color, bar_color);
		}
		draw_set_valign(fa_middle);
		draw_set_halign(fa_center);
		draw_text(bar_x + (bar_width / 2) + 2, bar_y - (bar_height / 2), $"{hp}/{max_hp}");
		
		// boost bar 
		bar_x = port_width_half - (16 * 5);
		bar_y = port_height - 64;
		var max_bar = 20;
		var bar_frequency = (100 div max_bar);
		var boost_color = (boost_juice < 100 ? c_yellow : c_orange);
		draw_rectangle_color(bar_x, bar_y - 4, bar_x + (16 * 10), bar_y + 4, 0, 0, 0, 0, false);
		for (var i = 0; i < max_bar; i++) {
			var segment = boost_juice div bar_frequency;
			if (segment >= i) {
				var anic = animcurve_get(anic_boost);
				var flash_freq = ((boost_juice - (i * bar_frequency)) / bar_frequency);
				var alpha = animcurve_channel_evaluate(animcurve_get_channel(anic, 1), flash_freq);
				var size = 1;
				if (boost_active) {
					size = animcurve_channel_evaluate(animcurve_get_channel(anic, 0), flash_freq);
				}
				draw_sprite_ext(spr_ui_boost_bar, 0, bar_x + (8 + (i * 16)) * (10 / max_bar), bar_y+1, size / 2 * (10 / max_bar), size / 2, 0, boost_color, alpha);
			}
		}
		
		draw_set_valign(fa_middle);
		draw_set_halign(fa_left);
		// rpm odometer
		var odometer_x = port_width_half - 64;
		var odometer_y = port_height - 72;
		odometer_rpm += ((engine_rpm / engine_rpm_max) - odometer_rpm) * 0.1;
		draw_sprite(spr_odometer_bkg, 0, odometer_x, odometer_y);
	
		draw_set_valign(fa_bottom);
		draw_set_halign(fa_center);
		draw_text_transformed(odometer_x, odometer_y - 20, gear, 0.75, 0.75, 0);
	
		draw_line_width_color(
			odometer_x,
			odometer_y,
			odometer_x + lengthdir_x(32,180 - (odometer_rpm * 180)),
			odometer_y + lengthdir_y(32,180 - (odometer_rpm * 180)),
			3,
			c_red,
			c_red
		)
		//draw_set_valign(fa_bottom);
		//draw_set_halign(fa_center);
		//draw_text(odometer_x, odometer_y - 64, $"{round(odometer_rpm * 10000)} RPM");
	
		// speed odometer
		odometer_x = port_width_half + 64;
		odometer_y = port_height - 72;
		odometer_speed += ((velocity / 3000) - odometer_speed) * 0.1;
		var speed_odometer_spr_index = 0;
		switch (global.gameplay_measure_metrics) {
			case MEASURE.METRIC:
				speed_odometer_spr_index = 1;
				break;
			case MEASURE.IMPERIAL:
				speed_odometer_spr_index = 2;
				break;
		}
		draw_sprite(spr_odometer_bkg, speed_odometer_spr_index, odometer_x, odometer_y);
		// adds off road indicator
		if (!on_road) {
			draw_sprite(spr_offroad_indicator, 0, odometer_x, odometer_y - 64);
		}
	
		// vehicle speed
		draw_set_valign(fa_bottom);
		draw_set_halign(fa_center);
		var speed_unit = (global.gameplay_measure_metrics == MEASURE.METRIC ? "KMH" : "MPH");
		var speed_scale = (global.gameplay_measure_metrics == MEASURE.METRIC ? 1 : KMH_TO_MPH);
		draw_text_transformed(odometer_x, odometer_y - 20, $"{round(velocity * speed_scale * global.WORLD_TO_REAL_SCALE / 10)}", 0.75, 0.75, 0);
	
		draw_line_width_color(
			odometer_x,
			odometer_y,
			odometer_x + lengthdir_x(32,180 - (odometer_speed * 180)),
			odometer_y + lengthdir_y(32,180 - (odometer_speed * 180)),
			3,
			c_red,
			c_red
		);
	}
	#endregion
	
	#region Simple UI
	if (global.gameplay_race_interface_mode == INTERFACE_MODE.SIMPLE) {
		// health
		var bar_x = port_width_half - 108;
		var bar_y = port_height - 48;
		var bar_width = 12;
		var bar_height = 72;
		var bkg_color = 0;
		var bar_color = c_green;
		var bar_border = 2;
		draw_bar_color_border(bar_x, bar_y, max_hp, max_hp, bar_width, bar_height, bar_border, bkg_color, bkg_color, bkg_color, bkg_color, bkg_color, true);
		if (hp_frac < 0.3) {
			var a_flash = animcurve_get(anic_fade_flash);
			var alpha = animcurve_channel_evaluate(animcurve_get_channel(a_flash, 0), (counter%(100))/100);
			draw_set_alpha(alpha);
			draw_bar_color_border_no_bkg(bar_x, bar_y, max_hp, max_hp, bar_width, bar_height, bar_border, c_red, c_red, c_red, c_red, true);
			draw_set_alpha(1)
		}
		draw_bar_color_border_no_bkg(bar_x, bar_y, max(0, hp), max_hp, bar_width, bar_height, bar_border, bar_color, bar_color, bar_color, bar_color, true);
		
		// speed
		var odometer_x = port_width_half + 64;
		var odometer_y = port_height - 48;
		draw_set_valign(fa_bottom);
		draw_set_halign(fa_center);
		var speed_unit = (global.gameplay_measure_metrics == MEASURE.METRIC ? "KMH" : "MPH");
		var speed_scale = (global.gameplay_measure_metrics == MEASURE.METRIC ? 1 : KMH_TO_MPH);
        
		draw_text_transformed(odometer_x, odometer_y - 20, $"{round(velocity * speed_scale * global.WORLD_TO_REAL_SCALE / 10)}", 2, 2, 0);
		draw_text_transformed(odometer_x, odometer_y, speed_unit, 0.75, 0.75, 0);
		// adds off road indicator
		if (!on_road) {
			draw_sprite(spr_offroad_indicator, 0, odometer_x, odometer_y - 64);
		}
		
		// rpm
		odometer_x = port_width_half - 64;
		odometer_y = port_height - 48;
		draw_text_transformed(odometer_x, odometer_y - 20, $"{gear}", 2, 2, 0);
		draw_text_transformed(odometer_x, odometer_y - 17, $"{round(engine_rpm)}", 0.5, 0.5, 0);
		draw_text_transformed(odometer_x, odometer_y, "RPM", 0.75, 0.75, 0);
		
		// boost
		var boost_color = c_yellow;
		var boost_text = string(round(boost_juice));
		var alpha = 1;
		var a_flash = animcurve_get(anic_flash);
		if (boost_juice >= 100) {
			boost_color = c_orange;
			boost_text = "Boost";
			alpha = animcurve_channel_evaluate(animcurve_get_channel(a_flash, 0), (counter%100)/100);
		}
		var boost_value_x = port_width_half;
		var boost_value_y = port_height - 48;
		
		draw_set_alpha(alpha);
		draw_set_color(boost_color);
		draw_text_transformed(boost_value_x, boost_value_y, $"{boost_text}", 0.75, 0.75, 0);
		draw_set_color(c_white);
		draw_set_alpha(1);
	}
	#endregion
}
#endregion