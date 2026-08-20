randomize();
// random_set_seed(1);
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
generation_progress = {
	initial: {current: 0, max: 0},
	setup: {current: 0, max: 0},
	prop: {current: 0, max: 0},
	touchup: {current: 0, max: 0},
}
generation_completed = false;
var t = current_time;

// initialize control points using path finding via a-star
grid_width = 270;//round(24 * sqr(global.difficulty * 1.5));
grid_height = 270;//round(24 * sqr(global.difficulty * 1.5));
grid = ds_list_create();
// intialize random weights for grids
for (var i = 0; i < grid_height*grid_width; i++) {ds_list_add(grid, 0);}

control_path = [];

// generating level
// get level data (tileset, tileset weight, curviness, etc)
var course_data = get_course_weights(global.gameplay_course);
var curve_modifier = 0.4;
switch (global.gameplay_course) {
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
// generate perlin noise and find select one square on column 0 and find fastest path to a square on column grid_width
while (array_length(control_path) == 0) {
	print("Creating grid");
	// generating terrain
	perlin_config = {
		inc: global.difficulty * curve_modifier / 10,	// determines rough ness of noise. higher = more noise
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
	print($"{ds_list_size(grid)} =? {grid_height * grid_width}");
	print("Creating road");
	// get the fastest grid pah
	var init_grid = irandom(grid_height-1);
	var control_start = init_grid * grid_width;
	var control_end = (min(grid_height, max(0, init_grid + irandom_range(-20 * global.difficulty, 20 * global.difficulty))) * grid_width) - 1;
    
    print($"start grid: {control_start} | end grid: {control_end}");
	control_path = a_star(grid, control_start, control_end, grid_width, a_star_heuristic); // holds grid values to generate control poitns
}

// convert control_path coordinates to game world cordinates
primary_count = array_length(control_path);
for (var s = 0; s < array_length(control_path); s++) {
	var rand_x = 0;
	var rand_y = 0;
	if (!global.DEBUG_STRAIGHT_MAP) {
		rand_x = (irandom(control_points_dist / 6) * choose(-1,1));
		rand_y = (irandom(control_points_dist / 6) * choose(-1,1));
	}
	var xx = ((control_path[s] % grid_width) * control_points_dist) + rand_x;
	var yy = ((control_path[s] div grid_width) * control_points_dist) + rand_y;
	var zz = (grid[|s] * course_data.Z_ROUGHNESS * global.difficulty * 3) + 500;
	control_points[s] = new Point3D(xx, yy, zz);
	generation_progress.initial.current += 1;
}

// generate off road control points
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
	
	generation_progress.initial.current += 1;
}

// actually create road nodes from control nodes
road_list = generate_roads(control_points, road_segments);
road_offset_list = {
	left: generate_roads(control_points_offset.left, road_segments),
	right: generate_roads(control_points_offset.right, road_segments),
}


// look back at previous nodes, if this node intersects with a previous, set the road's offset coordinate at the intersect to avoid overlap during sharp turns
for (var s = 0; s < array_length(road_list); s++) {
	var road = road_list[s];
	
	for (var i = 0; i < 10; i++) {
		var index = s-i;
		var left_offset_point = road_offset_list.left[s];
		var right_offset_point = road_offset_list.right[s];
		if (index < 0) {continue;}
		
		var prev_road = road_list[index];
		var prev_left_offset_point = road_offset_list.left[index];
		var prev_right_offset_point = road_offset_list.right[index];
		var left_intersect_info = lines_intersect(
			road.x, road.y, 
			left_offset_point.x, left_offset_point.y, 
			prev_road.x, prev_road.y,
			prev_left_offset_point.x, prev_left_offset_point.y
		);
		var right_intersect_info = lines_intersect(
			road.x, road.y, 
			right_offset_point.x, right_offset_point.y, 
			prev_road.x, prev_road.y,
			prev_right_offset_point.x, prev_right_offset_point.y
		);
		
		if (left_intersect_info.intersect) {
			left_offset_point.x = left_intersect_info.x;
			left_offset_point.y = left_intersect_info.y;
			left_offset_point.z = prev_left_offset_point.z;
			break;
		}
		if (right_intersect_info.intersect) {
			right_offset_point.x = right_intersect_info.x;
			right_offset_point.y = right_intersect_info.y;
			right_offset_point.z = prev_right_offset_point.z;
			break;
		}
	}
}

print("Rendering Road");
var race_length_modifier = [1.5, 1.7, 0.9, 0.7, 1]; // modifier to increase lnegth based on difficulty
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

level_generator_setup();
level_generator_create_props();


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

generation_completed = true;

show_debug_message($"road generation completed in {current_time - t}ms");
show_debug_message($"global.road_vertex_buffer has {vertex_get_buffer_size(global.road_vertex_buffer)} bytes");
show_debug_message($"building_vertex_buffer has {vertex_get_buffer_size(global.building_vertex_buffer)} bytes");

vehicle_current_pos_ping = 0;

alarm[0] = 30;