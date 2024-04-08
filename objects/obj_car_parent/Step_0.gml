// road fidning
var next_road = obj_road_generator.road_list[max(0, nav_road.get_id() + (ai_behavior.reversed_direction ? -6 : 6))];
var vec_to_road = new Vec2(0, 0);
if (nav_road._id != next_road._id) {
	vec_to_road = point_to_line(
		new Point(nav_road.x, nav_road.y),
		new Point(next_road.x, next_road.y),
		new Point(x, y)
	);
}
dist_along_road = on_road_index.length_to_point + point_distance(on_road_index.x, on_road_index.y, vec_to_road.x, vec_to_road.y);
vec_to_road.x += lengthdir_x(((ai_behavior.desired_lane + 0.5) * on_road_index.lane_width), on_road_index.direction-90);
vec_to_road.y += lengthdir_y(((ai_behavior.desired_lane + 0.5) * on_road_index.lane_width), on_road_index.direction-90);
var dist_to_road = point_distance(x,y,vec_to_road.x,vec_to_road.y);
//if (dist_to_road > 1024) {
//	hp = 0;
//}
if (global.game_state_paused) {exit;}

if (can_move) {
	// player moving
	if (is_player) {
		if (!is_completed) {
			accelerating = keyboard_check(global.player_input.accelerate);
			braking = keyboard_check(global.player_input.brake);
			boosting = keyboard_check_pressed(global.player_input.boost);
		}
		turning = (keyboard_check(global.player_input.turn.right) << 1) | (keyboard_check(global.player_input.turn.left));
		if (turning != 0) {
			// checking turning
			if (turning & 1 == 0) {
				// checking left turn
				turn_rate -= 10 * global.deltatime;
			}
			else if (turning & 2 == 0) {
				// checking right turn
				turn_rate += 10 * global.deltatime;
			}
		}
	}
	else {
		accelerating = !is_completed;
	}

	if (accelerating) {
		var angle_diff = angle_difference(nav_road.direction, direction);
		if (ai_behavior.reversed_direction) {
			angle_diff = angle_difference(direction, nav_road.direction)
		}
		
		if (is_player) {
			engine_power += 0.1;
			if (global.GAMEPLAY_TURN_GUIDE) {
				turn_rate += (angle_diff / 360); // moving along curved road
			}
		}
		else {
			#region Non-Player Car Movement
			if (ai_behavior.desired_lane > (ai_behavior.reversed_direction ? next_road.get_lanes_left() : next_road.get_lanes_right())-1 || ai_behavior.desired_lane < 0) {
				// desired lane doesn't exists, pick a new one
				ai_behavior.change_lane(nav_road);
			}
			engine_power = nav_road.get_ideal_throttle();
			if (nav_road.get_ideal_throttle() < 0.6) {
				engine_power = 0;
			}
			var side = -(angle_difference(image_angle, point_direction(x, y, vec_to_road.x, vec_to_road.y)));
			if (ai_behavior.reversed_direction) {
				side = -(angle_difference(point_direction(x, y, vec_to_road.x, vec_to_road.y), image_angle));
			}
			var turn_adjustments = 1;
		
			if (!on_road) {
				// off road, trying to get back on it
				// find the nearest road
				//var side = angle_difference(image_angle, point_direction(x,y,road.x,road.y));
				turn_rate = side / 300;
			}
			else {
				// car turning on curved road and moving to its desired lane
				var tr = (angle_diff / 15) * turn_adjustments; // moving along curved road
				
				// moving go desired lane
				if (dist_to_road > 32) {
					tr += (sign(side) / 10);
				}
				
				turn_rate = tr;
				
				braking = (abs(tr) > 1) | ((nav_road.get_ideal_throttle() < 0.25) && (abs(angle_diff) > 15));
			}
			
			// checking other cars
			var look_ahead_threshold = 512;
			var look_ahead_angle = 8;
			var car_look_ahead = instance_exists(collision_line(x, y, x+lengthdir_x(look_ahead_threshold, direction), y+lengthdir_y(look_ahead_threshold, direction), obj_car_parent, false, true));
			var car_look_left = instance_exists(collision_line(x, y, x+lengthdir_x(look_ahead_threshold, image_angle+look_ahead_angle), y+lengthdir_y(look_ahead_threshold, image_angle+look_ahead_angle), obj_car_parent, false, true));
			var car_look_right = instance_exists(collision_line(x, y, x+lengthdir_x(look_ahead_threshold, image_angle-look_ahead_angle), y+lengthdir_y(look_ahead_threshold, image_angle-look_ahead_angle), obj_car_parent, false, true));
			var rail_look_left = instance_exists(collision_line(x, y, x+lengthdir_x(look_ahead_threshold, image_angle+look_ahead_angle), y+lengthdir_y(look_ahead_threshold, image_angle+look_ahead_angle), obj_railing, false, true));
			var rail_look_right = instance_exists(collision_line(x, y, x+lengthdir_x(look_ahead_threshold, image_angle-look_ahead_angle), y+lengthdir_y(look_ahead_threshold, image_angle-look_ahead_angle), obj_railing, false, true));
			var is_off_road_left = !is_on_road(x+lengthdir_x(look_ahead_threshold/4, image_angle+90), y+lengthdir_y(look_ahead_threshold/4, image_angle+90), last_road_index) ? 1 : 0;
			var is_off_road_right = !is_on_road(x+lengthdir_x(look_ahead_threshold/4, image_angle-90), y+lengthdir_y(look_ahead_threshold/4, image_angle-90), last_road_index) ? 1 : 0;
			
			var evade_turn_rate = 0.5;
			if (car_look_left ^ car_look_right) {
				if (car_look_left) {turn_rate -= evade_turn_rate;}
				if (car_look_right) {turn_rate += evade_turn_rate;}
			}
			else if (car_look_left & car_look_right) {
				acceleration = false;
			}
			
			if (rail_look_left) {turn_rate -= evade_turn_rate;}
			else if (rail_look_right) {turn_rate += evade_turn_rate;}
			
			if (!is_off_road_left | !is_off_road_right) {
				turn_rate += (-(is_off_road_left/10) + (is_off_road_right/10));
			}
			//if (ai_behavior.part_of_race) {
			//	turn_rate *= max(1 - (velocity / max_velocity), (velocity / max_velocity)) * 1.2;
			//}
			
			turning += (turn_rate < 0.1 ? 2 : (turn_rate > 0.1 ? 1 : 0));
			// enables boost
			if (boost_juice >= 100) {
				if (irandom(20) < global.difficulty) {
					boosting = true;
				}
			}
			#endregion
		}
	}
	else {
		engine_power -= 0.1;
	}

	if (keyboard_check_pressed(vk_up)) {gear_shift_up();}
	if (keyboard_check_pressed(vk_down)) {gear_shift_down();}
}

