if (global.game_state_paused) {exit;}


// road fidning
var nav_road = on_road_index; // this road is used to track which direction to drive
var nodes_look_ahead = 0;
if (ai_behavior.part_of_race) {
	if (global.level >= 3) {
		nodes_look_ahead = 2;
	}
	if (!on_road) {
		nodes_look_ahead = 0;
	}
}

// tis road is used for throttle/break control
var look_ahead_road = obj_road_generator.road_list[max(0, on_road_index.get_id() + (ai_behavior.reversed_direction ? -nodes_look_ahead: nodes_look_ahead))];
//vec_to_road = point_to_line(
//	on_road_index.x, on_road_index.y,
//	on_road_index.next_road.x, on_road_index.next_road.y,
//	x, y
//);

dist_along_road = on_road_index.length_to_point + point_distance(on_road_index.x, on_road_index.y, vec_to_road.x, vec_to_road.y);

// set desired vector along road based on desired lane
if (!is_player) {
    vec_to_road.x += lengthdir_x(((ai_behavior.desired_lane + 0.5) * on_road_index.lane_width), on_road_index.direction-90);
    vec_to_road.y += lengthdir_y(((ai_behavior.desired_lane + 0.5) * on_road_index.lane_width), on_road_index.direction-90);
}
dist_to_lane = point_distance(x,y,vec_to_road.x,vec_to_road.y);
//if (dist_to_lane > 1024) {
//	hp = 0;
//}

if (can_move) {

    // getting new direction to change to
	var angle_diff = angle_difference(nav_road.direction, direction);
	var look_ahead_angle_diff = angle_difference(look_ahead_road.direction, direction);
	if (ai_behavior.reversed_direction) {
		angle_diff = angle_difference(nav_road.direction-180, direction);
		look_ahead_angle_diff = angle_difference(look_ahead_road.direction-180, direction);
	}

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
		
		if (on_road) {
	 		if (ai_behavior.part_of_race) {
				if (abs(look_ahead_angle_diff) > 20) {
					accelerating = false;
				}
				
				braking = (abs(look_ahead_angle_diff) > 40);
			}
		}
	}
	
    // engine power to accelerate
	if (accelerating) {
		if (is_player and turning == 0) {
			engine.engine_power += 0.1;
			if (global.GAMEPLAY_TURN_GUIDE) {
				turn_rate += (angle_diff / 720); // moving along curved road
			}
		}
	}
	else {
		engine.engine_power -= 0.1;
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
			
        if (ai_behavior.part_of_race) {
		    engine.engine_power = (is_completed ? 0 : nav_road.get_ideal_throttle() * 1.01);
        }
        else {
            engine.engine_power = 1;
        }
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
				turn_rate += clamp(sign(side) / 80, -1, 1);
			}
			else {
				// car turning on curved road and moving to its desired lane
				var tr = (angle_diff / 8) * turn_adjustments; // moving along curved road
				
				// moving go desired lane
				if (on_road_index.zone != ZONE.RIVER) {
					if (dist_to_lane > on_road_index.lane_width / 2) {
						tr += sign(side) / 5;
					}
				}
				turn_rate += (tr / 10);
				
				// braking = (abs(tr) > 1) | ((nav_road.get_ideal_throttle() < 0.25) && (abs(angle_diff) > 15));
			}
			//if (ai_behavior.part_of_race) {
			//	turn_rate *= max(1 - (velocity / max_velocity), (velocity / max_velocity)) * 1.2;
			//}
			
			if (abs(angle_diff) > 90) {
				engine.engine_power *= (1 - abs(angle_diff) / 90);
			}
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
			turn_rate -= 6 * global.deltatime;
		}
		else if (turning & 2 == 0) {
			// checking right turn
			turn_rate += 6 * global.deltatime;
		}
	}
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
            dust_part.direction = direction;
            dust_part.speed = -(velocity) * global.deltatime;
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
else {
	braking = true;
	accelerating = false;
	boosting = false;
	boost_active = false;
}

// calculate engine stuff for acceleration
var engine_to_wheel_ratio = engine.gear_ratio[engine.gear-1] * engine.diff_ratio;
var engine_torque_max = (torque_lookup(engine.rpm) + (300 * sqr(global.difficulty-1)));
// var engine_torque_max = ((horsepower / rpm * 5252) * 8 * global.difficulty);
var engine_torque = engine_torque_max * (boost_active ? 3 : engine.engine_power);
var drive_torque = engine_torque * engine_to_wheel_ratio * engine.transfer_eff;
	
var f_drag = -c_drag * velocity;
var f_rr = -c_rr * velocity;
var f_surface = -mass * global.gravity_3d * ((on_road) ? 0.2 : 5) * (vertical_on_road ? 1 : 0);
if (biker_state == BIKER_STATE.ROLLING) {
	f_surface = -mass * global.gravity_3d * (vertical_on_road ? 10 : 0);
}
if (vertical_on_road) {
    f_surface *= 1 + (dsin(on_road_index.elevation) * 10);
	f_surface = min(drive_torque / wheel_radius, f_surface);
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
	engine.rpm = (wheel_rotation_rate * engine_to_wheel_ratio * 60 / (2 * pi));
}
velocity = clamp(velocity, 0, max_velocity);
velocity = clamp(velocity, 0, speed_limit / ((global.gameplay_measure_metrics == MEASURE.METRIC ? 1 : KMH_TO_MPH) * global.WORLD_TO_REAL_SCALE / 10));

// burn hp when rpm is very high for long amount of time
// band-aid fix for down-gear exploit
if (engine.rpm > 9500) {
	engine.max_rpm_burn_penalty += global.deltatime;
	if (engine.max_rpm_burn_penalty >= 1) {
		hp -= engine.max_rpm_burn_penalty * 20 * global.deltatime;
	}
}
else {
	engine.max_rpm_burn_penalty = 0;
}

if (engine.rpm >= engine.rpm_max) {engine.rpm = engine.rpm_max;}

auto_gear_shift(); // auto gear shift
engine.engine_power = clamp(engine.engine_power, 0, 1);
engine.gear_shift_wait = clamp(engine.gear_shift_wait-1, 0, 120);

// play engine
var engine_sound_pitch = ((engine.rpm / engine.rpm_max)+1.0);// - (gear / 12);
if (engine_sound_interval == 0) {
	audio_emitter_pitch(engine_sound_emitter, engine_sound_pitch);
	audio_emitter_position(engine_sound_emitter, x, y, z);
	audio_play_sound_on(engine_sound_emitter, (boost_active ? snd_boost : snd_car), false, 2);
}
//audio_emitter_velocity(engine_sound_emitter, cos(direction), sin(direction), 0);
engine_sound_interval = (engine_sound_interval + 1) % (engine.rpm < 2000 ? 16 : 8);


// remove non-participating cars when too far away
if (abs(obj_controller.main_camera_target.dist_along_road - dist_along_road) > 5000) {
    if (!ai_behavior.part_of_race) {
        //print($"object {id} (part_of_race: {ai_behavior.part_of_race}, reverse: {ai_behavior.reversed_direction}) destroyed. Out of view. {obj_controller.main_camera_target.dist_along_road} {dist_along_road} {abs(obj_controller.main_camera_target.dist_along_road-dist_along_road)} > 5000");
        instance_destroy();
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
if (hp <= 0 and biker_state == BIKER_STATE.DRIVING) {
	// respawning
	on_death();
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