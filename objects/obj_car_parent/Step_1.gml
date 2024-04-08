nav_road = nearest_road;//find_nearest_road(x + lengthdir_x(128, image_angle), y + lengthdir_y(128, image_angle), last_road_index);
nav_road ??= obj_road_generator.road_list[last_road_index];
on_road_index = set_on_road();

if (global.game_state_paused) {exit;}
var vel = (velocity) * global.deltatime / global.WORLD_TO_REAL_SCALE;
var vec_to_road = point_to_line(
	new Point(on_road_index.x, on_road_index.y),
	new Point(on_road_index.next_road.x, on_road_index.next_road.y),
	new Point(x+lengthdir_x(vel, direction), y+lengthdir_y(vel, direction))
);
if (_z_restrict) {
	var lerp_value = point_distance(on_road_index.x, on_road_index.y, vec_to_road.x, vec_to_road.y) / on_road_index.length;
	zlerp = lerp(on_road_index.z, on_road_index.next_road.z, lerp_value);
	
	vertical_on_road = (z+zspeed <= zlerp);
	
	if (on_road_index.zone == ZONE.RIVER) {
		if (!on_road) {
			zlerp += on_road_index.sea_level;
		}
		
		vertical_on_road = on_road;
		if (on_road && z < zlerp - min(20, abs(on_road_index.z - on_road_index.next_road.z)*2)) {
			vertical_on_road = false;
			on_road = false;
		}
	}
	
	if (vertical_on_road) {
		drive_force *= cos(on_road_index.elevation) + (on_road_index.elevation < 0 ? 2 : 0);
		z = zlerp;
		if (zspeed > global.gravity_3d) {
			zspeed *= -1/3;
			turn_rate *= 3;
		}
	}
	else {
		// FREE FALLING
		zspeed -= (global.gravity_3d) * global.deltatime;
	}
	z += zspeed;
	z = clamp(z, zlerp, 500);
	// z -= sin(degtorad(nearest_road.next_road.elevation)) * velocity / 60;
	if (z < on_road_index.next_road.z - 100) {hp = 0;}
}

// move car in direction
if (!is_respawning) {
	turn_rate += -turn_rate * (is_player ? 0.1 : (turning ? 0.05 : 0));
	turn_rate = clamp(turn_rate, -6, 6);
	
	if (vehicle_type == VEHICLE_TYPE.BIKE) {
		if (velocity <= 0 || !global.race_started) {
			// stopped sprite
			vehicle_detail_index = spr_bike_3d_detail_2;
			vehicle_detail_subimage = 0;
		}
		else {
			vehicle_detail_index = spr_bike_3d_detail_2_turn;
			vehicle_detail_subimage = round(min(sprite_get_number(vehicle_detail_index), (abs(turn_rate) / 4 / global.deltatime) / 100 * sprite_get_number(vehicle_detail_index)));
		}
		image_xscale = -(turn_rate == 0 ? 1 : sign(turn_rate));
		if (!is_completed) {
			var length_to_cam = point_distance(obj_controller.main_camera_target.x, obj_controller.main_camera_target.y, x, y);
			var a = new Point(
				lengthdir_x(1, direction + 90),
				lengthdir_y(1, direction + 90)
			);
			var b = new Point(
				(obj_controller.main_camera_target.x - x) / length_to_cam,
				(obj_controller.main_camera_target.y - y) / length_to_cam
			);
			var _d = dot_product(a.x, a.y, b.x, b.y);
		
			if (velocity > 0 && abs(_d) > 0.25) {
				// angled sprite
				vehicle_detail_index = spr_bike_3d_detail_2;
				vehicle_detail_subimage = 1;
				image_xscale = -(_d == 0 ? 1 : sign(_d));
			}
		}
		else {
			if (ai_behavior.part_of_race && completed_race_rank <= 3) {
				vehicle_detail_index = spr_bike_3d_detail_2_victory;
				vehicle_detail_subimage = (round(global.race_timer * 10) div 3) % 2;
			}
		}
	}
	
	if (vertical_on_road) {
		direction += turn_rate;
	}
}
else {
	if (velocity > 400) {
		vehicle_detail_index = spr_bike_3d_detail_2_crashed_roll;
		vehicle_detail_subimage = (counter div 20) % 6;
	}
	else {
		vehicle_detail_index = spr_bike_3d_detail_2_crashed;
	}
}
x += dcos(direction) * vel;
y -= dsin(direction) * vel;
image_angle = direction;

velocity += acceleration * global.deltatime;// * gear_ratio[gear-1];
hp = clamp(hp, 0, max_hp);