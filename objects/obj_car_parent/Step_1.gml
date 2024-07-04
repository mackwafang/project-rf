
on_road_index = set_on_road();

if (global.game_state_paused) {exit;}
var vel = (velocity) * global.deltatime / global.WORLD_TO_REAL_SCALE;
//var vec_to_road = point_to_line(
//	new Point(on_road_index.x, on_road_index.y),
//	new Point(on_road_index.next_road.x, on_road_index.next_road.y),
//	new Point(x, y)
//);
var vec_to_road = point_to_line_3d(
	new Point3D(on_road_index.x, on_road_index.y, on_road_index.z),
	new Point3D(on_road_index.next_road.x, on_road_index.next_road.y, on_road_index.next_road.z),
	new Point3D(x, y, z)
);

if (_z_restrict) {
	var road = on_road_index;
	//var lerp_value = point_distance(road.x, road.y, vec_to_road.x, vec_to_road.y) / road.length;
	//zlerp = lerp(road.z, road.next_road.z, lerp_value);
	if (is_undefined(on_road_index)) {
		exit;
	}
	
	var road_col_x = road.collision_points[0];
	var road_col_y = road.collision_points[1];
	var road_col_z = road.collision_points[2];
	var lerp_value = point_distance_3d(road.x, road.y, road.z, vec_to_road.x, vec_to_road.y, vec_to_road.z) / road.length;
	var lerp_left = lerp_3d([road_col_x[0], road_col_y[0], road_col_z[0]], [road_col_x[1], road_col_y[1], road_col_z[1]], lerp_value);
	var lerp_right = lerp_3d([road_col_x[3], road_col_y[3], road_col_z[3]], [road_col_x[2], road_col_y[2], road_col_z[2]], lerp_value);
	zlerp = lerp_3d(lerp_left, lerp_right, point_distance_3d(x, y, z, vec_to_road.x, vec_to_road.y, vec_to_road.z)  / road.length)[2];
	
	vertical_on_road = (z+zspeed <= zlerp);
	
	if (on_road_index.zone == ZONE.RIVER) {
		if (!on_road) {
			zlerp += on_road_index.sea_level;
		}
		
		// vertical_on_road = on_road;
		//if (on_road && z < zlerp - min(20, abs(on_road_index.z - on_road_index.next_road.z)*2)) {
		//	vertical_on_road = false;
		//	on_road = false;
		//}
	}
	
	if (vertical_on_road) {
		drive_force *= cos(on_road_index.elevation) + (on_road_index.elevation < 0 ? 2 : 0);
		if (!on_road && on_road_index.zone != ZONE.RIVER) {
			zspeed += (global.gravity_3d) * global.deltatime / 2;
		}
	}
	else {
		// FREE FALLING
		zspeed -= (global.gravity_3d) * 1 * global.deltatime;
		if (z+zspeed <= zlerp) {
			if (zspeed > global.gravity_3d) {
				zspeed *= -1/3;
				turn_rate *= 3;
			}
		}
	}
	z += zspeed;
	if (z <= zlerp) {
		z = zlerp;
	}
	// z = clamp(z, zlerp, zlerp+500);
	// z -= sin(degtorad(nearest_road.next_road.elevation)) * velocity / 60;
	if (z < on_road_index.z - 400) {
		hp = 0;
		print($"object {id} (part_of_race: {ai_behavior.part_of_race}, reverse: {ai_behavior.reversed_direction}) destroyed. Out of z-bound");
	}
	
	//if (ai_behavior.reversed_direction) {
	//	print($"{lerp_value} {lerp_left[2]} {lerp_right[2]} {zlerp} {z} {on_road_index.z} {instance_number(obj_car)}");
	//}
}

// move car in direction
if (!is_respawning) {
	turn_rate += -turn_rate * 0.05;
	turn_rate = clamp(turn_rate, -15, 15);
	
	if (vehicle_type == VEHICLE_TYPE.BIKE) {
		if (velocity <= 0 || !global.race_started) {
			// stopped sprite
			vehicle_detail_index = spr_bike_3d_detail_2;
			vehicle_detail_subimage = 0;
		}
		else {
			// turning sprite
			vehicle_detail_index = spr_bike_3d_detail_2_turn;
			vehicle_detail_subimage = round(min(sprite_get_number(vehicle_detail_index), (abs(turn_rate) / 5 / global.deltatime) / 100 * sprite_get_number(vehicle_detail_index)));
		}
		image_xscale = -(turn_rate == 0 ? 1 : sign(turn_rate));
		if (!is_completed) {
			var length_to_cam = point_distance(obj_controller.main_camera_pos.x, obj_controller.main_camera_pos.y, x, y);
			var a = new Point(
				lengthdir_x(1, direction + 90),
				lengthdir_y(1, direction + 90)
			);
			
			var b = new Point(
				(obj_controller.main_camera_pos.x - x) / length_to_cam,
				(obj_controller.main_camera_pos.y - y) / length_to_cam
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
	
	if (z - zlerp < 1) {
		direction += turn_rate * 75 * global.deltatime;
	}
}
else {
	if (velocity > 400) {
		vehicle_detail_index = spr_bike_3d_detail_2_crashed_roll;
		vehicle_detail_subimage = (counter div 20) % 6;
	}
	else {
		if (crash_timer.to_stand > 0) {
			vehicle_detail_index = spr_bike_3d_detail_2_stand;
			vehicle_detail_subimage = min(max(0, round(crash_timer.to_stand / crash_timer.TIME_TO_STAND * 4)), 4);
		}
		else {
			vehicle_detail_index = spr_bike_3d_detail_2_crashed;
		}
	}
}
x += dcos(direction) * vel;
y -= dsin(direction) * vel;

if (!crash_timer.is_walking) {
	image_angle = direction;
}
else {
	image_angle = bike_obj.image_angle;
}

velocity += acceleration * global.deltatime;// * gear_ratio[gear-1];
hp = clamp(hp, 0, max_hp);