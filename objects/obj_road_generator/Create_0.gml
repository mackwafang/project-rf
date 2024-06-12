// randomize();
random_set_seed(0);
depth = 1000;

// primary_count = 80 * global.difficulty;
road_segments = 12;
control_points = [];
control_points_dist = 2048;
lane_width = 80;
track_length = 0;
beyond_shoulder_range = 2000;
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
while (array_length(control_path) == 0) {
	print("Creating grid");
	// generating terrain
	perlin_config = {
		inc: global.difficulty * 0.6,	// determines rough ness of noise. higher = more noise
		X: random(1000),
		Y: random(1000),
	}
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
	print($"{ds_list_size(grid)} {grid_height * grid_width}");
	print("Creating road");
	// generating road
	var init_grid = irandom(grid_height-1);
	var control_start = init_grid * grid_width;
	var control_end = (min(grid_height, max(0, init_grid + irandom_range(-2 * global.difficulty, 2 * global.difficulty))) * grid_width) - 1;
	control_path = a_star(grid, control_start, control_end, grid_width, a_star_heuristic); // holds grid values to generate control poitns
}

// stitch control path together to smooth
primary_count = array_length(control_path);
for (var s = 0; s < array_length(control_path); s++) {
	var xx = ((control_path[s] % grid_width) * control_points_dist) + (irandom(control_points_dist / 5) * choose(-1,1));
	var yy = ((control_path[s] div grid_width) * control_points_dist) + (irandom(control_points_dist / 5) * choose(-1,1));
	var zz = grid[|s] * 200 * global.difficulty;
	control_points[s] = new Point3D(xx, yy, zz);
}

// actually create road via catmull-rom
road_list = generate_roads(control_points, road_segments);

