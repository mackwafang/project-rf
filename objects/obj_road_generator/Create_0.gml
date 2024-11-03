randomize();
// random_set_seed(0);
depth = 1000;

// primary_count = 80 * global.difficulty;
road_segments = 10;
control_points = [];
control_points_offset = {
	left: [],
	right: [],
}
control_points_dist = 2048;
lane_width = 80;
track_length = 0;
beyond_shoulder_range = 4000;
tunnel_height = 150;
current_cp = 0; // current control point that is visible

var t = current_time;

// initialize control points using path finding via a-star
grid_width = 270;//round(24 * sqr(global.difficulty * 1.5));
grid_height = 270;//round(24 * sqr(global.difficulty * 1.5));
grid = ds_list_create();
// intialize random weights for grids
for (var i = 0; i < grid_height*grid_width; i++) {ds_list_add(grid, 0);}

control_path = [];

// generating level
var course_data = get_course_weights(global.GAMEPLAY_COURSE);
var curve_modifier = 0.4;
switch (global.GAMEPLAY_COURSE) {
	case COURSES.MOUNTAIN:
		curve_modifier = 1;
		break;
	case COURSES.CITY:
		curve_modifier = 0.5;
		break;
	case COURSES.DESERT:
		curve_modifier = 0.1;
		break;
}
while (array_length(control_path) == 0) {
	print("Creating grid");
	// generating terrain
	perlin_config = {
		inc: global.difficulty * curve_modifier,	// determines rough ness of noise. higher = more noise
		X: random(1000),
		Y: random(1000),
	}
	if (!global.DEBUG_STRAIGHT_MAP) {
		for (var yy = 0; yy < grid_height; yy++) {
			var Y_temp = perlin_config.Y;
			for (var xx = 0; xx < grid_width; xx++) {
				var index = xx + (yy * grid_height);
				var value = perlin_noise(perlin_config.X, Y_temp);
				grid[|index] = value;
				Y_temp += perlin_config.inc;
			}
			perlin_config.X += perlin_config.inc;
		}
	}
	print($"{ds_list_size(grid)} {grid_height * grid_width}");
	print("Creating road");
	// generating road
	var init_grid = irandom(grid_height-1);
	var control_start = init_grid * grid_width;
	var control_end = (min(grid_height, max(0, init_grid + irandom_range(-2 * global.difficulty, 2 * global.difficulty))) * grid_width) - 1;
	control_path = a_star(grid, control_start, control_end, grid_width, a_star_heuristic); // holds grid values to generate control poitns
}

// convert control_path coordinates to game world cordinates
primary_count = array_length(control_path);
for (var s = 0; s < array_length(control_path); s++) {
	var rand_x = 0;
	var rand_y = 0;
	if (!global.DEBUG_STRAIGHT_MAP) {
		rand_x = (irandom(control_points_dist / 5) * choose(-1,1));
		rand_y = (irandom(control_points_dist / 5) * choose(-1,1));
	}
	var xx = ((control_path[s] % grid_width) * control_points_dist) + rand_x;
	var yy = ((control_path[s] div grid_width) * control_points_dist) + rand_y;
	var zz = grid[|s] * 200 * global.difficulty;
	control_points[s] = new Point3D(xx, yy, zz);
}

for (var s = 0; s < array_length(control_points); s++) {
	var p = undefined;
	var p_next = undefined;
	if (s < array_length(control_points)-2) {
		p = control_points[s];
		p_next = control_points[s+1];
	}
	else {
		p = control_points[s-1];
		p_next = control_points[s];
	}
	
	var angle = point_direction(p.x, p.y, p_next.x, p_next.y);
	control_points_offset.left[s] = new Point3D(p.x+lengthdir_x(beyond_shoulder_range, angle+90), p.y+lengthdir_y(beyond_shoulder_range, angle+90), p.z);
	control_points_offset.right[s] = new Point3D(p.x+lengthdir_x(beyond_shoulder_range, angle-90), p.y+lengthdir_y(beyond_shoulder_range, angle-90), p.z);
}

// actually create road via catmull-rom
road_list = generate_roads(control_points, road_segments);
road_offset_list = {
	left: generate_roads(control_points_offset.left, road_segments),
	right: generate_roads(control_points_offset.right, road_segments),
}

print("Rendering Road");
var race_length_modifier = [1.25, 1.1, 1, 0.9, 0.8];
global.destination_road_index = round(array_length(road_list) * ((global.difficulty * 0.8) - 0.6) * race_length_modifier[global.level]) - (road_segments * 10);
global.race_length = 0;

//set up vertex buffers
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_color();
vertex_format_add_texcoord();
vertex_format_add_normal();
building_vertex_format = vertex_format_end();
global.building_vertex_buffer = vertex_create_buffer();

vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_color();
vertex_format_add_texcoord();
vertex_format_add_normal();
prop_vertex_format = vertex_format_end();
global.prop_vertex_buffer = vertex_create_buffer();

vertex_format_begin();
if (global.CAMERA_MODE_3D) {vertex_format_add_position_3d();} else {vertex_format_add_position();}
vertex_format_add_color();
vertex_format_add_texcoord();
vertex_format_add_normal();
road_vertex_format = vertex_format_end();
global.road_vertex_buffer = vertex_create_buffer();

