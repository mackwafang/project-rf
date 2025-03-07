
if (global.game_state_paused) {exit;}

on_road_index = set_on_road();
on_road = is_on_road(x,y,last_road_index);

var vel = (velocity) * global.deltatime;
var dist_to_median = point_distance(x,y,vec_to_road.x,vec_to_road.y);

// -1 left, 1 right
var side_from_median = dsin(angle_difference(point_direction(x,y,vec_to_road.x,vec_to_road.y), on_road_index.direction));


// move car in direction
if (!is_respawning) {
	turn_rate += -turn_rate * 0.05;
	turn_rate = clamp(turn_rate, -10, 10);
	
	// change bike sprite at at certain behavior and direction to camera
	if (vehicle_type == VEHICLE_TYPE.BIKE) {
		if (velocity <= 0 || !global.race_started) {
			// stopped sprite
			vehicle_detail_index = spr_bike_3d_detail_2;
			vehicle_detail_subimage = 0;
		}
		else {
			// turning sprite
			vehicle_detail_index = spr_bike_3d_detail_2_turn;
			vehicle_detail_subimage = round(min(sprite_get_number(vehicle_detail_index), (abs(turn_rate) / 4 / global.deltatime) / 100 * sprite_get_number(vehicle_detail_index)));
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
            var can_perform_wheelie = accelerating and velocity <= 200 * global.difficulty and gear == 1;
			if (ai_behavior.part_of_race) {
				if (can_perform_wheelie) {
					vehicle_detail_index = spr_bike_3d_detail_2_start;
				}
			}
			
			if (abs(_d) > 0.25) {
				if (velocity > 0) {
					// angled sprite
					vehicle_detail_index = spr_bike_3d_detail_2_side;
                    if (can_perform_wheelie) {
                        vehicle_detail_index = spr_bike_3d_detail_2_start;
                        vehicle_detail_subimage = 1;
                    }
				}
				else {
					// angled stopped sprite
					vehicle_detail_index = spr_bike_3d_detail_2;
					vehicle_detail_subimage = 1;
				}
				
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

// invisible walls to attempt to revent stuck behind buildings
var side_limit = ((side_from_median == -1 ? on_road_index.get_lanes_left() : on_road_index.get_lanes_right())+4); // building limits
switch(on_road_index.zone) {
	case ZONE.FOREST:
		side_limit = 6;
		break;
	case ZONE.SUBURBAN:
		side_limit = 6;
		break;
	case ZONE.DESERT:
		side_limit = 6;
		break;
	case ZONE.RIVER:
		side_limit = 6;
		break;
    case ZONE.MOUNTAIN: case ZONE.TUNNEL:
        side_limit = ((side_from_median == -1 ? on_road_index.get_lanes_left() : on_road_index.get_lanes_right())+1);
        break;
}
side_limit -= 0.1;

var move_x = 0, move_y = 0;
if (dist_to_median <= (side_limit * on_road_index.lane_width)) {
	// move freely
	move_x += dcos(direction) * vel;
	move_y -= dsin(direction) * vel;
}
else {
	// push back
	var dir_to_median = point_direction(x, y, vec_to_road.x,vec_to_road.y);
	move_x += dcos(dir_to_median) * vel / 2;
	move_y -= dsin(dir_to_median) * vel / 2;
}

move_and_collide(move_x, move_y, obj_railing);

if (!crash_timer.is_walking) {
	image_angle = direction;
}
else {
	image_angle = bike_obj.image_angle;
}

velocity += acceleration * global.deltatime;// * gear_ratio[gear-1];
hp = clamp(hp, 0, max_hp);