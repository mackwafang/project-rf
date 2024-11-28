if (global.game_state_paused) {exit;}

// road fidning
var nav_road = on_road_index;//obj_road_generator.road_list[max(0, on_road_index.get_id() + (ai_behavior.reversed_direction ? -1 : 1))];
//vec_to_road = point_to_line(
//	on_road_index.x, on_road_index.y,
//	on_road_index.next_road.x, on_road_index.next_road.y,
//	x, y
//);

dist_along_road = on_road_index.length_to_point + point_distance(on_road_index.x, on_road_index.y, vec_to_road.x, vec_to_road.y);

vec_to_road.x += lengthdir_x(((ai_behavior.desired_lane + 0.5) * on_road_index.lane_width), on_road_index.direction-90);
vec_to_road.y += lengthdir_y(((ai_behavior.desired_lane + 0.5) * on_road_index.lane_width), on_road_index.direction-90);
var dist_to_lane = point_distance(x,y,vec_to_road.x,vec_to_road.y);
//if (dist_to_lane > 1024) {
//	hp = 0;
//}

if (can_move) {
	// moving, not crashed
	if (is_player) {
		if (!is_completed) {
			accelerating = keyboard_check(global.player_input.accelerate);
			braking = keyboard_check(global.player_input.brake);
			boosting = keyboard_check_pressed(global.player_input.boost);
		}
		turning = (keyboard_check(global.player_input.turn.right) << 1) | (keyboard_check(global.player_input.turn.left));
	}
	else {
		accelerating = !is_completed;
	}

	var angle_diff = angle_difference(nav_road.direction, direction);
	if (ai_behavior.reversed_direction) {
		angle_diff = angle_difference(nav_road.direction-180, direction);
	}

	if (accelerating) {
		if (is_player and turning == 0) {
			engine_power += 0.1;
			if (global.GAMEPLAY_TURN_GUIDE) {
				turn_rate += (angle_diff / 720); // moving along curved road
			}
		}
	}
	else {
		engine_power -= 0.1;
	}
	
	#region Non-Player Car Movement
	if (!is_player) {
		// checking other cars
		var look_ahead_threshold = 512;
		var look_ahead_angle = 5;
		//if (on_road_index.zone == ZONE.RIVER) {
		//	look_ahead_threshold = 128;
		//	look_ahead_angle = 2;
		//}
		var instance_ahead = [
			collision_line(x, y, x+lengthdir_x(look_ahead_threshold, direction), y+lengthdir_y(look_ahead_threshold, direction), obj_car_parent, false, true),
			collision_line(x, y, x+lengthdir_x(look_ahead_threshold, direction+look_ahead_angle), y+lengthdir_y(look_ahead_threshold, direction+look_ahead_angle), obj_car_parent, false, true),
			collision_line(x, y, x+lengthdir_x(look_ahead_threshold, direction-look_ahead_angle), y+lengthdir_y(look_ahead_threshold, direction-look_ahead_angle), obj_car_parent, false, true),
		];
		// set special condition to when vehicle evasion can be ignored
		for (var i = 0; i < 3; i++) {
			if (instance_exists(instance_ahead[i])) {
				if (ai_behavior.part_of_race and instance_ahead[i].ai_behavior.part_of_race) {
					instance_ahead[i] = noone;
					continue;
				}
			}
		}
		
		var car_look_ahead = instance_exists(instance_ahead[0]);
		var car_look_left = instance_exists(instance_ahead[1]);
		var car_look_right = instance_exists(instance_ahead[2]);
		var rail_look_left = car_look_left | instance_exists(collision_line(x, y, x+lengthdir_x(look_ahead_threshold, direction+look_ahead_angle), y+lengthdir_y(look_ahead_threshold, direction+look_ahead_angle), obj_railing, false, true));
		var rail_look_right = car_look_right | instance_exists(collision_line(x, y, x+lengthdir_x(look_ahead_threshold, direction-look_ahead_angle), y+lengthdir_y(look_ahead_threshold, direction-look_ahead_angle), obj_railing, false, true));
		//var is_off_road_left = !is_on_road(x+lengthdir_x(look_ahead_threshold/4, image_angle+90), y+lengthdir_y(look_ahead_threshold/4, image_angle+90), last_road_index) ? 1 : 0;
		//var is_off_road_right = !is_on_road(x+lengthdir_x(look_ahead_threshold/4, image_angle-90), y+lengthdir_y(look_ahead_threshold/4, image_angle-90), last_road_index) ? 1 : 0;
			
		engine_power = (is_completed ? 0 : nav_road.get_ideal_throttle());
		turning = 0;
			
		var evade_turn_rate = 0.05;
		if (car_look_left ^ car_look_right) {
			//if (car_look_right) {turn_rate += evade_turn_rate;}
			//else if (car_look_left) {turn_rate -= evade_turn_rate;}
			if (car_look_right) {turning = 2;}
			else if (car_look_left) {turning = 1;}
		}
		
		if (!(car_look_left & car_look_right)) {
			
			//if (rail_look_left) {turn_rate -= evade_turn_rate;}
			//else if (rail_look_right) {turn_rate += evade_turn_rate;}
			if (rail_look_left) {turning = 2;}
			else if (rail_look_right) {turning = 1;}
			
			//if (!is_off_road_left | !is_off_road_right) {
			//	turn_rate += (-(is_off_road_left/100) + (is_off_road_right/100));
			//}
			
			if (ai_behavior.desired_lane > (ai_behavior.reversed_direction ? nav_road.get_lanes_left() : nav_road.get_lanes_right())-1 || ai_behavior.desired_lane < 0) {
				// desired lane doesn't exists, pick a new one
				ai_behavior.change_lane(nav_road);
			}
			
			var side = angle_difference(point_direction(x, y, vec_to_road.x, vec_to_road.y), direction);
			var turn_adjustments = 1;
		
			if (!on_road) {
				// off road, trying to get back on it
				// but only for non-bridge zone, median barrier giving issue with turning
				turn_rate += clamp(sign(side) / 40, -1, 1);
			}
			else {
				// car turning on curved road and moving to its desired lane
				var tr = (angle_diff / 8) * turn_adjustments; // moving along curved road
				
				// moving go desired lane
				if (on_road_index.zone != ZONE.RIVER) {
					if (dist_to_lane > on_road_index.lane_width / 2) {
						tr += sign(side) / 10;
					}
				}
				turn_rate += (tr / 10);
				
				// braking = (abs(tr) > 1) | ((nav_road.get_ideal_throttle() < 0.25) && (abs(angle_diff) > 15));
			}
			//if (ai_behavior.part_of_race) {
			//	turn_rate *= max(1 - (velocity / max_velocity), (velocity / max_velocity)) * 1.2;
			//}
		
			turn_rate += abs(turn_rate / 2) * global.deltatime;
		
			// enables boost
			if (boost_juice >= 100) {
				if (irandom(400) < global.difficulty) {
					boosting = true;
				}
			}
		}
	}
	#endregion
			
	if (abs(turn_rate) > 7.5) {
		hp = 0;
		if (global.DEBUG_PRINT_VEHICLE_CRASH_REASON) {
			print($"dir: {direction}, angle_diff: {angle_diff}, turn_rate: {turn_rate}");
			print($"on_road_index dir: {on_road_index.direction}");
			print($"object {id} (part_of_race: {ai_behavior.part_of_race}, reverse: {ai_behavior.reversed_direction}) destroyed. Turn too hard");
		}
	}

	if (keyboard_check_pressed(vk_up)) {gear_shift_up();}
	if (keyboard_check_pressed(vk_down)) {gear_shift_down();}
	if (keyboard_check_pressed(ord("T"))) {hp = 0;}
	
	
	if (turning != 0) {
		// checking turning
		if (turning & 1 == 0) {
			// checking left turn
			turn_rate -= max(10, abs(turn_rate / 2)) * global.deltatime;
		}
		else if (turning & 2 == 0) {
			// checking right turn
			turn_rate += max(10, abs(turn_rate / 2)) * global.deltatime;
		}
	}
}
else {
	#region crashed, walking to bike
	if (is_respawning) {
		if (instance_exists(bike_obj)) {
			if (point_distance(x, y, bike_obj.x, bike_obj.y) > 16) {
				// walking to bike
				if (crash_timer.is_walking) {
					direction += angle_difference(point_direction(x, y, bike_obj.x, bike_obj.y), direction) * 0.05;
					velocity = 80;
					
					// changing sprite basd on walking direction
					var cam_dir = image_angle;//point_direction(obj_controller.main_camera_pos.x, obj_controller.main_camera_pos.y, x, y);
					var length_to_cam = point_distance(obj_controller.main_camera_pos.x, obj_controller.main_camera_pos.y, x, y);

					var a = new Point(
						lengthdir_x(1, angle_difference(direction, cam_dir)),
						lengthdir_y(1, angle_difference(direction, cam_dir))
					);
					var a_hor = new Point(
						lengthdir_x(1, angle_difference(direction, cam_dir)),
						lengthdir_y(1, angle_difference(direction, cam_dir))
					);
					var b = new Point(
						(obj_controller.main_camera_pos.x - x) / length_to_cam,
						(obj_controller.main_camera_pos.y - y) / length_to_cam
					);
					var _d = -dot_product(a.x, a.y, b.x, b.y);
					var _d_hor = -dot_product(a.x, a.y, b.x, b.y);
					
					if (_d > 0.5) {
						// forward
						vehicle_detail_index = spr_bike_3d_detail_2_walk_up;
					}
					else if (_d < -0.5) {
						// towards
						vehicle_detail_index = spr_bike_3d_detail_2_walk_down;
					}
					else {
						//side
						vehicle_detail_index = spr_bike_3d_detail_2_walk_side;
					}
					
					vehicle_detail_subimage = (counter div 10) % 6
					image_xscale = sign(_d_hor);
				}
			}
			else {
				// getting on bike
				if (crash_timer.to_get_on <= 0 and crash_timer.is_walking) {
					crash_timer.to_get_on = crash_timer.TIME_TO_GET_ON;
					crash_timer.is_walking = false;
					bike_obj.display_sprite_index = spr_1x1;
				}
				direction = on_road_index.direction;
				velocity = 0;
				vehicle_detail_index = spr_bike_3d_detail_2_get_on;
				vehicle_detail_subimage = min(max(0, round(crash_timer.to_get_on / crash_timer.TIME_TO_GET_ON * 10)), 10);
			}
		}
	}
	#endregion
}