// set up road node data
var lane_change_duration = 10; //how many nodes until change to new lane
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
		lane_change_duration = 10;//30+irandom(10);
		lane_change_to = course_data.MIN_LANES+irandom(course_data.MAX_LANES-course_data.MIN_LANES);
		
		cur_zone = choose_weight(course_data.ZONES, course_data.WEIGTHS, 1)[0];
		//if (irandom(2) == 0) {
		//	// change zone
		//	if (prev_road.zone != ZONE.RIVER) {
		//		cur_zone = choose(ZONE.SUBURBAN, ZONE.CITY, ZONE.DESERT, ZONE.RIVER);
		//	}
		//	else {
		//		// pick a different zone thats not a river, 
		//		cur_zone = choose(ZONE.SUBURBAN, ZONE.CITY, ZONE.DESERT);
		//	}
		//}
		
		switch(cur_zone) {
			case ZONE.RIVER:
				lane_change_to = 2+irandom(1);
				initial_river_seg = road_list[@ i+1];
				lane_change_duration = 15;
				break;
			case ZONE.CITY:
				road.building_color = building_color;
				// lane_change_to = 2+irandom(1);
				building_color = make_color_hsv(irandom(255), choose(0, 128 + irandom_range(-64, 64)), 196 + irandom_range(-32, 32));
				break;
		}
	}
	
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
			road.set_lanes_side(cur_lane_change_to);
			break;
	}
	lane_change_duration--;
	
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
	
	// set off road data
	if (road.zone == ZONE.MOUNTAIN) {
		road.beyond_range[0].z += 5000;
		road.beyond_range[1].z -= 1000;
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
	
	if (road.zone != ZONE.DESERT and road.zone != ZONE.RIVER and global.GAMEPLAY_COURSE != COURSES.HILL) {
		if (irandom(50) < 1) {
			road.intersection = true;
		}
	}

}

// calculate road collision
for (var i = 0; i < array_length(road_list) - 1; i++) {
	var road = road_list[@ i];
	var next_road = road_list[@ i + 1];
	var lane_function = [road.get_lanes_left, road.get_lanes_right];
	var next_lane_function = [next_road.get_lanes_left, next_road.get_lanes_right];
	//compile left lanes
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
	
}
	
