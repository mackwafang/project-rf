
if (global.game_state_paused) {exit;}

on_road_index = set_on_road();
on_road = is_on_road(x,y,last_road_index);

var vel = (velocity) * global.deltatime;
var dist_to_median = point_distance(x,y,vec_to_road.x,vec_to_road.y);

// -1 left, 1 right
side_from_median = dsin(angle_difference(point_direction(x,y,vec_to_road.x,vec_to_road.y), on_road_index.direction));


/************ vertical height ************/
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
    var pos_relative_to_road_norm = point_distance_3d(road.x, road.y, road.z, vec_to_road_3d.x, vec_to_road_3d.y, vec_to_road_3d.z) / road.length; // vehicle's position relative distance from road to next road, normalized
    var lerp_value = pos_relative_to_road_norm
    
    var lerp_left = lerp_3d(
        [road_col_x[0], road_col_y[0], road_col_z[0]], 
        [road_col_x[1], road_col_y[1], road_col_z[1]], 
        lerp_value
    );
    var lerp_right = lerp_3d(
        [road_col_x[3], road_col_y[3], road_col_z[3]], 
        [road_col_x[2], road_col_y[2], road_col_z[2]], 
        lerp_value
    );
    zlerp = lerp_3d(lerp_left, lerp_right, pos_relative_to_road_norm)[2];
    
    vertical_on_road = (z+zspeed <= zlerp);
    
    switch(road.zone) {
        case ZONE.RIVER:
            if (!on_road) {
                zlerp -= road.sea_level;
            }
            break;
        case ZONE.CITY: case ZONE.TOWN: case ZONE.TUNNEL:
            if (dist_to_lane div road.lane_width == road.get_lanes_left() && side_from_median == -1) {
                zlerp += 5;
            }
            if (dist_to_lane div road.lane_width == road.get_lanes_right() && side_from_median == 1) {
                zlerp += 5;
            }
            break;
    }
    
    if (vertical_on_road) {
        zspeed += -sin(on_road_index.elevation) * global.deltatime;
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
                //turn_rate *= 3;
            }
        }
    }
    z = clamp(z+zspeed, zlerp, zlerp + 500);
    
	// kill zone
    if (z < on_road_index.z - 400) {
        hp = 0;
        print($"object {id} (part_of_race: {ai_behavior.part_of_race}, reverse: {ai_behavior.reversed_direction}) destroyed. Out of z-bound");
    }
}

if (!is_respawning) {
    // reset turning
	turn_rate += -turn_rate * 0.05;
	turn_rate = clamp(turn_rate, -10, 10);
	
	if (z - zlerp < 1) {
		direction += turn_rate * 75 * global.deltatime;
	}
	biker_state = BIKER_STATE.DRIVING;
}

// invisible walls to attempt to revent stuck behind buildings
var side_default = 8;
var side_limit = ((side_from_median == -1 ? on_road_index.get_lanes_left() : on_road_index.get_lanes_right())+4); // building limits
switch(on_road_index.zone) {
    case ZONE.MOUNTAIN: case ZONE.TUNNEL:
        side_limit = ((side_from_median == -1 ? on_road_index.get_lanes_left() : on_road_index.get_lanes_right())+1);
        break;
    default:
        side_limit = side_default;
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

if (!crash_timer.is_walking) {
	image_angle = direction;
}
else {
	image_angle = bike_obj.image_angle;
}

velocity += acceleration * global.deltatime;// * gear_ratio[gear-1];
hp = clamp(hp, 0, max_hp);

// swapping sprites based on state
switch(vehicle_type) {
	case VEHICLE_TYPE.BIKE:
		switch(biker_state) {
			case BIKER_STATE.DRIVING:
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
				break;
			
			case BIKER_STATE.ROLLING:
				if (velocity > 400) {
					vehicle_detail_index = spr_bike_3d_detail_2_crashed_roll;
					vehicle_detail_subimage = (counter div 20) % 6;
				}
				else {
					vehicle_detail_index = spr_bike_3d_detail_2_crashed;
					
					if (velocity <= 0) {
						crash_timer.to_stand = crash_timer.TIME_TO_STAND;
						biker_state = BIKER_STATE.GETUP;
					}
				}
			
				break;
			
			case BIKER_STATE.GETUP:
				if (crash_timer.to_stand > 0) {
					vehicle_detail_index = spr_bike_3d_detail_2_stand;
					vehicle_detail_subimage = min(max(0, round(crash_timer.to_stand / crash_timer.TIME_TO_STAND * 4)), 4);
					
					crash_timer.to_stand -= global.deltatime;
					if (crash_timer.to_stand <= 0) {
						crash_timer.is_walking = true;
						on_stand_up();
					}
				}
				break;
			
			case BIKER_STATE.WALKING:
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
							var b = new Point(
								(obj_controller.main_camera_pos.x - x) / length_to_cam,
								(obj_controller.main_camera_pos.y - y) / length_to_cam
							);
							var _d = -dot_product(a.x, a.y, b.x, b.y);
							
							if (_d > 0.75) {
								// forward
								vehicle_detail_index = spr_bike_3d_detail_2_walk_up;
							}
							else if (_d < -0.75) {
								// towards
								vehicle_detail_index = spr_bike_3d_detail_2_walk_down;
							}
							else {
								//side
								vehicle_detail_index = spr_bike_3d_detail_2_walk_side;
							}
							
							vehicle_detail_subimage = (counter div 10) % 6
							image_xscale = sign(angle_difference(cam_dir, direction));
						}
					}
					else {
						biker_state = BIKER_STATE.GETON;
					}
				}
				break;
			
			case BIKER_STATE.GETON:
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
			
			
				if (crash_timer.to_get_on > 0) {
					crash_timer.to_get_on -= global.deltatime;
					if (crash_timer.to_get_on <= 0) {
						crash_timer.is_walking = false;
						on_respawn();
					}
				}
				break;
			
			case BIKER_STATE.WIN:
				if (ai_behavior.part_of_race && completed_race_rank <= 3) {
					vehicle_detail_index = spr_bike_3d_detail_2_victory;
					vehicle_detail_subimage = (round(global.race_timer * 10) div 3) % 2;
				}
				break;
		}
		break;
	
}

// moving and handling smooth collision handling
var col_obj = move_and_collide(move_x, move_y, [obj_railing, obj_building]);
for (var i = 0; i< array_length(col_obj); i++) {
    var obj = col_obj[i];
    switch(obj.object_index) {
        case obj_building:
            var dist_to_building = max(1, point_distance(x, y, other.x, other.y));
            var a = new Point(
            	lengthdir_x(1, direction),
            	lengthdir_y(1, direction)
            );
            var b = new Point(
            	(other.x - x) / dist_to_building,
            	(other.y - y) / dist_to_building
            );
            var _d = clamp(abs(dot_product(b.x, b.y, a.x, a.y)), 0, 1);
            hp -= max_hp * (1-_d);
            turn_rate *= _d * 2;
            velocity *= _d;
            // print(_d);
            //var dist_to_center = sqrt(sqr(other.building_width / 2) + sqr(other.building_height / 2));
            //var other_center_x = other.x + lengthdir_x(dist_to_center, other.direction);
            //var other_center_y = other.y + lengthdir_y(dist_to_center, other.direction);
            //var push_dir = point_direction(other_center_x, other_center_y, x, y);
            // move_and_collide(dcos(push_dir), dsin(push_dir), obj_building);
            // move_outside_all(point_direction(x, y, other_center_x, other_center_y), velocity);
        default:
            event_perform(ev_collision, obj);
    }
}