// turning = (turn_rate < 0.1 ? 2 : (turn_rate > 0.1 ? 1 : 0));

// "crash" on river
if (!on_road) {
	if (on_road_index.zone == ZONE.RIVER) {
		if (z <= on_road_index.z - 20) {
			hp = 0;
		}
	}
}
// create dust particle
if (!on_road && vertical_on_road) {
	if (velocity > 100) {
		if (on_road_index.zone != ZONE.CITY or on_road_index.zone != ZONE.RIVER) {
			var dust_part = instance_create_layer(x, y, "Instances", obj_dust_particle);
			dust_part.z = z;
			switch(on_road_index.zone) {
				case ZONE.SUBURBAN:
					dust_part.color = $0A62A3;
					break;
				case ZONE.DESERT:
					dust_part.color = $B2D9F8;
					break;
			}
		}
	}
}

// finish
if (!is_completed) {
	is_completed = (dist_along_road >= global.race_length) && (ai_behavior.part_of_race);
	if (is_completed) {
		if (obj_controller.main_camera_target == id) {
			audio_play_sound(snd_yeah, 10, false);
		}
		completed_race_rank = race_rank;
	}
}


if (is_completed) {
	braking = true;
	accelerating = false;
	boosting = false;
	boost_active = false;
}

// calculate engine stuff for acceleration
var engine_to_wheel_ratio = gear_ratio[gear-1] * diff_ratio;
var engine_torque_max = (torque_lookup(engine_rpm) + (300 * sqr(global.difficulty-1)));
// var engine_torque_max = ((horsepower / engine_rpm * 5252) * 8 * global.difficulty);
var engine_torque = engine_torque_max * (boost_active ? 2 : engine_power);
var drive_torque = engine_torque * engine_to_wheel_ratio * transfer_eff;
	