// render control point
function render_control_point(cp, range=0) {
	// calculate render polygons
	if (global.road_vertex_buffer == -1) {global.road_vertex_buffer = vertex_create_buffer();}
	if (global.prop_vertex_buffer == -1) {global.prop_vertex_buffer = vertex_create_buffer();}
	var ri_start = max(0, (cp - 2) * obj_road_generator.road_segments);
	var ri_end = min(global.road_list_length, max(1, cp+range) * obj_road_generator.road_segments);
	
	vertex_begin(global.road_vertex_buffer, road_vertex_format);
	for (var i = ri_start; i < ri_end - 1; i++) {
		var road = road_list[@ i];
		var next_road = road_list[@ i + 1];
		
		var left_lanes = road.get_lanes_left();
		var right_lanes = road.get_lanes_right();
		var next_left_lanes = next_road.get_lanes_left();
		var next_right_lanes = next_road.get_lanes_right();
		var left_subimage = 2;
		var right_subimage = 2;
		var left_lane_sprite = global.ROAD_SPRITE_INDEX[left_lanes];
		var right_lane_sprite = global.ROAD_SPRITE_INDEX[right_lanes];
		var shoulder_uv = sprite_get_uvs(spr_road_shoulder, 0);
		var grass_uv = sprite_get_uvs(spr_grass, 0);
		var tunnel_uv = sprite_get_uvs(spr_tunnel_wall, 0);
		var off_shoulder_left_z = road.beyond_range[0].z;
		var off_shoulder_right_z = road.beyond_range[1].z;
		var next_off_shoulder_left_z = next_road.beyond_range[0].z;
		var next_off_shoulder_right_z = next_road.beyond_range[1].z;
		
		// change grass and shoulder texture
		switch(road.zone) {
			case ZONE.DESERT:
				shoulder_uv = sprite_get_uvs(spr_road_shoulder, 1);
				grass_uv = sprite_get_uvs(spr_grass, 2);
				break;
			case ZONE.CITY: case ZONE.TOWN: case ZONE.TUNNEL:
				shoulder_uv = sprite_get_uvs(spr_road_shoulder, 1);
				grass_uv = sprite_get_uvs(spr_grass, 1);
				break;
			case ZONE.RIVER:
				shoulder_uv = sprite_get_uvs(spr_road_shoulder, 1);
				grass_uv = sprite_get_uvs(spr_grass, 3);
				off_shoulder_z = road.sea_level;
				next_off_shoulder_z = next_road.sea_level;
				break;
		}
		
		if (road.zone == ZONE.RIVER and next_road.zone != ZONE.RIVER) {
			off_shoulder_z = road.sea_level;
			next_off_shoulder_z = road.sea_level;
		}
		
		// switch road texture during transition
		// lane change 
		if (left_lanes != next_left_lanes) {
			left_lane_sprite = global.ROAD_SPRITE_INDEX[min(left_lanes, next_left_lanes)];
			left_subimage = 2;
		}
		if (right_lanes != next_right_lanes) {
			right_lane_sprite = global.ROAD_SPRITE_INDEX[min(right_lanes, next_right_lanes)];
			right_subimage = 2;
		}
		
		if (road.zone != ZONE.DESERT and road.zone != ZONE.RIVER) {
			if (road.intersection) {
				// create lane intersection
				shoulder_uv = sprite_get_uvs(spr_road_shoulder, 2);
				grass_uv = sprite_get_uvs(spr_road_side, 0);
				left_subimage = 0;
				right_subimage = 0;
			}
			else {
				if (next_road.intersection) {
					left_subimage = 4;
					right_subimage = 4;
				}
				if (i > 0) {
					if (road_list[@ i-1].intersection) {
						left_subimage = 3;
						right_subimage = 3;
					}
				}
			}
		}
		
		if (i == global.destination_road_index) {
			left_lane_sprite = spr_checkered;
			right_lane_sprite = spr_checkered;
			left_subimage = 0;
			right_subimage = 0;
		}
	
		var left_uv = sprite_get_uvs(left_lane_sprite, left_subimage);		// left lanes uv
		var right_uv = sprite_get_uvs(right_lane_sprite, right_subimage);	// right lanes uv
		var left_change_uv = sprite_get_uvs(spr_road_1_lane, 0);			// left lanes uv for lane change
		var right_change_uv = sprite_get_uvs(spr_road_1_lane, 0);			// right lanes uv for lane change
		var road_render_points = [
			 [
				road.x+lengthdir_x(lane_width*min(left_lanes, next_left_lanes), road.direction+90),
				next_road.x+lengthdir_x(lane_width*min(left_lanes, next_left_lanes), next_road.direction+90),
				next_road.x+lengthdir_x(lane_width*min(right_lanes, next_right_lanes), next_road.direction-90),
				road.x+lengthdir_x(lane_width*min(right_lanes, next_right_lanes), road.direction-90),
			],
			[
				road.y+lengthdir_y(lane_width*min(left_lanes, next_left_lanes), road.direction+90),
				next_road.y+lengthdir_y(lane_width*min(left_lanes, next_left_lanes), next_road.direction+90),
				next_road.y+lengthdir_y(lane_width*min(right_lanes, next_right_lanes), next_road.direction-90),
				road.y+lengthdir_y(lane_width*min(right_lanes, next_right_lanes), road.direction-90),
			]
		];
		var shoulder_coord = {
			left: [
				[road.x+lengthdir_x(lane_width * (left_lanes), road.direction+90),					road.y+lengthdir_y(lane_width * (left_lanes), road.direction+90)],
				[next_road.x+lengthdir_x(lane_width * next_left_lanes, next_road.direction+90),		next_road.y+lengthdir_y(lane_width * next_left_lanes, next_road.direction+90)],
				[next_road.x+lengthdir_x(lane_width * (next_left_lanes+1), next_road.direction+90),	next_road.y+lengthdir_y(lane_width * (next_left_lanes+1), next_road.direction+90)],
				[road.x+lengthdir_x(lane_width * (left_lanes+1), road.direction+90),				road.y+lengthdir_y(lane_width * (left_lanes+1), road.direction+90)],
			],
			right: [
				[next_road.x+lengthdir_x(lane_width * next_right_lanes, next_road.direction-90),	next_road.y+lengthdir_y(lane_width * next_right_lanes, next_road.direction-90)],
				[road.x+lengthdir_x(lane_width * (right_lanes), road.direction-90),					road.y+lengthdir_y(lane_width * (right_lanes), road.direction-90)],
				[road.x+lengthdir_x(lane_width * (right_lanes+1), road.direction-90),				road.y+lengthdir_y(lane_width * (right_lanes+1), road.direction-90)],
				[next_road.x+lengthdir_x(lane_width*(next_right_lanes+1), next_road.direction-90),	next_road.y+lengthdir_y(lane_width*(next_right_lanes+1), next_road.direction-90)],
			]
		}
		var grass_coord = {
			left: [
				[road.x+lengthdir_x(lane_width * (left_lanes+1), road.direction+90),				road.y+lengthdir_y(lane_width * (left_lanes+1), road.direction+90)],
				[next_road.x+lengthdir_x(lane_width * (next_left_lanes+1), next_road.direction+90),	next_road.y+lengthdir_y(lane_width * (next_left_lanes+1), next_road.direction+90)],
				[next_road.beyond_range[0].x, next_road.beyond_range[0].y],
				[road.beyond_range[0].x, road.beyond_range[0].y]
				//[shoulder_coord.left[2][0]+lengthdir_x(next_road.beyond_range, next_road.direction+90), shoulder_coord.left[2][1]+lengthdir_y(next_road.beyond_range, next_road.direction+90)],
				//[shoulder_coord.left[3][0]+lengthdir_x(road.beyond_range, road.direction+90), shoulder_coord.left[3][1]+lengthdir_y(road.beyond_range, road.direction+90)]
			],
			right: [
				[next_road.x+lengthdir_x(lane_width * (next_right_lanes+1), next_road.direction-90),	next_road.y+lengthdir_y(lane_width * (next_right_lanes+1), next_road.direction-90)],
				[road.x+lengthdir_x(lane_width * (right_lanes+1), road.direction-90),					road.y+lengthdir_y(lane_width * (right_lanes+1), road.direction-90)],
				[road.beyond_range[1].x, road.beyond_range[1].y],
				[next_road.beyond_range[1].x, next_road.beyond_range[1].y],
				//[shoulder_coord.right[2][0]+lengthdir_x(road.beyond_range, road.direction-90), shoulder_coord.right[2][1]+lengthdir_y(road.beyond_range, road.direction-90)],
				//[shoulder_coord.right[3][0]+lengthdir_x(next_road.beyond_range, next_road.direction-90), shoulder_coord.right[3][1]+lengthdir_y(next_road.beyond_range, next_road.direction-90)],
			]
		}
		#region Road Render Polygons
		var road_seg_data = [
			
			//left grass
			[new Point3D(grass_coord.left[0][0], grass_coord.left[0][1], road.z-7), new Point(grass_uv[2], grass_uv[3])],
			[new Point3D(grass_coord.left[1][0], grass_coord.left[1][1], next_road.z-7), new Point(grass_uv[2], grass_uv[1])],
			[new Point3D(grass_coord.left[2][0], grass_coord.left[2][1], next_off_shoulder_left_z), new Point(grass_uv[0], grass_uv[1])],
		
			[new Point3D(grass_coord.left[0][0], grass_coord.left[0][1], road.z-7), new Point(grass_uv[2], grass_uv[3])],
			[new Point3D(grass_coord.left[2][0], grass_coord.left[2][1], next_off_shoulder_left_z), new Point(grass_uv[0], grass_uv[1])],
			[new Point3D(grass_coord.left[3][0], grass_coord.left[3][1], off_shoulder_left_z), new Point(grass_uv[0], grass_uv[3])],
			
			//left shoulder 
			[new Point3D(shoulder_coord.left[0][0], shoulder_coord.left[0][1], road.z), new Point(shoulder_uv[2], shoulder_uv[1])],
			[new Point3D(shoulder_coord.left[1][0], shoulder_coord.left[1][1], next_road.z), new Point(shoulder_uv[0], shoulder_uv[1])],
			[new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.z), new Point(shoulder_uv[0], shoulder_uv[3])],
		
			[new Point3D(shoulder_coord.left[0][0], shoulder_coord.left[0][1], road.z), new Point(shoulder_uv[2], shoulder_uv[1])],
			[new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.z), new Point(shoulder_uv[0], shoulder_uv[3])],
			[new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z), new Point(shoulder_uv[2], shoulder_uv[3])],
			
			//left road
			[new Point3D(road_render_points[0][0], road_render_points[1][0], road.z), new Point(left_uv[0], left_uv[3])],
			[new Point3D(road.x, road.y, road.z), new Point(left_uv[0], left_uv[1])],
			[new Point3D(road_render_points[0][1], road_render_points[1][1], next_road.z), new Point(left_uv[2], left_uv[3])],
		
			[new Point3D(road.x, road.y, road.z), new Point(left_uv[0], left_uv[1])],
			[new Point3D(next_road.x, next_road.y, next_road.z), new Point(left_uv[2], left_uv[1])],
			[new Point3D(road_render_points[0][1], road_render_points[1][1], next_road.z), new Point(left_uv[2], left_uv[3])],
		
			//right road
			[new Point3D(road_render_points[0][2], road_render_points[1][2], next_road.z), new Point(right_uv[2], right_uv[3])],
			[new Point3D(next_road.x, next_road.y, next_road.z), new Point(right_uv[2], right_uv[1])],
			[new Point3D(road_render_points[0][3], road_render_points[1][3], road.z), new Point(right_uv[0], right_uv[3])],
			
			[new Point3D(road.x, road.y, road.z), new Point(right_uv[0], right_uv[1])],
			[new Point3D(road_render_points[0][3], road_render_points[1][3], road.z), new Point(right_uv[0], right_uv[3])],
			[new Point3D(next_road.x, next_road.y, next_road.z), new Point(right_uv[2], right_uv[1])],
		
			//right shoulder 
			[new Point3D(shoulder_coord.right[0][0], shoulder_coord.right[0][1], next_road.z), new Point(shoulder_uv[2], shoulder_uv[1])],
			[new Point3D(shoulder_coord.right[1][0], shoulder_coord.right[1][1], road.z), new Point(shoulder_uv[0], shoulder_uv[1])],
			[new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z), new Point(shoulder_uv[0], shoulder_uv[3])],
		
			[new Point3D(shoulder_coord.right[0][0], shoulder_coord.right[0][1], next_road.z), new Point(shoulder_uv[2], shoulder_uv[1])],
			[new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z), new Point(shoulder_uv[0], shoulder_uv[3])],
			[new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.z), new Point(shoulder_uv[2], shoulder_uv[3])],
		
			// right grass
			[new Point3D(grass_coord.right[0][0], grass_coord.right[0][1], next_road.z-7), new Point(grass_uv[0], grass_uv[1])],
			[new Point3D(grass_coord.right[1][0], grass_coord.right[1][1], road.z-7), new Point(grass_uv[0], grass_uv[3])],
			[new Point3D(grass_coord.right[2][0], grass_coord.right[2][1], off_shoulder_right_z), new Point(grass_uv[2], grass_uv[3])],
		
			[new Point3D(grass_coord.right[0][0], grass_coord.right[0][1], next_road.z-7), new Point(grass_uv[0], grass_uv[1])],
			[new Point3D(grass_coord.right[2][0], grass_coord.right[2][1], off_shoulder_right_z), new Point(grass_uv[2], grass_uv[3])],
			[new Point3D(grass_coord.right[3][0], grass_coord.right[3][1], next_off_shoulder_right_z), new Point(grass_uv[2], grass_uv[1])],
			
		];
		
		// create tunnel polygons
		if (road.zone == ZONE.TUNNEL) {
			road_seg_data = array_concat(road_seg_data,[
				////left tunnel wall
				[new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.z), new Point(tunnel_uv[2], tunnel_uv[3])],
				[new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.z + tunnel_height), new Point(tunnel_uv[2], tunnel_uv[1])],
				[new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z), new Point(tunnel_uv[0], tunnel_uv[3])],
		
				[new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.z + tunnel_height), new Point(tunnel_uv[2], tunnel_uv[1])],
				[new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + tunnel_height), new Point(tunnel_uv[0], tunnel_uv[1])],
				[new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z), new Point(tunnel_uv[0], tunnel_uv[3])],
				
				// right tunnel wall
				[new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z), new Point(tunnel_uv[2], tunnel_uv[3])],
				[new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + tunnel_height), new Point(tunnel_uv[2], tunnel_uv[1])],
				[new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.z), new Point(tunnel_uv[0], tunnel_uv[3])],
		
				[new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + tunnel_height), new Point(tunnel_uv[2], tunnel_uv[1])],
				[new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.z + tunnel_height), new Point(tunnel_uv[0], tunnel_uv[1])],
				[new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.z), new Point(tunnel_uv[0], tunnel_uv[3])],
				
				// roof
				[new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.z + tunnel_height), new Point(tunnel_uv[2], tunnel_uv[1])],
				[new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.z + tunnel_height), new Point(tunnel_uv[2], tunnel_uv[1])],
				[new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + tunnel_height), new Point(tunnel_uv[0], tunnel_uv[3])],
		
				[new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + tunnel_height), new Point(tunnel_uv[2], tunnel_uv[3])],
				[new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.z + tunnel_height), new Point(tunnel_uv[0], tunnel_uv[3])],
				[new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + tunnel_height), new Point(tunnel_uv[0], tunnel_uv[1])],
			]);
		}
		
		// added missing segment when lane changes
		if (road.get_lanes() != next_road.get_lanes()) {
			road_seg_data = array_concat(road_seg_data,[
				// missing grass floor on the center
				[new Point3D(road_render_points[0][0], road_render_points[1][0], road.z), new Point(left_change_uv[2], left_change_uv[1])],
				[new Point3D(road_render_points[0][1], road_render_points[1][1], next_road.z), new Point(left_change_uv[2], left_change_uv[3])],
				[new Point3D(
					(left_lanes > next_left_lanes) ? shoulder_coord.left[0][0] : shoulder_coord.left[1][0], 
					(left_lanes > next_left_lanes) ? shoulder_coord.left[0][1] : shoulder_coord.left[1][1], 
					(left_lanes > next_left_lanes) ? road.z : next_road.z
				), new Point(right_change_uv[0], (right_lanes > next_right_lanes) ? right_change_uv[1] : right_change_uv[3])],
				
				[new Point3D(road_render_points[0][2], road_render_points[1][2], next_road.z), new Point(right_change_uv[0], right_change_uv[3])],
				[new Point3D(road_render_points[0][3], road_render_points[1][3], road.z), new Point(right_change_uv[0], right_change_uv[1])],
				[new Point3D(
					(right_lanes > next_right_lanes) ? shoulder_coord.right[1][0] : shoulder_coord.right[0][0], 
					(right_lanes > next_right_lanes) ? shoulder_coord.right[1][1] : shoulder_coord.right[0][1], 
					(right_lanes > next_right_lanes) ? road.z : next_road.z
				), new Point(right_change_uv[2], (right_lanes > next_right_lanes) ? right_change_uv[1] : right_change_uv[3])],
			]);
		}
		if (i > 0) {
			if (road.zone == ZONE.RIVER) {
				road_seg_data = array_concat(road_seg_data,[
					// missing grass floor on the center
					[new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.sea_level), new Point(grass_uv[0], grass_uv[1])],
					[new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.sea_level), new Point(grass_uv[2], grass_uv[3])],
					[new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.sea_level), new Point(grass_uv[0], grass_uv[3])],
					
					[new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.sea_level), new Point(grass_uv[0], grass_uv[1])],
					[new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.sea_level), new Point(grass_uv[2], grass_uv[1])],
					[new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.sea_level), new Point(grass_uv[2], grass_uv[3])],
				]);
			}
			
			if (road.zone != ZONE.RIVER && road_list[@ i-1].zone == ZONE.RIVER) {
				var prev_road = road_list[@ i-1];
				road_seg_data = array_concat(road_seg_data,[
					// wall
					[new Point3D(road.x, road.y, road.z), new Point(grass_uv[0], grass_uv[1])],
					[new Point3D(road.x, road.y, prev_road.sea_level), new Point(grass_uv[0], grass_uv[3])],
					[new Point3D(road.beyond_range[1].x, road.beyond_range[1].y, road.z), new Point(grass_uv[2], grass_uv[1])],
		
					[new Point3D(road.x, road.y, prev_road.sea_level), new Point(grass_uv[0], grass_uv[3])],
					[new Point3D(road.beyond_range[1].x, road.beyond_range[1].y, prev_road.sea_level), new Point(grass_uv[2], grass_uv[3])],
					[new Point3D(road.beyond_range[1].x, road.beyond_range[1].y, road.z), new Point(grass_uv[2], grass_uv[1])],
					
					
					[new Point3D(road.x, road.y, road.z), new Point(grass_uv[0], grass_uv[1])],
					[new Point3D(road.beyond_range[0].x, road.beyond_range[0].y, road.z), new Point(grass_uv[2], grass_uv[1])],
					[new Point3D(road.x, road.y, prev_road.sea_level), new Point(grass_uv[0], grass_uv[3])],
		
					[new Point3D(road.x, road.y, prev_road.sea_level), new Point(grass_uv[0], grass_uv[3])],
					[new Point3D(road.beyond_range[0].x, road.beyond_range[0].y, road.z), new Point(grass_uv[2], grass_uv[1])],
					[new Point3D(road.beyond_range[0].x, road.beyond_range[0].y, prev_road.sea_level), new Point(grass_uv[2], grass_uv[3])],
				]);
			}
		}
		
		for (var di = 0; di < array_length(road_seg_data); di++) {
			var data = road_seg_data[di];
			var pos = data[0];
			var uv = data[1];
			if (global.CAMERA_MODE_3D) {vertex_position_3d(global.road_vertex_buffer, pos.x, pos.y, pos.z - 3);} else {vertex_position(global.road_vertex_buffer, pos.x, pos.y);}
			vertex_color(global.road_vertex_buffer, c_white, 1);
			vertex_texcoord(global.road_vertex_buffer, uv.x, uv.y);
			vertex_normal(global.road_vertex_buffer, 0, 0, 1);
			
		}
		
		for (var p_i = 0; p_i < array_length(road.buildings); p_i++) {
			road.buildings[p_i].init_vertex_buffer();
		}
		#endregion
	}
	vertex_end(global.road_vertex_buffer);
	global.road_vertex_buffer = calc_vertex_normal(global.road_vertex_buffer, road_vertex_format);
	vertex_freeze(global.road_vertex_buffer);	
	
	
	vertex_begin(global.prop_vertex_buffer, prop_vertex_format);
	for (var i = ri_start; i < ri_end - 1; i++) {
		var road = road_list[@ i];
		for (var p_i = 0; p_i < array_length(road.props); p_i++) {
			road.props[p_i].init_vertex_buffer();
		}
	}
	vertex_end(global.prop_vertex_buffer);
	global.prop_vertex_buffer = calc_vertex_normal(global.prop_vertex_buffer, prop_vertex_format);
	vertex_freeze(global.prop_vertex_buffer);
}

