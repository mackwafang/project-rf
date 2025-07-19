
//if (vehicle_type == VEHICLE_TYPE.BIKE) {
//	draw_sprite_ext(spr_vehicle_shadow, 0, x, y, image_xscale, image_yscale, image_angle, c_white, 0.5);
//}
if (global.CAMERA_MODE_3D) {
	
	// color replace
	shader_set(shd_sprite_billboard_color_replace);
	shader_set_uniform_f(global.sbcr_color, false);
	matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, 0, 1, 1, 1));
	switch (vehicle_type) {
		case VEHICLE_TYPE.BIKE:
			shader_set_uniform_f(global.sbcr_color, true);
			shader_set_uniform_f_array(global.sbcr_src_color, global.racer_color_replace_src);
			shader_set_uniform_f_array(global.sbcr_dst_color, racer_color_replace_dst);
			draw_sprite_ext(vehicle_detail_index, vehicle_detail_subimage, 0, 0, image_xscale*0.6, -0.6, -turn_rate*10, c_white, 1);
			break;
		case VEHICLE_TYPE.CAR:
			// draw_sprite_ext(vehicle_detail_index, vehicle_detail_subimage, 64, 64, image_xscale, 1, 0, vehicle_color.primary, 1);
			draw_sprite_ext(spr_car_3d, vehicle_detail_subimage, 0, 0, 1, -1, 0, c_white, 1);
			break;
	}
	matrix_set(matrix_world, global.IDENTITY_MATRIX);
	shader_reset();
	//update_vertex_buffer();
	//// sprite billboard
	//shader_set(shd_sprite_billboard);
	//matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, 0, 0.5, 0.5, 0.5));
	//draw_surface_ext(render_surface, -32, 40, surface_scale[0], -surface_scale[1], 0, c_white, 1);
	//matrix_set(matrix_world, global.IDENTITY_MATRIX);
	//shader_reset();
	
	
	matrix_set(matrix_world, matrix_build(x, y, zlerp - 0.5, 0, 0, image_angle+90, 1, 1, 1));
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
	matrix_set(matrix_world, global.IDENTITY_MATRIX);
}
else {
	draw_self();
}

if (global.DEBUG_CAR) {
	if (accelerating) {draw_circle_color(x+8, y-10, 4, c_green, c_green, false);}
	if (boosting) {draw_circle_color(x, y-10, 4, c_yellow, c_yellow, false);}
	if (braking) {draw_circle_color(x-8, y-10, 4, c_red, c_red, false);}
	
	
	draw_text_transformed_color(x + lengthdir_x(16, image_angle+180),y + lengthdir_y(16, image_angle+180),$"{round(velocity / 10)}/{round(max_velocity/10)}",1,1,image_angle-90,c_white,c_white,c_white,c_white,1);
	draw_text_transformed_color(x + lengthdir_x(32, image_angle+180),y + lengthdir_y(32, image_angle+180),gear,1,1,image_angle-90,c_white,c_white,c_white,c_white,1)
	draw_text_transformed_color(x + lengthdir_x(48, image_angle+180),y + lengthdir_y(48, image_angle+180),round(engine.rpm),1,1,image_angle-90,c_white,c_white,c_white,c_white,1)
	
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