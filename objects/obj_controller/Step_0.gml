if (keyboard_check(vk_space)) {
	if (global.DEBUG_FREE_CAMERA) {z -= 1;}
}
if (keyboard_check(vk_control)) {
	if (global.DEBUG_FREE_CAMERA) {z += 1;}
}

if (keyboard_check_pressed(global.DEBUG_HOTKEY.GAME_RESTART)) {
	if (global.DEBUG_GAME_RESTART_KEY_ENABLE) {
		game_restart();
	}
}
if (keyboard_check_pressed(ord("Q"))) {
	if (global.DEBUG_FREE_CAMERA) {
		participating_camera_index = (participating_camera_index + 1) % array_length(participating_vehicles);
		main_camera_target = participating_vehicles[participating_camera_index];
	}
}
if (keyboard_check_pressed(ord("E"))) {
	if (global.DEBUG_FREE_CAMERA) {
		participating_camera_index = (participating_camera_index - 1 < 0) ? array_length(participating_vehicles)-1 : participating_camera_index - 1;
		main_camera_target = participating_vehicles[participating_camera_index];
	}
}

// hotkey to quickly swich display mode
if (keyboard_check_pressed(global.game_settings.keybinds.display_mode_change)) {
    var default_window_size = new Rect(1024, 768); 
    var display_size = new Rect(
        display_get_width(),
        display_get_height()
    );
    var fullscreen_size = new Rect(
        default_window_size.width * (display_size.width / default_window_size.width),
        default_window_size.height * (display_size.height / default_window_size.height)
    );
    print(fullscreen_size);
    global.game_settings.display_mode = (global.game_settings.display_mode+1) % 2;
    
    switch(global.game_settings.display_mode) {
        case GAME_DISPLAY_MODE.WINDOWED:
            window_set_fullscreen(false);
            window_enable_borderless_fullscreen(false);
            global.game_settings.display_mode_size.width = default_window_size.width;
            global.game_settings.display_mode_size.height = default_window_size.height;
            break;
        //case GAME_DISPLAY_MODE.FULLSCREEN:
            //window_set_fullscreen(true);
            //window_enable_borderless_fullscreen(false);
            //global.game_settings.display_mode_size.width = default_window_size.width * (display_size.width / default_window_size.width);
            //global.game_settings.display_mode_size.height = default_window_size.height * (display_size.height / default_window_size.height);
            //break;
        case GAME_DISPLAY_MODE.BORDERLESS:
            window_set_fullscreen(true);
            window_enable_borderless_fullscreen(true);
            global.game_settings.display_mode_size.width = fullscreen_size.width;
            global.game_settings.display_mode_size.height = fullscreen_size.height;
            break;
    }    
    
    main_camera_size = {
        width: global.game_settings.display_mode_size.width, 
        height: global.game_settings.display_mode_size.height,
    }
    
    view_set_wport(0, default_window_size.width);
    view_set_hport(0, default_window_size.height);
    
    camera_set_view_size(main_camera, main_camera_size.width, main_camera_size.height);
    window_set_size(main_camera_size.width, main_camera_size.height);
    surface_resize(application_surface, main_camera_size.width, main_camera_size.height);

}

//if (mouse_wheel_up()) {cam_zoom += 2;}
//if (mouse_wheel_down()) {cam_zoom -= 2;}
if (keyboard_check_pressed(vk_f6)) {
	// switches to debug camera
	if (global.DEBUG_FREE_CAMERA) {
		switch (main_camera_target.object_index) {
			case obj_racers:
				main_camera_target = debug_cam_obj;
				break;
			case debug_cam_obj:
				main_camera_target = participating_vehicles[participating_camera_index];
				break;
		}
	}
}

if (keyboard_check_pressed(vk_f11)) {
	global.gameplay_race_interface_mode = ((global.gameplay_race_interface_mode+1) mod 3);
}


// play music
if (alarm[0] == global.display_freq * 3) {
	audio_play_sound(global.bkg_soundtrack, 128, false, 3);
}
if (global.race_started) {
	if (!audio_is_playing(global.bkg_soundtrack)) {
		global.bkg_soundtrack = choose(
			snd_race_1,
			snd_race_2,
			snd_race_3,
			snd_race_4,
			snd_race_5
		)
		audio_play_sound(global.bkg_soundtrack, 128, false, 3);
	}
}

// other controls
if (keyboard_check_pressed(vk_escape)) {
	global.game_state_paused = !global.game_state_paused;
}

var speed_zoom = (main_camera_target.velocity / main_camera_target.max_velocity);

var cam_dist = point_distance(main_camera_pos.x, main_camera_pos.y, main_camera_target.x, main_camera_target.y);
//main_camera_pos.x += ((main_camera_target.x - main_camera_pos.x) + lengthdir_x(min(-60+cam_zoom, cam_dist), main_camera_target.image_angle)) * main_camera_pos_smooth;
//main_camera_pos.y += ((main_camera_target.y - main_camera_pos.y) + lengthdir_y(min(-60+cam_zoom, cam_dist), main_camera_target.image_angle)) * main_camera_pos_smooth;
main_camera_pos.z += (main_camera_target.z - main_camera_pos.z + z) * main_camera_pos_smooth * 2;