/************* create props *************/
var prop_chain = 0;
var prop_image_index = 1;
var prop_side_len = 0;
//vertex_begin(global.prop_vertex_buffer, prop_vertex_format);
for (var i = 0; i < array_length(road_list) - 1; i++) {
	var road = road_list[@i];
	var next_road = road_list[@i+1];
	var left_lanes = road.get_lanes_left();
	var right_lanes = road.get_lanes_right();
	
	// create traffic lights at intersections
	if (road.intersection and !next_road.intersection) {
		var traffic_light = instance_create_layer(
			next_road.x + lengthdir_x((right_lanes + 0.5) * next_road.lane_width, next_road.direction - 90),
			next_road.y + lengthdir_y((right_lanes + 0.5) * next_road.lane_width, next_road.direction - 90),
			"Instances",
			obj_traffic_prop
		);
		traffic_light.image_xscale = 12;
		traffic_light.image_yscale = 12;
		traffic_light.image_index = 0;
		traffic_light.display_sprite_index = spr_traffic_light;
		traffic_light.display_image_index = next_road.get_lanes_right() - 1;
		traffic_light.z = next_road.z;
		traffic_light.direction = road.direction;
		array_push(road.props, traffic_light);
	}
	
	// create speed limit sign
	if ((i % 100) == 0) {
		var prop_obj = instance_create_layer(
			road.x + lengthdir_x((right_lanes+0.25) * road.lane_width, road.direction-90),
			road.y + lengthdir_y((right_lanes+0.25) * road.lane_width, road.direction-90),
			"Instances",
			obj_traffic_prop
		);
		prop_obj.display_image_index = 0;
		prop_obj.z = road.z;
		prop_obj.direction = road.direction;
		array_push(road.props, prop_obj);
	}
	
	// create street sign
	if (road.intersection and !next_road.intersection) {
		var str_sign = instance_create_layer(
			next_road.x + lengthdir_x((right_lanes+1) * lane_width, next_road.direction - 90),
			next_road.y + lengthdir_y((right_lanes+1) * lane_width, next_road.direction - 90),
			"Instances",
			obj_traffic_prop
		);
		str_sign.display_image_index = 2;
		str_sign.z = next_road.z;
		str_sign.direction = road.direction;
		array_push(road.props, str_sign);
	}
	
	// create billboards
	if (irandom(100) == 0) {
		var len = choose(-left_lanes, right_lanes) * road.lane_width;
		var prop_obj = instance_create_layer(
			road.x + lengthdir_x(len * 3, road.direction-90),
			road.y + lengthdir_y(len * 3, road.direction-90),
			"Instances",
			obj_billboard
		);
		prop_obj.z = road.z;
		prop_obj.direction = road.direction;
		array_push(road.props, prop_obj);
	}
	
	// prop chain 
	if (prop_chain > 0) {
		var prop_obj = instance_create_layer(
			road.x + lengthdir_x(prop_side_len, road.direction-90),
			road.y + lengthdir_y(prop_side_len, road.direction-90),
			"Instances",
			obj_traffic_prop
		);
		prop_obj.display_image_index = prop_image_index;
		prop_obj.z = road.z;
		prop_obj.direction = road.direction;
		with(prop_obj) {
			event_perform(ev_other, ev_user0);
		}
		array_push(road.props, prop_obj);
		
		prop_chain -= 1;
		if (prop_chain == 0) {
			// reseting  chain
			prop_chain -= round(50 / global.difficulty);
			prop_image_index = choose(1, 6);
			switch(prop_image_index) {
				case 6:
					prop_side_len = choose(-left_lanes-0.5, right_lanes+0.5) * road.lane_width;
					break;
				default:
					prop_side_len = choose(-left_lanes, right_lanes) * road.lane_width;
					break;
			}
		}
	}
	else {
		prop_chain += 1;
		if (prop_chain == 0) {
			prop_chain = 3+irandom(3);
		}
	}
	
	// finish line prop
	if (global.destination_road_index - 5 < i and i <= global.destination_road_index) {
		for (var j = 0; j < 5; j++) {
			var prop_obj = instance_create_layer(
				road.x + lengthdir_x(left_lanes * road.lane_width, road.direction+90),
				road.y + lengthdir_y(left_lanes * road.lane_width, road.direction+90),
				"Instances",
				obj_traffic_prop
			);
			prop_obj.display_image_index = 7;
			prop_obj.z = road.z;
			prop_obj.image_xscale = 8;
			prop_obj.image_yscale = 24;
			prop_obj.direction = road.direction;
			array_push(road.props, prop_obj);
			
			var prop_obj = instance_create_layer(
				road.x + lengthdir_x(right_lanes * road.lane_width, road.direction-90),
				road.y + lengthdir_y(right_lanes * road.lane_width, road.direction-90),
				"Instances",
				obj_traffic_prop
			);
			prop_obj.display_image_index = 7;
			prop_obj.z = road.z;
			prop_obj.image_xscale = 8;
			prop_obj.image_yscale = 8;
			prop_obj.direction = road.direction;
			array_push(road.props, prop_obj);
		}
	}
	
	
	// zone specific props
	switch(road.zone) {
		// create building
		case ZONE.CITY:	case ZONE.TOWN:	
			if (!road.intersection) {
				// create buildings on each side of the road
				for (var j = -1; j <= 1; j += 2) {
					var func = undefined;
					var pos = [road.x, road.y];
					switch(j) {
						case -1:
							func = road.get_lanes_left;
							pos = [next_road.x, next_road.y];
							break;
						case 1:
							func = road.get_lanes_right;
							break;
					}
					var building_obj = instance_create_layer(
						pos[0] + lengthdir_x((func() + 1) * lane_width * j, road.direction-90),
						pos[1] + lengthdir_y((func() + 1) * lane_width * j, road.direction-90),
						"Instances",
						obj_building
					);
					building_obj.z = road.z;
					building_obj.direction = road.direction + (j == -1 ? 180 : 0);
					building_obj.building_width = road.length * 0.8;
					building_obj.floors = (road.zone == ZONE.CITY ? 3 + irandom(2) : 1);
					building_obj.z_start = road.z;
					building_obj.z_end = next_road.z;
					building_obj.building_color = road.building_color;
					building_obj.display_image_index = irandom(2);
					if (j == -1) {
						building_obj.z_start = next_road.z;
						building_obj.z_end = road.z;
					}
					building_obj.assigned_cp = i div road_segments;
					array_push(road.buildings, building_obj);
				}
				if (i > 0) {
					if (road_list[@i-1].intersection | road_list[@i-1].zone != road.zone) {
						// create buildings of intersection
						for (var j = -1; j <= 1; j += 2) {
							for (var k = 0; k < 10; k++) {
								var func = undefined;
								var pos = [road.x, road.y];
								switch(j) {
									case -1:
										func = road.get_lanes_left;
										break;
									case 1:
										func = road.get_lanes_right;
										break;
								}
								var l = 512 + (func() * lane_width) + (road.length * k);
								var building_obj = instance_create_layer(
									pos[0] + lengthdir_x(l, road.direction+(90 * j)),
									pos[1] + lengthdir_y(l, road.direction+(90 * j)),
									"Instances",
									obj_building
								);
								building_obj.z = road.z;
								building_obj.direction = road.direction + 90;
								building_obj.building_width = road.length * 0.9;
								building_obj.floors = (road.zone == ZONE.CITY ? 3 + irandom(2) : 1);
								building_obj.z_start = road.z;
								building_obj.z_end = road.z;
								building_obj.building_color = road.building_color;
								building_obj.display_image_index = irandom(2);

								building_obj.assigned_cp = i div road_segments;
								array_push(road.buildings, building_obj);
							}
						}
					}
				}
			}
			
			// create city trees
			if ((i%4) == 0) {
				var begin_length = choose(
					lane_width*(left_lanes+0.5),
					-lane_width*(right_lanes+0.5),
				);
				var tree_obj = instance_create_layer(
					road.x + lengthdir_x(begin_length, road.direction + 90),
					road.y + lengthdir_y(begin_length, road.direction + 90),
					"Instances",
					obj_tree
				);
				tree_obj.display_image_index = choose(2, 3, 4);
				tree_obj.z = road.z;
				tree_obj.assigned_cp = i div road_segments;
				array_push(road.props, tree_obj);
			}
			break;
		case ZONE.DESERT:
			//create trees
			if (global.GAMEPLAY_TREES) {
				for (var tid = 0; tid < irandom(3); tid++) {
					var begin_length = choose(
						lane_width*(left_lanes+1) + random(beyond_shoulder_range),
						-lane_width*(right_lanes+1) - random(beyond_shoulder_range),
					);
					var tree_obj = instance_create_layer(
						road.x + lengthdir_x(begin_length, road.direction + 90) + random_range(-16,16),
						road.y + lengthdir_y(begin_length, road.direction + 90) + random_range(-16,16),
						"Instances",
						obj_tree
					);
					tree_obj.display_image_index = choose(2, 9, 10);
					tree_obj.z = road.z - irandom(32);
					tree_obj.assigned_cp = i div road_segments;
					array_push(road.props, tree_obj);
				}
			}
			break;
		case ZONE.FOREST:
			// create trees
			if (global.GAMEPLAY_TREES) {
				
				// lorge tree
				for (var tid = 0; tid < irandom(5); tid++) {
					var begin_length = choose(
						lane_width*(left_lanes+5) + random(beyond_shoulder_range)/4,
						-lane_width*(right_lanes+5) - random(beyond_shoulder_range)/4,
					);
					var tree_obj = instance_create_layer(
						road.x + lengthdir_x(begin_length, road.direction + 90) + random_range(-32,32),
						road.y + lengthdir_y(begin_length, road.direction + 90) + random_range(-32,32),
						"Instances",
						obj_tree
					);
					tree_obj.display_image_index = 8;
					tree_obj.direction = ((i/10) * 90) + (irandom(3) * 90);
					tree_obj.z = road.z - irandom(32);
					tree_obj.assigned_cp = i div road_segments;
					tree_obj.image_xscale = 2;
					tree_obj.image_yscale = 2;
					tree_obj.render_scale.x = 2;
					tree_obj.render_scale.y = 2;
					tree_obj.render_scale.z = 4;
					array_push(road.props, tree_obj);
				}
				
				// some smaller trees
				var begin_length = choose(
					lane_width*(left_lanes+3),
					-lane_width*(right_lanes+3),
				);
				var tree_obj = instance_create_layer(
					road.x + lengthdir_x(begin_length, road.direction + 90) + random_range(-32,32),
					road.y + lengthdir_y(begin_length, road.direction + 90) + random_range(-32,32),
					"Instances",
					obj_tree
				);
				tree_obj.display_image_index = 8;
				tree_obj.direction = ((i/10) * 90) + (irandom(3) * 90);
				tree_obj.z = road.z - irandom(32);
				tree_obj.assigned_cp = i div road_segments;
				tree_obj.image_xscale = 1;
				tree_obj.image_yscale = 1;
				array_push(road.props, tree_obj);
			}
			break;
		default:
			// create trees
			if (global.GAMEPLAY_TREES) {
				if (road.zone != ZONE.RIVER and road.zone != ZONE.TUNNEL) {
					for (var tid = 0; tid < irandom(25); tid++) {
						var choose_index = choose(0,1);
						var begin_length = [
							lane_width*(left_lanes+2) + random(beyond_shoulder_range/2),
							-lane_width*(right_lanes+2) - random(beyond_shoulder_range/2),
						][choose_index];
						var tree_obj = instance_create_layer(
							road.x + lengthdir_x(begin_length, road.direction + 90) + random_range(-32,32),
							road.y + lengthdir_y(begin_length, road.direction + 90) + random_range(-32,32),
							"Instances",
							obj_tree
						);
						tree_obj.direction = (i/25) * 360;
						tree_obj.display_image_index = irandom(8);
						tree_obj.z =lerp(road.z - irandom(32), road.beyond_range[choose_index].z, abs(begin_length) / beyond_shoulder_range);
						tree_obj.assigned_cp = i div road_segments;
						array_push(road.props, tree_obj);
					}
				}
			}
			break;
	}
	
	//create light
	if ((global.GAMEPLAY_COURSE != COURSES.DESERT) & (global.GAMEPLAY_COURSE != COURSES.MOUNTAIN)) {
		if (i % 5 == 0) {
			var side = [
				lane_width*(left_lanes+1),
				-lane_width*(right_lanes+1),
				0,
			];
			var j_start = 0;
			var j_end = 1;
			var light_section = i div 5;
			j_start = light_section % 2;
			j_end = light_section % 2;
		
			if (road.zone == ZONE.RIVER) {
				j_start = 2;
				j_end = 2;
			}
				
			for (var j = j_start; j <= j_end; j++) {
				var obj = instance_create_layer(
					road.x + lengthdir_x(side[j], road.direction + 90),
					road.y + lengthdir_y(side[j], road.direction + 90),
					"Instances",
					obj_street_light
				);
				obj.display_sprite_index = spr_street_light;
				obj.display_image_index = j;
				obj.z = road.z;
				obj.assigned_cp = i div road_segments;
				obj.direction = road.direction;
				array_push(road.props, obj);
			}
		}
	}
}

