// debuging camera
//if (keyboard_check(ord("W"))) {y -= cam_move_speed;}
//if (keyboard_check(ord("S"))) {y += cam_move_speed;}
//if (keyboard_check(ord("A"))) {x -= cam_move_speed;}
//if (keyboard_check(ord("D"))) {x += cam_move_speed;}
if (keyboard_check(vk_space)) {z -= 1;}
if (keyboard_check(vk_control)) {z += 1;}
if (keyboard_check(ord("Q"))) {
	if (global.DEBUG_FREE_CAMERA) {
		cam_angle -= 5;
	}
}
if (keyboard_check_pressed(ord("Q"))) {
	if (!global.DEBUG_FREE_CAMERA) {
		participating_camera_index = (participating_camera_index + 1) % array_length(participating_vehicles);
	}
}
if (keyboard_check(ord("E"))) {
	if (global.DEBUG_FREE_CAMERA) {
		cam_angle += 5;
	}
}if (keyboard_check_pressed(ord("E"))) {
	if (!global.DEBUG_FREE_CAMERA) {
		participating_camera_index = (participating_camera_index - 1 < 0) ? array_length(participating_vehicles)-1 : participating_camera_index - 1;
	}
}
//if (mouse_wheel_up()) {cam_zoom += 2;}
//if (mouse_wheel_down()) {cam_zoom -= 2;}

// play music
if (alarm[0] == global.display_freq * 3) {
	audio_play_sound(global.bkg_soundtrack, 128, false);
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
		audio_play_sound(global.bkg_soundtrack, 128, false);
	}
}

// other controls
if (keyboard_check_pressed(vk_escape)) {
	global.game_state_paused = !global.game_state_paused;
}

main_camera_target = participating_vehicles[participating_camera_index];

if (!global.DEBUG_FREE_CAMERA) {
	// normal game camera
	if (!global.CAMERA_MODE_3D) {
		camera_set_view_pos(
			main_camera,
			main_camera_target.x - (main_camera_size.width/2) + lengthdir_x(main_camera_size.width * 0.45, main_camera_target.image_angle),
			main_camera_target.y - (main_camera_size.height/2) + lengthdir_y(main_camera_size.width * 0.45, main_camera_target.image_angle)
		);
		camera_set_view_angle(main_camera, -main_camera_target.image_angle+90);
	}
	else {
		//var speed_zoom = (main_camera_target.velocity / main_camera_target.max_velocity) * 280;
		
		//main_camera_pos.x += (main_camera_target.x+lengthdir_x(-60+cam_zoom+speed_zoom, main_camera_target.image_angle) - main_camera_pos.x) * main_camera_pos_smooth;
		//main_camera_pos.y += (main_camera_target.y+lengthdir_y(-60+cam_zoom+speed_zoom, main_camera_target.image_angle) - main_camera_pos.y) * main_camera_pos_smooth;
		main_camera_pos.z += (main_camera_target.z - main_camera_pos.z + z) * main_camera_pos_smooth * 2;
		
		main_camera_pos.x = main_camera_target.x+lengthdir_x(-60+cam_zoom, main_camera_target.image_angle);
		main_camera_pos.y = main_camera_target.y+lengthdir_y(-60+cam_zoom, main_camera_target.image_angle);
		//main_camera_pos.z = main_camera_target.z + z;
		
		main_camera_pos_to.x = main_camera_target.x+lengthdir_x(500, main_camera_target.image_angle);
		main_camera_pos_to.y = main_camera_target.y+lengthdir_y(500, main_camera_target.image_angle);
		main_camera_pos_to.z = main_camera_target.z+z-120;
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
			main_camera_target.x = obj_road_generator.road_list[0].x;
			main_camera_target.y = obj_road_generator.road_list[0].y;
			main_camera_target.z = obj_road_generator.road_list[0].z;
			//main_camera_target._z_restrict = false;
		}
	}
}
else {
	// debug camera
	camera_set_view_pos(
		main_camera,
		x,
		y
	);
	camera_set_view_size(main_camera, main_camera_size.width / cam_zoom, main_camera_size.height / cam_zoom);
	camera_set_view_angle(main_camera, cam_angle);
	cam_zoom = clamp(cam_zoom, 0.1, 10);
}

if (global.game_state_paused) {exit;}
// other car spawning
if (global.GAMEPLAY_CARS) {
	var road_at_view_edge = obj_road_generator.road_list[max(0, main_camera_target.on_road_index._id + choose(-10,10))];
	if (alarm[0] == -1) {
		if (irandom(100 / global.difficulty) < 1 and instance_number(obj_car) < 10) {
			var side = choose(-1, 1);
			var road_function = (side == -1 ? road_at_view_edge.get_lanes_left : road_at_view_edge.get_lanes_right);
			
			var spawn_lane = (irandom_range(0, road_function()) + 0.5) * side;
			var spawn_x = road_at_view_edge.x + lengthdir_x(road_at_view_edge.lane_width * spawn_lane, road_at_view_edge.direction - 90);
			var spawn_y = road_at_view_edge.y + lengthdir_y(road_at_view_edge.lane_width * spawn_lane, road_at_view_edge.direction - 90);
			
			var car = instance_create_layer(spawn_x, spawn_y, "Instances", obj_car);
			print($"spawned object {car.id} (part_of_race: {car.ai_behavior.part_of_race}, reverse: {car.ai_behavior.reversed_direction})");
			car.rpm = 5000;
			car.max_velocity = 400 + (global.difficulty * 400);
			car.velocity = car.max_velocity;
			
			car.nav_road = road_at_view_edge;
			car.on_road_index = road_at_view_edge;
			car.last_road_index = road_at_view_edge.get_id();
			
			car.horsepower = 30;
			car.max_gear = 2;
			car.z = road_at_view_edge.z + 10;
			if (side == -1) {
				car.ai_behavior.reversed_direction = true;
			}
			car.ai_behavior.desired_lane = irandom(road_function() - 1) * side;
			car.direction = road_at_view_edge.direction + (side == -1 ? -180 : 0);
		}
	}
}

// race timer
if (alarm[0] < 0) {
	global.race_timer += delta_time / 1000000;
}