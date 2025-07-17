function level_generator_setup() {
	// set up road node data
	var lane_change_duration = 10; //how many nodes until change to new lane
	var course_data = get_course_weights(global.gameplay_course);
	var lane_change_to = course_data.MIN_LANES; // change this side of road to this number of lanes
	var cur_lane_change_to = lane_change_to; // current lane change for transition
	var prev_lane_lane_to = lane_change_to; // previous lane change
	var lane_side_affected = ROAD_LANE_CHANGE_AFFECT.BOTH; // which side of the road changes 
	var cur_zone = course_data.STARTING_ZONE;
	var initial_river_seg = road_list[@ 0];//(cur_zone == ZONE.RIVER ? road_list[@ 0] : undefined);
	var building_color = make_color_hsv(irandom(255), choose(0, 192 + irandom(64)), 192 + irandom(64));
	for (var i = 0; i < array_length(road_list)-1; i++) {
		var road = road_list[@i];
		var next_road = road_list[@i+1];
		var prev_road = undefined;
		if (i > 0) {
			prev_road = road_list[@i-1];
		}
		
		// road changes lane count
		if (lane_change_duration == 0) {
			prev_lane_lane_to = lane_change_to;
			lane_side_affected = choose(ROAD_LANE_CHANGE_AFFECT.LEFT, ROAD_LANE_CHANGE_AFFECT.RIGHT, ROAD_LANE_CHANGE_AFFECT.BOTH);
			lane_change_duration = 30+irandom(10);
			lane_change_to = course_data.MIN_LANES+irandom(course_data.MAX_LANES-course_data.MIN_LANES);
			if (road.intersection and lane_side_affected == ROAD_LANE_CHANGE_AFFECT.LEFT) {
				lane_change_to = 0;
			}
			
			cur_zone = choose_weight(course_data.ZONES, course_data.WEIGTHS, 1)[0];
			
			// hard set zone to river is height map value at this grid is below certain value
			var grid_x = road.x div control_points_dist;
			var grid_y = road.y div control_points_dist;
			var grid_index = grid_x + (grid_y * grid_width);
			if (grid[| grid_index] < -0.15) {
				cur_zone = ZONE.RIVER;
			}
			
			switch(cur_zone) {
				case ZONE.RIVER:
					lane_change_to = 2+irandom(1);
					initial_river_seg = road_list[@ i+1];
					lane_change_duration = 15;
					break;
				case ZONE.CITY: case ZONE.TOWN:
					road.building_color = building_color;
					// lane_change_to = 2+irandom(1);
					building_color = make_color_hsv(irandom(255), choose(0, 128 + irandom_range(-64, 64)), 196 + irandom_range(-32, 32));
					break;
			}
		}
		
		if (road.zone != ZONE.TUNNEL) {
			switch(lane_side_affected) {
				case ROAD_LANE_CHANGE_AFFECT.LEFT:
					road.set_lanes_left(cur_lane_change_to);
					road.set_lanes_right(road_list[@i-1].get_lanes_right());
					break;
				case ROAD_LANE_CHANGE_AFFECT.RIGHT:
					road.set_lanes_left(road_list[@i-1].get_lanes_left());
					road.set_lanes_right(cur_lane_change_to);
					break;
				case ROAD_LANE_CHANGE_AFFECT.BOTH:
					road.set_lanes_left(cur_lane_change_to);
	                road.set_lanes_right(cur_lane_change_to);
					break;
			}
			lane_change_duration--;
		}
		
		// set up road data
		road.next_road = next_road;
		road.direction = point_direction(road.x, road.y, next_road.x, next_road.y);
		road.length = point_distance_3d(road.x, road.y, road.z, next_road.x, next_road.y, next_road.z);
		road.elevation = -darcsin((road.z - next_road.z) / road.length);
		road.beyond_range = [
			road_offset_list.left[i],
			road_offset_list.right[i],
		];
		if (i == array_length(road_list)-2) {
			next_road.beyond_range = [
				road_offset_list.left[array_length(road_list)-1],
				road_offset_list.right[array_length(road_list)-1],
			];
		}
		
		road.ideal_throttle = min(1, road.length / (control_points_dist / road_segments)) * (global.difficulty < 1.5 ? 0.9 : 1.05);
		if (i < 50) {
			road.ideal_throttle = 1;
		}
		road._id = i;
		road.lane_width = lane_width;
		road.zone = cur_zone;
		road.sea_level = road.z;
		road.building_color = building_color;
		
		next_road.length_to_point = road.length_to_point + road.length;
		track_length += road.length;
		if (!array_contains([ZONE.DESERT, ZONE.MOUNTAIN, ZONE.RIVER, ZONE.TUNNEL], road.zone) and global.gameplay_course != COURSES.HILL) {
			if (irandom(50) < 1) {
				road.intersection = true;
			}
		}
		
		// set extra shoulder z
		switch(road.zone) {
			case ZONE.CITY: case ZONE.TOWN: case ZONE.TUNNEL:
				if (i > 0) {
					road.shoulder_z[0] = 5;
					road.shoulder_z[1] = 5;
					if (road.intersection or road_list[@i-1].intersection) {
						road.shoulder_z[0] = 0;
						road.shoulder_z[1] = 0;
					}
				}
				break;
		}
		
		// set which side is mountain for mountain zone
		if (road.zone == ZONE.MOUNTAIN) {
			var mnt_side = random_get_seed() % 2;
			road.beyond_range[mnt_side].z += global.gameplay_zone_mountain_z;
			road.beyond_range[(mnt_side + 1) % 2].z -= global.gameplay_zone_mountain_z/3;
			
			if (random_get_seed() % 69420 == 0) {
				road.zone_feature |= (1 << (ZONE_FEATURE.MOUNTAIN_SIDE_LEFT-1));
				road.zone_feature |= (1 << (ZONE_FEATURE.MOUNTAIN_SIDE_RIGHT-1));
				
				road.beyond_range[0].z += global.gameplay_zone_mountain_z;
				road.beyond_range[1].z += global.gameplay_zone_mountain_z;
			}
			else {
				if (mnt_side == 0) {road.zone_feature |= (1 << (ZONE_FEATURE.MOUNTAIN_SIDE_LEFT-1));}
				if (mnt_side == 1) {road.zone_feature |= (1 << (ZONE_FEATURE.MOUNTAIN_SIDE_RIGHT-1));}
			}
	        
	        if (i > 30) {
	            if (prev_road.zone != ZONE.MOUNTAIN) {
	                // set the edge of off road area for segments that is near mountain to slowly increase to mountain z
	                for (var j = 1; j < 29; j++) {
	                    var r = road_list[i-j];
	                    r.beyond_range[mnt_side].z += (global.gameplay_zone_mountain_z / 30) * (30-j);
	                    r.beyond_range[(mnt_side + 1) % 2].z -= (global.gameplay_zone_mountain_z / 3 / 30) * (30-j);
	                }
	            }
	        }
		}
		
		// sea level height
		if (i > 0) {
			if (cur_zone == ZONE.RIVER) {
				if (road_list[@ i-1].zone != cur_zone) {
					road.sea_level = road.z - 200;
				}
				else {
					road.sea_level = min(road.z - 200, initial_river_seg.sea_level);
				}
			}
			else {
				if (road_list[@ i-1].zone == ZONE.RIVER) {
					road.sea_level = road_list[@ i-1].sea_level;
				}
			}
		}
		if (cur_lane_change_to != lane_change_to) {
			cur_lane_change_to += sign(lane_change_to - prev_lane_lane_to);
			road.transition_lane = true;
		}
		
		generation_progress.setup.current += 1;
	}
	
	// setup road collision regions
	for (var i = 0; i < array_length(road_list) - 1; i++) {
		var road = road_list[@ i];
		var next_road = road_list[@ i + 1];
		var lane_function = [road.get_lanes_left, road.get_lanes_right];
		var next_lane_function = [next_road.get_lanes_left, next_road.get_lanes_right];
		var left_lanes = road.get_lanes_left();
		var right_lanes = road.get_lanes_right();
		var next_left_lanes = next_road.get_lanes_left();
		var next_right_lanes = next_road.get_lanes_right();
		
		if (i == global.destination_road_index) {
			global.race_length = road.length_to_point;
		}
		
		var collision_points = [
			 [
				road.x+lengthdir_x(lane_width*(left_lanes + (road.shoulder[0] ? 1 : 0)) + beyond_shoulder_range, road.direction+90),
				next_road.x+lengthdir_x(lane_width*(next_left_lanes + (next_road.shoulder[0] ? 1 : 0)) + beyond_shoulder_range, next_road.direction+90),
				next_road.x+lengthdir_x(lane_width*(next_right_lanes + (next_road.shoulder[1] ? 1 : 0)) + beyond_shoulder_range, next_road.direction-90),
				road.x+lengthdir_x(lane_width*(right_lanes + (road.shoulder[1] ? 1 : 0)) + beyond_shoulder_range, road.direction-90),
			],
			[
				road.y+lengthdir_y(lane_width*(left_lanes + (road.shoulder[0] ? 1 : 0)) + beyond_shoulder_range, road.direction+90),
				next_road.y+lengthdir_y(lane_width*(next_left_lanes + (next_road.shoulder[0] ? 1 : 0)) + beyond_shoulder_range, next_road.direction+90),
				next_road.y+lengthdir_y(lane_width*(next_right_lanes + (next_road.shoulder[1] ? 1 : 0)) + beyond_shoulder_range, next_road.direction-90),
				road.y+lengthdir_y(lane_width*(right_lanes + (road.shoulder[1] ? 1 : 0)) + beyond_shoulder_range, road.direction-90),
			],
			[
				road.z,
				next_road.z,
				next_road.z,
				road.z,
			]
		];
		road.collision_points = collision_points;
		generation_progress.initial.current += 1;
	}
}