// create chevron road limit sign
for (var i = 0; i < array_length(road_list) - 1; i++) {
	var road = road_list[@i];
	var next_road = road_list[@i+1];
	var left_lanes = road.get_lanes_left();
	var right_lanes = road.get_lanes_right();
	
	for (var j = 1; j < 8; j++) {
		if (i + j < array_length(road_list)) {
			var angle = angle_difference(road_list[i].direction, road_list[i+j].direction);
			var r = road_list[i+j];
			var ll = r.get_lanes_left();
			var rl = r.get_lanes_right();
			
			if (abs(angle) > 25) {
				var lane_func = (sign(angle) == -1 ? rl : ll);
				var prop_obj = instance_create_layer(
					r.x + lengthdir_x(sign(angle) * (lane_func+1) * r.lane_width, r.direction+90),
					r.y + lengthdir_y(sign(angle) * (lane_func+1) * r.lane_width, r.direction+90),
					"Instances",
					obj_traffic_prop
				);
				prop_obj.display_image_index = 4 + sign(angle);
				prop_obj.z = r.z;
				prop_obj.direction = road_list[i].direction;
				with (prop_obj) {event_user(0);}
				array_push(r.props, prop_obj);
				i += 2;
			}
		}
	}
}

// railing buffer
for (var i = 0; i < array_length(road_list) - 1; i++) {
	var road = road_list[@i];
	var next_road = road_list[@i+1];
	var left_lanes = road.get_lanes_left();
	var right_lanes = road.get_lanes_right();
	var next_left_lanes = next_road.get_lanes_left();
	var next_right_lanes = next_road.get_lanes_right();
	var railing_image = 0;
	// create railing
	var choose_side = [];
	var angle_diff = angle_difference(road.direction, next_road.direction);
	switch(road.zone) {
		case ZONE.RIVER:
			choose_side = [0,1,2];
			left_lanes += 1;
			right_lanes += 1;
			next_left_lanes += 1;
			next_right_lanes += 1;
			railing_image = 1;
			break;
		case ZONE.MOUNTAIN:
			choose_side = [0,1];
			left_lanes += 1;
			right_lanes += 1;
			next_left_lanes += 1;
			next_right_lanes += 1;
			railing_image = 1;
			break;
		default:
			if (abs(angle_diff) > 10) {
				var s = sign(angle_diff);
				switch(s) {
					case -1:
						choose_side = [1];
						break;
					case 1:
						choose_side = [0];
						break;
				}
			}
			if (road.intersection) {
				choose_side = [];
			}
	}
	
	for (var j = 0; j < array_length(choose_side); j++) {
		var s = choose_side[j];
		var begin_length = [
			-lane_width*(left_lanes),
			lane_width*(right_lanes),
			0,
		];
		var next_length = [
			-lane_width*(next_left_lanes),
			lane_width*(next_right_lanes),
			0,
		];
		var railing_obj = instance_create_layer(
			road.x + lengthdir_x(begin_length[s], road.direction - 90),
			road.y + lengthdir_y(begin_length[s], road.direction - 90),
			"Instances",
			obj_railing
		);
		railing_obj.length = point_distance(
			road.x + lengthdir_x(begin_length[s], road.direction - 90),
			road.y + lengthdir_y(begin_length[s], road.direction - 90),
			next_road.x + lengthdir_x(next_length[s], next_road.direction - 90),
			next_road.y + lengthdir_y(next_length[s], next_road.direction - 90)
		);
		railing_obj.direction = point_direction(
			road.x + lengthdir_x(begin_length[s], road.direction - 90),
			road.y + lengthdir_y(begin_length[s], road.direction - 90),
			next_road.x + lengthdir_x(next_length[s], next_road.direction - 90),
			next_road.y + lengthdir_y(next_length[s], next_road.direction - 90)
		);
		railing_obj.image_xscale = railing_obj.length;
		railing_obj.image_angle = road.direction;
		railing_obj.z = road.z - 5;
		railing_obj.z_end = next_road.z - 5;
		railing_obj.display_image_index = railing_image;
		railing_obj.assigned_cp = i div road_segments;
		array_push(road.props, railing_obj);
	}
}
//vertex_end(global.prop_vertex_buffer);
//global.prop_vertex_buffer = calc_vertex_normal(global.prop_vertex_buffer, prop_vertex_format);
//vertex_freeze(global.prop_vertex_buffer);