var f_drag = -c_drag * velocity;
var f_rr = -c_rr * velocity;
var f_surface = -mass * global.gravity_3d * ((on_road) ? 0.2 : 5) * (vertical_on_road ? 1 : 0);
if (hp <= 0) {
	f_surface = -mass * global.gravity_3d * (vertical_on_road ? 10 : 0);
}
var f_brake = ((braking) ? -braking_power * 1000 : 0);
var f_turn = -abs(turn_rate) * mass / 1000;
if (velocity <= 0) {
	f_brake = 0;
}
var f_incline = arcsin(on_road_index.elevation / on_road_index.length) * mass * global.gravity_3d;
	
drive_force = (drive_torque / wheel_radius) + f_drag + f_rr + f_brake + f_surface + f_turn + f_incline - push_vector.x;

push_vector.x = max(0, push_vector.x * 0.95);
push_vector.y = max(0, push_vector.y * 0.95);

drive_torque = drive_force * wheel_radius;

if (vertical_on_road) {
	acceleration = (drive_torque / inertia);
	var wheel_rotation_rate = velocity * 100 / 3600 / wheel_radius;
	engine_rpm = (wheel_rotation_rate * engine_to_wheel_ratio * 60 / (2 * pi));
}
velocity = clamp(velocity, 0, max_velocity);
velocity = clamp(velocity, 0, speed_limit / ((global.GAMEPLAY_MEASURE_METRICS == MEASURE.METRIC ? 1 : KMH_TO_MPH) * global.WORLD_TO_REAL_SCALE / 10));