// "crash" on river
if (on_road_index.zone == ZONE.RIVER) {
	if (z <= on_road_index.sea_level) {
		hp = 0;
		velocity = 0;
		image_alpha = 0;
	}
}
// create dust particle
if (!on_road && vertical_on_road) {
	if (velocity > 100) {
		if (!on_road_index.zone == ZONE.CITY) {
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
var engine_torque_max = (torque_lookup(engine_rpm) + (200 * global.difficulty));
// var engine_torque_max = ((horsepower / engine_rpm * 5252) * 8 * global.difficulty);
var engine_torque = engine_torque_max * (boost_active ? 2 : engine_power);
var drive_torque = engine_torque * engine_to_wheel_ratio * transfer_eff;
	
var f_drag = -c_drag * velocity;
var f_rr = -c_rr * velocity;
var f_surface = -mass * global.gravity_3d * ((on_road) ? 0.2 : 10) * (vertical_on_road ? 1 : 0);
if (hp <= 0) {
	f_surface = -mass * global.gravity_3d * (vertical_on_road ? 10 : 0);
}
var f_brake = ((braking) ? -braking_power * 1000 : 0);
var f_turn = -abs(turn_rate) * mass * 3;
if (velocity <= 0) {
	f_brake = 0;
	f_surface = 0;
}
var f_incline = arcsin(on_road_index.elevation / on_road_index.length) * mass * global.gravity_3d;
	
drive_force = (drive_torque / wheel_radius) + f_drag + f_rr + f_brake + f_surface + f_turn + f_incline - push_vector.x;

push_vector.x = max(0, push_vector.x - abs(drive_force));
push_vector.y = max(0, push_vector.y * 0.95);

drive_torque = drive_force * wheel_radius;

if (vertical_on_road) {
	acceleration = (drive_torque / inertia);
	var wheel_rotation_rate = velocity * 100 / 3600 / wheel_radius;
	engine_rpm = (wheel_rotation_rate * engine_to_wheel_ratio * 60 / (2 * pi));
}
velocity = clamp(velocity, 0, max_velocity);

if (engine_rpm <= 500) {engine_rpm = 500;}
if (engine_rpm >= engine_rpm_max) {engine_rpm = engine_rpm_max;}

gear_shift(); // auto gear shift
engine_power = clamp(engine_power, 0, 1);
gear_shift_wait = clamp(gear_shift_wait-1, 0, 60);

// play engine audio
if (hp > 0) {
	var engine_sound_pitch = ((engine_rpm / engine_rpm_max)+1.0);// - (gear / 12);
	if (obj_controller.main_camera_target.id == id) {
		audio_listener_position(x, y, z);
	}
	if (engine_sound_interval == 0) {
		audio_play_sound_on(engine_sound_emitter, (boost_active ? snd_boost : snd_car), false, 1);
	}
	audio_emitter_pitch(engine_sound_emitter, engine_sound_pitch);
	audio_emitter_position(engine_sound_emitter, x, y, z);
	engine_sound_interval = (engine_sound_interval + 1) % (engine_rpm < 2000 ? 16 : 8);
}


// remove non-participating cars when too far away
if (abs(obj_controller.main_camera_target.dist_along_road - dist_along_road) > 4000) {
	if (!global.DEBUG_FREE_CAMERA) {
		if (!ai_behavior.part_of_race) {
			instance_destroy()
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
		boost_juice_penalty = clamp(boost_juice_penalty + 10, 0, 90);
		if (!is_player) {
			boosting = false;
		}
	}
}

//check alive
if (hp <= 0) {
	on_death();
	if (velocity <= 0) {
		if (alarm[2] <= 0) {
			alarm[2] = round(4 / global.deltatime);
		}
	}
}
else {
	// health regen
	hp_regen_delay += global.deltatime;
	if (hp_regen_delay >= 0) {
		hp = clamp(hp+(3 / global.difficulty), 0, max_hp);
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