//vertex_format_begin();
//vertex_format_add_position_3d();
//vertex_format_add_color();
//vertex_format_add_texcoord();
//vertex_format_add_normal();
//test_vertex_format = vertex_format_end();
//test_vertex_buffer = vertex_create_buffer();

////bottom
//var test_size = 1000;
//vertex_begin(test_vertex_buffer, test_vertex_format);
//vertex_position_3d_uv(test_vertex_buffer, -test_size, -test_size, 0, 0, 0, c_white, 1);
//vertex_position_3d_uv(test_vertex_buffer, test_size, -test_size, 0, 1, 0, c_white, 1);
//vertex_position_3d_uv(test_vertex_buffer, test_size, test_size, 0, 1, 1, c_white, 1);

//vertex_position_3d_uv(test_vertex_buffer, test_size, test_size, 0, 1, 1, c_white, 1);
//vertex_position_3d_uv(test_vertex_buffer, -test_size, test_size, 0, 0, 1, c_white, 1);
//vertex_position_3d_uv(test_vertex_buffer, -test_size, -test_size, 0, 0, 0, c_white, 1);
//vertex_end(test_vertex_buffer);
//test_vertex_buffer = calc_vertex_normal(test_vertex_buffer, test_vertex_format);
//vertex_freeze(test_vertex_buffer);

global.road_list_length = array_length(road_list);

obj_controller.x = road_list[0].x;
obj_controller.y = road_list[0].y;
	

show_debug_message($"road generation completed in {current_time - t}ms");
show_debug_message($"global.road_vertex_buffer has {vertex_get_buffer_size(global.road_vertex_buffer)} bytes");
show_debug_message($"building_vertex_buffer has {vertex_get_buffer_size(global.building_vertex_buffer)} bytes");

vehicle_current_pos_ping = 0;

alarm[0] = 30;