if (engine_rpm >= engine_rpm_max) {engine_rpm = engine_rpm_max;}

gear_shift(); // auto gear shift
engine_power = clamp(engine_power, 0, 1);
gear_shift_wait = clamp(gear_shift_wait-1, 0, 60);

// play engine
var engine_sound_pitch = ((engine_rpm / engine_rpm_max)+1.0);// - (gear / 12);
if (engine_sound_interval == 0) {
	audio_play_sound_on(engine_sound_emitter, (boost_active ? snd_boost : snd_car), false, 2);
}
audio_emitter_pitch(engine_sound_emitter, engine_sound_pitch);
audio_emitter_position(engine_sound_emitter, x, y, z);
//audio_emitter_velocity(engine_sound_emitter, cos(direction), sin(direction), 0);
engine_sound_interval = (engine_sound_interval + 1) % (engine_rpm < 2000 ? 16 : 8);


// remove non-participating cars when too far away
if (abs(obj_controller.main_camera_target.dist_along_road - dist_along_road) > 5000) {
	if (!global.DEBUG_FREE_CAMERA) {
		if (!ai_behavior.part_of_race) {
			//print($"object {id} (part_of_race: {ai_behavior.part_of_race}, reverse: {ai_behavior.reversed_direction}) destroyed. Out of view. {obj_controller.main_camera_target.dist_along_road} {dist_along_road} {abs(obj_controller.main_camera_target.dist_along_road-dist_along_road)} > 5000");
			instance_destroy();
		}
	}
	// randomly destroy car to simulate crashes
	if (irandom(100000) < ((global.total_participating_vehicles - race_rank + 1))) {
		if (!is_player) {
			hp = 0;
		}
	}
}

// boost
if (!boost_active) {
	if (boosting) {
		boost_active = true;
	}
	
	if (boost_juice < 100 && global.race_started) {
		boost_juice += (0.05 * global.difficulty) * (1 - (boost_juice_penalty / 100)) * global.deltatime * 100;
	}
}
else {
	if (boost_juice > 0) {
		boost_juice -= 0.25 * global.deltatime * 100;
	}
	else {
		boost_active = false;
		boost_juice_penalty = clamp(boost_juice_penalty + 10, 0, 80);
		if (!is_player) {
			boosting = false;
		}
	}
}

//check alive
if (hp <= 0) {
	// respawning
	// respawning process:
	// when hp <= 0
	// on_death is called
	// changes player to a person rolling, this causes constant deceleration until stopping (begin step)
	// once stopped, change state to standing up
	// calls on_stand_up, create a bike object
	// walks to bike object
	// once close, change animation to get on
	// once get on is done, turn off is_respawning and restore health
	// go to idle state
	on_death();
	if (velocity <= 0) {
		if (crash_timer.to_stand <= 0 and crash_timer.to_get_on <= 0) {
			crash_timer.to_stand = crash_timer.TIME_TO_STAND;
		}
	}
}
else {
	// health regen
	hp_regen_delay += global.deltatime;
	if (hp_regen_delay >= 0) {
		hp = clamp(hp+(5 / global.difficulty), 0, max_hp);
		hp_regen_delay = -1;
	}
}

if (obj_controller.alarm[0] < 0) {
	if (is_nan(x) || is_nan(y)) {
		print("derp");
		acceleration = 0;
		velocity = 0;
		turn_rate = 0;
		z = 0;
	
		drive_force = 0;
		hp = 0;
	}
}


counter = (counter + 1) % 1000;