
//if (vehicle_type == VEHICLE_TYPE.BIKE) {
//	draw_sprite_ext(spr_vehicle_shadow, 0, x, y, image_xscale, image_yscale, image_angle, c_white, 0.5);
//}
if (global.CAMERA_MODE_3D) {
	//matrix_set(matrix_world, matrix_build(x, y, z-10, 0, 0, 0, 1, 1, 1));
	//draw_sprite_ext(sprite_index, 0, 0, 0, image_xscale, image_yscale, image_angle, c_white, image_alpha);
	//matrix_set(matrix_world, matrix_build_identity());
	//var look_ahead_threshold = 256;
	//var look_ahead_angle = 10;
	//matrix_set(matrix_world, matrix_build(0, 0, z-20, 0, 0, 0, 1, 1, 1));
	//draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, image_angle, c_white, 1);
	//matrix_set(matrix_world, matrix_build_identity());
	
	shader_set(shd_sprite_billboard);
	shader_set_uniform_f(global.color_replace_replace_color, false);
	matrix_set(matrix_world, matrix_build(x+lengthdir_x(-4, image_angle), y+lengthdir_y(-4, image_angle), z, 0, 0, 0, 0.5, 0.5, 0.5));
	switch (vehicle_type) {
		case VEHICLE_TYPE.BIKE:
			var turn_adjust = 0;//clamp(turn_rate * 10, -20, 20) * (abs(turn_rate) > 0.1 ? 1 : 0);
			//if (vehicle_detail_index == spr_bike_3d_detail_2_turn && vehicle_detail_subimage == 0) {
			//	if (abs(turn_rate) > 0.075) {
			//		turn_adjust = -turn_rate * 30;
			//	}
			//}
			turn_adjust = -turn_rate * 30 / (max(1, vehicle_detail_subimage)*3);
			// draw_sprite_ext(spr_bike_3d, 0, 0, 0, 0.25, 0.25, (turn_adjust), c_white, image_alpha);
			//draw_sprite_ext(spr_bike_3d_detail, 0, 0, 0, 0.25, 0.25, (turn_adjust), vehicle_color.tetriary, image_alpha);
			//draw_sprite_ext(spr_bike_3d_detail, 1, 0, 0, 0.25, 0.25, (turn_adjust), vehicle_color.primary, image_alpha);
			//draw_sprite_ext(spr_bike_3d_detail, 2, 0, 0, 0.25, 0.25, (turn_adjust), vehicle_color.secondary, image_alpha);
			//draw_sprite_ext(spr_bike_3d_detail, 3, 0, 0, 0.25, 0.25, (turn_adjust), vehicle_color.tetriary, image_alpha);
			//draw_sprite_ext(spr_bike_3d_detail, 4, 0, 0, 0.25, 0.25, (turn_adjust), c_white, image_alpha);
			shader_set_uniform_f(global.color_replace_replace_color, true);
			shader_set_uniform_f_array(global.color_replace_src_color, global.racer_color_replace_src);
			shader_set_uniform_f_array(global.color_replace_dst_color, racer_color_replace_dst);
			draw_sprite_ext(vehicle_detail_index, vehicle_detail_subimage, 0, 0, 0.5 * image_xscale, -0.625, turn_adjust, c_white, 1);
			break;
		case VEHICLE_TYPE.CAR:
			draw_sprite_ext(spr_car_3d, vehicle_detail_subimage, 0, 0, 1, -1, 0, vehicle_color.primary, image_alpha);
			break;
	}
	matrix_set(matrix_world, matrix_build_identity());
	shader_reset();

	matrix_set(matrix_world, matrix_build(x, y, z - 0.5, 0, 0, image_angle+90, 1, 1, 1));
	draw_set_alpha(0.5);
	switch (vehicle_type) {
		case VEHICLE_TYPE.BIKE:
			vertex_submit(global.bike_shadow.buffer, pr_trianglestrip, sprite_get_texture(spr_bike_shadow_simple, 0));
			break;
		case VEHICLE_TYPE.CAR:
			vertex_submit(global.bike_shadow.buffer, pr_trianglestrip, sprite_get_texture(spr_car_shadow_simple, 0));
			break;
	}
	draw_set_alpha(1);
	matrix_set(matrix_world, matrix_build_identity());
}
else {
	draw_self();
}
//draw_sprite_ext(vehicle_detail_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, image_alpha);

if (global.DEBUG_CAR) {
	if (accelerating) {draw_circle_color(x+8, y-10, 4, c_green, c_green, false);}
	if (boosting) {draw_circle_color(x, y-10, 4, c_yellow, c_yellow, false);}
	if (braking) {draw_circle_color(x-8, y-10, 4, c_red, c_red, false);}
	
	
	draw_text_transformed_color(x + lengthdir_x(16, image_angle+180),y + lengthdir_y(16, image_angle+180),$"{round(velocity / 10)}/{round(max_velocity/10)}",1,1,image_angle-90,c_white,c_white,c_white,c_white,1)
	draw_text_transformed_color(x + lengthdir_x(32, image_angle+180),y + lengthdir_y(32, image_angle+180),gear,1,1,image_angle-90,c_white,c_white,c_white,c_white,1)
	draw_text_transformed_color(x + lengthdir_x(48, image_angle+180),y + lengthdir_y(48, image_angle+180),round(engine_rpm),1,1,image_angle-90,c_white,c_white,c_white,c_white,1)
	
	draw_arrow(x, y, x+lengthdir_x(engine_power * 32, image_angle), y+lengthdir_y(engine_power * 32, image_angle), 10);
	draw_arrow(x, y, x+lengthdir_x(turn_rate * 32, image_angle+90), y+lengthdir_y(turn_rate * 32, image_angle+90), 10);
	draw_text_transformed_color(x+lengthdir_x(turn_rate * 32, image_angle+90), y+lengthdir_y(turn_rate * 32, image_angle+90),turn_rate,1,1,image_angle-90,c_white,c_white,c_white,c_white,1)
	
	if (!on_road) {
		draw_text_transformed_color(
			x + lengthdir_x(-16, image_angle+90),
			y + lengthdir_y(-16, image_angle+90),
			"!",
			2,
			2,
			image_angle-90,
			c_red,
			c_red,
			c_red,
			c_red,
			1
		);
	}
}