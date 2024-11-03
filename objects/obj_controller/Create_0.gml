init_data();

cam_move_speed = 16;
cam_zoom = 1;
cam_angle = 0;
z = 50;

depth = -10000;

participating_vehicles = [];
global.total_participating_vehicles = 12;
global.gravity_3d = 9.8;
global.race_completed = false;
global.game_state_paused = false;
global.race_started = false;
global.race_timer = 0;
global.deltatime = delta_time / 1000000;
global.display_freq = display_get_frequency();
player_obj = noone;

// cam stuff
if (global.CAMERA_MODE_3D) {
	gpu_set_zwriteenable(true);
	gpu_set_ztestenable(true);
	gpu_set_alphatestenable(true);
	gpu_set_alphatestref(16);
	display_reset(0, true);
	init_bike_shadow_buffer();
}

game_set_speed(global.display_freq, gamespeed_fps);

instance_create_layer(0, 0, "Instances", obj_road_generator);

// racing car
for (var i = 0; i < global.total_participating_vehicles; i++) {
	var car = instance_create_layer(0, 0, "Instances", obj_racers);
	if (i == 0) {
		car.is_player = true;
		player_obj = car;
	}
	car.car_id = i+1;
	car.depth = 10;
	car.z = 100;
	car.vehicle_type = VEHICLE_TYPE.BIKE;
	car.ai_behavior.part_of_race = true;
	car.name = global.racer_names[irandom(array_length(global.racer_names)-1)];
	participating_vehicles[array_length(participating_vehicles)] = car;
}

for (var i = 0; i < array_length(participating_vehicles); i++) {
	var car = participating_vehicles[i];
	car.race_rank = (array_length(participating_vehicles) - i);
	var road = obj_road_generator.road_list[(i div 3) + 1];
	var lane_position_x = (((i % 3) / 3) * road.length);
	var lane_position_y = ((i % road.get_lanes_right()) * road.lane_width) + (road.lane_width / 2) + (random(road.lane_width / 2) * random_range(-1, 1));
	//var road = obj_road_generator.road_list[i + 1];
	//var lane_position_x = 0;
	//var lane_position_y = ((i % road.get_lanes_right()) * road.lane_width) + (road.lane_width / 2) + (random(road.lane_width / 2) * random_range(-1, 1));
	
	var dist = point_distance(road.x, road.y, road.x + lane_position_x, road.y + lane_position_y);
	var dir = point_direction(road.x, road.y, road.x + lane_position_x, road.y + lane_position_y) + road.direction;
	
	car.x = road.x + lengthdir_x(dist, dir);
	car.y = road.y + lengthdir_y(dist, dir);
	car.z = road.z + 10;
	car.direction = road.direction;
	car.can_move = false;
	car.mass = 200;
	car.horsepower = 30 * (power(global.difficulty, 4) / 6) + 20;
	car.ai_behavior.desired_lane = (i % road.get_lanes_right());
	car.on_road_index = road;
	car.on_road = true;
}
global.car_ranking = [];
array_copy(global.car_ranking, 0, participating_vehicles, 0, array_length(participating_vehicles));
debug_cam_obj = instance_create_layer(participating_vehicles[0].x, participating_vehicles[0].y, "Instances", obj_debug_cam);

if (!global.DEBUG_FREE_CAMERA) {
	if (global.CAMERA_MODE_3D) {
		main_camera_size = {width: 1024, height: 768,}
	}
	else {
		main_camera_size = {width: 480, height: 640,}
	}
	main_camera_target = participating_vehicles[0];
}
else {
	main_camera_size = {
		width: 640,
		height: 480,
	}
}
vehicle_current_pos_ping = 0;
// set camera size
participating_camera_index = 0;
main_camera = view_camera[view_current];
main_camera_pos = new Point3D(0, 0, 0);
main_camera_pos_to = new Point3D(0, 0, 0);
main_camera_pos_smooth = 0.05;

view_set_wport(0, main_camera_size.width);
view_set_hport(0, main_camera_size.height);

window_set_size(main_camera_size.width, main_camera_size.height);
camera_set_view_size(main_camera, main_camera_size.width, main_camera_size.height);
surface_resize(application_surface, main_camera_size.width, main_camera_size.height);
global.view_matrix = undefined;
global.projection_matrix = matrix_build_projection_perspective_fov(-100, -4/3, 1, 4000);

// sounds
var num = audio_get_listener_count();
for( var i = 0; i < num; i++) {
    var info = audio_get_listener_info(i);
    audio_set_master_gain(info[? "index"], 0.25);
    ds_map_destroy(info);
}
global.bkg_soundtrack = choose(
	snd_race_1,
	snd_race_2,
	snd_race_3,
	snd_race_4,
	snd_race_5
)

// background
global.bkg_sprite_index = spr_bkg_city;
switch(global.GAMEPLAY_COURSE) {
	case COURSES.CITY:
		global.bkg_sprite_index = spr_bkg_city;
		break;
	case COURSES.DESERT:
		global.bkg_sprite_index = spr_bkg_sky;
		break;
	case COURSES.MOUNTAIN: case COURSES.HILL:
		global.bkg_sprite_index = spr_bkg_mountain;
		break;
}

// outline shader setting
global.outline_shader_pixel_w = shader_get_uniform(shd_outline, "pixel_w");
global.outline_shader_pixel_h = shader_get_uniform(shd_outline, "pixel_h");
global.outline_shader_alpha_override = shader_get_uniform(shd_outline, "alpha_override");

// color replace shader setting
global.color_replace_replace_color = shader_get_uniform(shd_color_replace, "replace_color");
global.color_replace_src_color = shader_get_uniform(shd_color_replace, "src_color");
global.color_replace_dst_color = shader_get_uniform(shd_color_replace, "dst_color");
global.racer_color_replace_src = [
	1,			0,			33/255,
	148/255,	0,			0,
	74/255,		0,			0,
	1,			36/255,		107/255,
	1,			1,			1,
	74/255,		73/255,		107/255,
	74/255,		73/255,		74/255,
	181/255,	182/255,	222/255,
	148/255,	146/255,	181/255,
	74/255,		73/255,		171/255
];

// minimap
minimap_config = {
	border: 32,
	surface_width: 0,
	surface_height: 0,
	width: 200,
	height: 200,
	x: 256,
	y: 256,
	cache_created: false
}

if (global.DEBUG_DRAW_MINIMAP) {
	minimap_config.surface_width = minimap_config.border * obj_road_generator.grid_width;
	minimap_config.surface_height = minimap_config.border * obj_road_generator.grid_height;
	minimap_surface = surface_create(minimap_config.surface_width, minimap_config.surface_height);
	
	surface_set_target(minimap_surface);
	draw_clear_alpha(c_white, 0);
	surface_reset_target();
}

game_surface = surface_create(main_camera_size.width, main_camera_size.height);

cluck_init();

alarm[0] = round(6 * global.display_freq); // starting timer