print("Rendering Road")
global.destination_road_index = round(array_length(road_list) * (max(0.2, global.difficulty - 1))) - (road_segments * 10);
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
var lane_change_duration = 50; //how many nodes until change to new lane
var lane_change_to = 3;//1+irandom(2); // change this side of road to this number of lanes
var cur_lane_change_to = lane_change_to; // current lane change for transition
var prev_lane_lane_to = lane_change_to; // previous lane change
var lane_side_affected = ROAD_LANE_CHANGE_AFFECT.BOTH; // which side of the road changes 
var cur_zone = choose(ZONE.SUBURBAN, ZONE.CITY, ZONE.DESERT, ZONE.RIVER);
var initial_river_seg = road_list[@ 0];//(cur_zone == ZONE.RIVER ? road_list[@ 0] : undefined);
var building_color = make_color_rgb(irandom(255), irandom(255), irandom(255));
for (var i = 0; i < array_length(road_list)-1; i++) {
	var road = road_list[@i];
	var next_road = road_list[@i+1];
	
	// road changes lane count
	if (lane_change_duration == 0) {
		prev_lane_lane_to = lane_change_to;
		lane_side_affected = choose(ROAD_LANE_CHANGE_AFFECT.LEFT, ROAD_LANE_CHANGE_AFFECT.RIGHT, ROAD_LANE_CHANGE_AFFECT.BOTH);
		lane_change_duration = 30+irandom(10);
		lane_change_to = 1+irandom(2);
		if (irandom(2) == 0) {
			cur_zone = choose(ZONE.SUBURBAN, ZONE.CITY, ZONE.DESERT, ZONE.RIVER);	// change zone
		}
		switch(road.zone) {
			case ZONE.RIVER:
				lane_change_to = 2+irandom(1);
				if (cur_zone == ZONE.RIVER) {
					initial_river_seg = road_list[@ i+1];
				}
				break;
			case ZONE.CITY:
				road.building_color = building_color;
				lane_change_to = 2+irandom(1);
				building_color = make_color_rgb(irandom(255), irandom(255), irandom(255));
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
	
	road.ideal_throttle = min(1.1, road.length / (control_points_dist / road_segments)) * (global.difficulty < 1.5 ? 0.9 : 1.01);
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
	
	if (lane_change_to != cur_lane_change_to) {
		cur_lane_change_to += sign(lane_change_to - prev_lane_lane_to) * 0.5;
		road.transition_lane = true;
	}
	
	if (road.zone != ZONE.DESERT and road.zone != ZONE.RIVER) {
		if (irandom(10) < 4) {
			if (road.transition_lane) {
				road.intersection = true;
			}
		}
	}

}

// post road generation adjustments
for (var i = 0; i < array_length(road_list)-1; i++) {
	var road = road_list[@i];
	var next_road = road_list[@i+1];
	var lane_change_dist = 1000;
	
	// extend road if lane changes
	//if (road.get_lanes() != next_road.get_lanes()) {
	//	track_length += lane_change_dist;
	//	road.length += lane_change_dist;
	//	road.length_to_point += lane_change_dist;
	//	for (var j = i+1; j < array_length(road_list)-1; j++) {
	//		var r = road_list[@j];
	//		road_list[@j].x += lengthdir_x(lane_change_dist, road.direction);
	//		road_list[@j].y += lengthdir_y(lane_change_dist, road.direction);
	//		road_list[@j].z += lengthdir_y(lane_change_dist, radtodeg(arcsin(road.elevation/road.length)));
	//	}
	//}
	
	// set road elevation
	road.elevation = arctan((road.z - next_road.z) / road.length);
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
	var adjust_beyond_shoulder_range = beyond_shoulder_range;
	
	vertex_begin(global.road_vertex_buffer, road_vertex_format);
	for (var i = ri_start; i < ri_end - 1; i++) {
		var road = road_list[@ i];
		var next_road = road_list[@ i + 1];
		
		var left_lanes = road.get_lanes_left();
		var right_lanes = road.get_lanes_right();
		var next_left_lanes = next_road.get_lanes_left();
		var next_right_lanes = next_road.get_lanes_right();
		var left_subimage = max(left_lanes, next_left_lanes)+1;
		var right_subimage = max(right_lanes, next_right_lanes)+1;
		var left_lane_sprite = (left_lanes != next_left_lanes) ? spr_road : spr_road;
		var right_lane_sprite = (right_lanes != next_right_lanes) ? spr_road : spr_road;
		var shoulder_uv = sprite_get_uvs(spr_road_shoulder, 0);
		var grass_uv = sprite_get_uvs(spr_grass, 0);
		var off_shoulder_z = road.z;
		var next_off_shoulder_z = next_road.z;
		
		road.beyond_range = [adjust_beyond_shoulder_range, adjust_beyond_shoulder_range];
		
		// change grass and shoulder texture
		switch(road.zone) {
			case ZONE.DESERT:
				shoulder_uv = sprite_get_uvs(spr_road_shoulder, 1);
				grass_uv = sprite_get_uvs(spr_grass, 2);
				break;
			case ZONE.CITY:
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
		
		// switch road texture during transition
		if (left_lanes != next_left_lanes) {left_subimage = next_left_lanes+5;}
		if (right_lanes != next_right_lanes) {right_subimage = next_right_lanes+5;}
		
		
		// setup water "grass" texture
		if (road.zone == ZONE.RIVER && next_road.zone != ZONE.RIVER) {
			off_shoulder_z = road.sea_level;
			next_off_shoulder_z = road.sea_level;
		}
		
		
		if (road.zone != ZONE.DESERT and road.zone != ZONE.RIVER) {
			if (road.transition_lane) {
				// create lane intersection
				shoulder_uv = sprite_get_uvs(spr_road_shoulder, 2);
				grass_uv = sprite_get_uvs(spr_road_side, 0);
				left_subimage = 0;
				right_subimage = 0;
				if (!next_road.transition_lane) {
					// far end
					grass_uv = sprite_get_uvs(spr_road_side, 2);
					left_subimage = 1;
					right_subimage = 1;
				}
			}
			else {
				if (next_road.transition_lane and road.zone != ZONE.RIVER) {
					left_subimage = 1;
					right_subimage = 1;
				}
			}
		}
		
		if (i == global.destination_road_index) {
			left_lane_sprite = spr_checkered;
			right_lane_sprite = spr_checkered;
			left_subimage = 0;
			right_subimage = 0;
		}
	
		var left_uv = texture_get_uvs(sprite_get_texture(left_lane_sprite, left_subimage));//sprite_get_uvs(left_lane_sprite, left_subimage);
		var right_uv = texture_get_uvs(sprite_get_texture(right_lane_sprite, right_subimage));//sprite_get_uvs(right_lane_sprite, right_subimage);
		var road_render_points = [
			 [
				road.x+lengthdir_x(lane_width*(left_lanes), road.direction+90),
				next_road.x+lengthdir_x(lane_width*(next_left_lanes), next_road.direction+90),
				next_road.x+lengthdir_x(lane_width*(next_right_lanes), next_road.direction-90),
				road.x+lengthdir_x(lane_width*(right_lanes), road.direction-90),
			],
			[
				road.y+lengthdir_y(lane_width*(left_lanes), road.direction+90),
				next_road.y+lengthdir_y(lane_width*(next_left_lanes), next_road.direction+90),
				next_road.y+lengthdir_y(lane_width*(next_right_lanes), next_road.direction-90),
				road.y+lengthdir_y(lane_width*(right_lanes), road.direction-90),
			]
		];
		var shoulder_coord = {
			left: [
				[road_render_points[0][0], road_render_points[1][0]],
				[road_render_points[0][1], road_render_points[1][1]],
				[road_render_points[0][1]+lengthdir_x(next_road.lane_width, next_road.direction+90), road_render_points[1][1]+lengthdir_y(next_road.lane_width, next_road.direction+90)],
				[road_render_points[0][0]+lengthdir_x(road.lane_width, road.direction+90), road_render_points[1][0]+lengthdir_y(road.lane_width, road.direction+90)],
			],
			right: [
				[road_render_points[0][2], road_render_points[1][2]],
				[road_render_points[0][3], road_render_points[1][3]],
				[road_render_points[0][3]+lengthdir_x(road.lane_width, road.direction-90), road_render_points[1][3]+lengthdir_y(road.lane_width, road.direction-90)],
				[road_render_points[0][2]+lengthdir_x(next_road.lane_width, next_road.direction-90), road_render_points[1][2]+lengthdir_y(next_road.lane_width, next_road.direction-90)]
			]
		}
		var grass_coord = {
			left: [
				shoulder_coord.left[0],
				shoulder_coord.left[1],
				[shoulder_coord.left[2][0]+lengthdir_x(adjust_beyond_shoulder_range, next_road.direction+90), shoulder_coord.left[2][1]+lengthdir_y(adjust_beyond_shoulder_range, next_road.direction+90)],
				[shoulder_coord.left[3][0]+lengthdir_x(adjust_beyond_shoulder_range, road.direction+90), shoulder_coord.left[3][1]+lengthdir_y(adjust_beyond_shoulder_range, road.direction+90)]
			],
			right: [
				shoulder_coord.right[0],
				shoulder_coord.right[1],
				[shoulder_coord.right[2][0]+lengthdir_x(adjust_beyond_shoulder_range, road.direction-90), shoulder_coord.right[2][1]+lengthdir_y(adjust_beyond_shoulder_range, road.direction-90)],
				[shoulder_coord.right[3][0]+lengthdir_x(adjust_beyond_shoulder_range, next_road.direction-90), shoulder_coord.right[3][1]+lengthdir_y(adjust_beyond_shoulder_range, next_road.direction-90)],
			]
		}
		#region Road Render Polygons
		var road_seg_data = [
			
			//left grass
			[new Point3D(grass_coord.left[0][0], grass_coord.left[0][1], off_shoulder_z-7), new Point(grass_uv[0], grass_uv[1])],
			[new Point3D(grass_coord.left[1][0], grass_coord.left[1][1], next_off_shoulder_z-7), new Point(grass_uv[2], grass_uv[1])],
			[new Point3D(grass_coord.left[2][0], grass_coord.left[2][1], next_off_shoulder_z), new Point(grass_uv[0], grass_uv[3])],
		
			[new Point3D(grass_coord.left[0][0], grass_coord.left[0][1], off_shoulder_z-7), new Point(grass_uv[2], grass_uv[1])],
			[new Point3D(grass_coord.left[2][0], grass_coord.left[2][1], next_off_shoulder_z), new Point(grass_uv[0], grass_uv[3])],
			[new Point3D(grass_coord.left[3][0], grass_coord.left[3][1], off_shoulder_z), new Point(grass_uv[2], grass_uv[3])],
			
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
			[new Point3D(grass_coord.right[0][0], grass_coord.right[0][1], next_off_shoulder_z-7), new Point(grass_uv[0], grass_uv[1])],
			[new Point3D(grass_coord.right[1][0], grass_coord.right[1][1], off_shoulder_z-7), new Point(grass_uv[2], grass_uv[1])],
			[new Point3D(grass_coord.right[2][0], grass_coord.right[2][1], off_shoulder_z), new Point(grass_uv[0], grass_uv[3])],
		
			[new Point3D(grass_coord.right[0][0], grass_coord.right[0][1], next_off_shoulder_z-7), new Point(grass_uv[2], grass_uv[1])],
			[new Point3D(grass_coord.right[2][0], grass_coord.right[2][1], off_shoulder_z), new Point(grass_uv[0], grass_uv[3])],
			[new Point3D(grass_coord.right[3][0], grass_coord.right[3][1], next_off_shoulder_z), new Point(grass_uv[2], grass_uv[3])],
			
		];
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
					[new Point3D(road.x+lengthdir_x(adjust_beyond_shoulder_range, road.direction-90), road.y+lengthdir_y(adjust_beyond_shoulder_range, road.direction-90), road.z), new Point(grass_uv[2], grass_uv[1])],
		
					[new Point3D(road.x, road.y, prev_road.sea_level), new Point(grass_uv[0], grass_uv[3])],
					[new Point3D(road.x+lengthdir_x(adjust_beyond_shoulder_range, road.direction-90), road.y+lengthdir_y(adjust_beyond_shoulder_range, road.direction-90), prev_road.sea_level), new Point(grass_uv[2], grass_uv[3])],
					[new Point3D(road.x+lengthdir_x(adjust_beyond_shoulder_range, road.direction-90), road.y+lengthdir_y(adjust_beyond_shoulder_range, road.direction-90), road.z), new Point(grass_uv[2], grass_uv[1])],
					
					
					[new Point3D(road.x, road.y, road.z), new Point(grass_uv[0], grass_uv[1])],
					[new Point3D(road.x+lengthdir_x(adjust_beyond_shoulder_range, road.direction+90), road.y+lengthdir_y(adjust_beyond_shoulder_range, road.direction+90), road.z), new Point(grass_uv[2], grass_uv[1])],
					[new Point3D(road.x, road.y, prev_road.sea_level), new Point(grass_uv[0], grass_uv[3])],
		
					[new Point3D(road.x, road.y, prev_road.sea_level), new Point(grass_uv[0], grass_uv[3])],
					[new Point3D(road.x+lengthdir_x(adjust_beyond_shoulder_range, road.direction+90), road.y+lengthdir_y(adjust_beyond_shoulder_range, road.direction+90), road.z), new Point(grass_uv[2], grass_uv[1])],
					[new Point3D(road.x+lengthdir_x(adjust_beyond_shoulder_range, road.direction+90), road.y+lengthdir_y(adjust_beyond_shoulder_range, road.direction+90), prev_road.sea_level), new Point(grass_uv[2], grass_uv[3])],
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

// create props, building
var prop_chain = 0;
//vertex_begin(global.prop_vertex_buffer, prop_vertex_format);
for (var i = 0; i < array_length(road_list) - 1; i++) {
	var road = road_list[@i];
	var next_road = road_list[@i+1];
	var left_lanes = road.get_lanes_left();
	var right_lanes = road.get_lanes_right();
	
	// create traffic lights at intersections
	if (road.intersection and !next_road.intersection) {
		var traffic_light = instance_create_layer(
			next_road.x + lengthdir_x((right_lanes+1) * lane_width, next_road.direction - 90),
			next_road.y + lengthdir_y((right_lanes+1) * lane_width, next_road.direction - 90),
			"Instances",
			obj_traffic_prop
		);
		traffic_light.image_xscale = 12;
		traffic_light.image_yscale = 12;
		traffic_light.image_index = 0;
		traffic_light.display_sprite_index = spr_traffic_light;
		traffic_light.display_image_index = 0;
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
	
	// prop chain 
	if (prop_chain > 0) {
		var len = choose(-left_lanes, 0, right_lanes) * road.lane_width;
		var prop_obj = instance_create_layer(
			road.x + lengthdir_x(len, road.direction-90),
			road.y + lengthdir_y(len, road.direction-90),
			"Instances",
			obj_traffic_prop
		);
		prop_obj.display_image_index = 1;
		prop_obj.z = road.z;
		prop_obj.image_xscale = 4;
		prop_obj.image_yscale = 24;
		prop_obj.direction = road.direction;
		array_push(road.props, prop_obj);
		
		prop_chain -= 1;
		if (prop_chain == 0) {
			prop_chain -= 15;
		}
	}
	else {
		prop_chain += 1;
		if (prop_chain == 0) {
			prop_chain = 3+irandom(3);
		}
	}
	
	// zone specific props
	switch(road.zone) {
		// create building
		case ZONE.CITY:	
			if (!road.transition_lane) {
				if (road.length * 0.75 > 32) {
					// create buildings
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
						building_obj.building_width = road.length * 0.75;
						building_obj.floors = 1 + irandom(1);
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
					tree_obj.direction = road.direction;
					array_push(road.props, tree_obj);
				}
			}
			break;
		case ZONE.DESERT:
			//create trees
			if (global.GAMEPLAY_TREES) {
				for (var tid = 0; tid < irandom(3); tid++) {
					var begin_length = choose(
						lane_width*(left_lanes+1) + irandom(beyond_shoulder_range),
						-lane_width*(right_lanes+1) - irandom(beyond_shoulder_range),
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
					tree_obj.direction = road.direction;
					array_push(road.props, tree_obj);
				}
			}
			break;
		default:
			// create trees
			if (global.GAMEPLAY_TREES) {
				if (road.zone != ZONE.RIVER) {
					for (var tid = 0; tid < irandom(50); tid++) {
						var begin_length = choose(
							lane_width*(left_lanes+2) + irandom(beyond_shoulder_range),
							-lane_width*(right_lanes+2) - irandom(beyond_shoulder_range),
						);
						var tree_obj = instance_create_layer(
							road.x + lengthdir_x(begin_length, road.direction + 90) + random_range(-32,32),
							road.y + lengthdir_y(begin_length, road.direction + 90) + random_range(-32,32),
							"Instances",
							obj_tree
						);
						tree_obj.display_image_index = irandom(8);
						tree_obj.z = road.z - irandom(32);
						tree_obj.assigned_cp = i div road_segments;
						
						tree_obj.direction = road.direction;
						array_push(road.props, tree_obj);
					}
				}
			}
			break;
	}
	
	//create light
	if (i % 5 == 0) {
		var side = [
			lane_width*(left_lanes+1),
			-lane_width*(right_lanes),
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
				obj_traffic_prop
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
			
			if (abs(angle) > 35) {
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
	if (road.zone != ZONE.RIVER) {
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
	else {
		choose_side = [0,1,2];
		left_lanes += 1;
		right_lanes += 1;
		next_left_lanes += 1;
		next_right_lanes += 1;
		railing_image = 1;
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

alarm[0] = 15;