main_camera_pos.x = main_camera_target.x+lengthdir_x(-60+cam_zoom, main_camera_target.image_angle);
main_camera_pos.y = main_camera_target.y+lengthdir_y(-60+cam_zoom, main_camera_target.image_angle);
//main_camera_pos.z = main_camera_target.z + z;

main_camera_pos_to.x = main_camera_target.x+lengthdir_x(500, main_camera_target.image_angle);
main_camera_pos_to.y = main_camera_target.y+lengthdir_y(500, main_camera_target.image_angle);
main_camera_pos_to.z = main_camera_target.z+z-120;

var cam_direction = point_direction(
    main_camera_pos.x,
    main_camera_pos.y,
    main_camera_pos_to.x,
    main_camera_pos_to.y
);
audio_listener_position(main_camera_pos.x, main_camera_pos.y, main_camera_pos.z);
audio_listener_orientation(dcos(cam_direction), dsin(cam_direction), 0, 0, 0, 1);
gpu_set_zwriteenable(false);
global.view_matrix = matrix_build_lookat(
    main_camera_pos.x,
    main_camera_pos.y,
    main_camera_pos.z,
    main_camera_pos_to.x,
    main_camera_pos_to.y,
    main_camera_pos_to.z,
    0, 0, 1
);
camera_set_view_mat(main_camera, global.view_matrix);
camera_set_proj_mat(main_camera, global.projection_matrix);

camera_apply(main_camera);
gpu_set_zwriteenable(true);

// keep keep camera fixed or move away when finished
if (main_camera_target.is_completed) {
    cam_zoom -= 0.25;
    z += 0.125;
    cam_zoom = clamp(cam_zoom, -300, 10);
    z = clamp(z, 0, 300);
    
    if (cam_zoom == -300) {
        clean_level();
        room_goto(rm_title);
    }
}
if (keyboard_check_pressed(ord("R"))) {
    main_camera_target.x = 0;//obj_road_generator.road_list[0].x;
    main_camera_target.y = 0;//obj_road_generator.road_list[0].y;
    main_camera_target.z = 0;//obj_road_generator.road_list[0].z;
    //main_camera_target._z_restrict = false;
}

if (global.game_state_paused) {exit;}
// other car spawning
if (global.GAMEPLAY_CARS) {
    var road_edge_index = max(0, main_camera_target.on_road_index._id + choose(-15,15));
	var road_at_view_edge = obj_road_generator.road_list[road_edge_index];
	var zone_modifier = 1;
	switch(road_at_view_edge.zone) {
		case ZONE.CITY: case ZONE.TOWN: case ZONE.BEACH:
			zone_modifier = 0.25;
			break;
		case ZONE.SUBURBAN:
			zone_modifier = 1;
			break;
		case ZONE.DESERT:
			zone_modifier = 2;
			break;
		case ZONE.FOREST: case ZONE.MOUNTAIN:
			zone_modifier = 2;
			break;
	}
	if (alarm[0] == -1 and road_at_view_edge.get_id() > 30) {
		if (irandom(120 / global.difficulty * zone_modifier) < 1 and instance_number(obj_car_parent) < 25) {
			var side = choose(-1, 1);
			var road_function = (side == -1 ? road_at_view_edge.get_lanes_left : road_at_view_edge.get_lanes_right);
			
			var spawn_lane = (irandom_range(0, road_function()) + 0.5) * side;
			var spawn_x = road_at_view_edge.x + lengthdir_x(road_at_view_edge.lane_width * spawn_lane, road_at_view_edge.direction - 90);
			var spawn_y = road_at_view_edge.y + lengthdir_y(road_at_view_edge.lane_width * spawn_lane, road_at_view_edge.direction - 90);
			
			var car = instance_create_layer(spawn_x, spawn_y, "Instances", obj_car);
			car.rpm = 3000;
			car.max_velocity = 400;// + (global.difficulty * 400);
			car.velocity = car.max_velocity;
			
			car.on_road_index = road_at_view_edge;
			car.last_road_index = road_at_view_edge.get_id();
			
			car.horsepower = 30;
			car.max_gear = 2;
			car.z = road_at_view_edge.z + 10;
			car.on_road = true;
			car.vertical_on_road = true;
			if (side == -1) {
				car.ai_behavior.reversed_direction = true;
			}
			car.ai_behavior.desired_lane = irandom(road_function() - 1) * side;
			car.direction = road_at_view_edge.direction + (side == -1 ? 180 : 0);
			car.image_angle = direction;
            // print($"spawned object {car.id} (part_of_race: {car.ai_behavior.part_of_race}, reverse: {car.ai_behavior.reversed_direction}), vehicle count: {instance_number(obj_car_parent)} (25)");
		}
	}
}

// race timer
if (alarm[0] < 0) {
	global.race_timer += delta_time / 1000000;
}