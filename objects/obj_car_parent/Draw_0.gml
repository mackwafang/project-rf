
//if (vehicle_type == VEHICLE_TYPE.BIKE) {
//	draw_sprite_ext(spr_vehicle_shadow, 0, x, y, image_xscale, image_yscale, image_angle, c_white, 0.5);
//}
if (global.CAMERA_MODE_3D) {
	
	// color replace
	if (!surface_exists(render_surface)) {
		render_surface = surface_create(128, 64);
	}
	surface_set_target(render_surface);
	draw_clear_alpha(c_white, 0);
	shader_set(shd_color_replace);
	shader_set_uniform_f(global.color_replace_replace_color, false);
	var surface_scale = [1, 1];
	switch (vehicle_type) {
		case VEHICLE_TYPE.BIKE:
			var turn_adjust = 0;//clamp(turn_rate * 10, -20, 20) * (abs(turn_rate) > 0.1 ? 1 : 0);

			turn_adjust = -turn_rate * 30 / (max(1, vehicle_detail_subimage)*3);
			shader_set_uniform_f(global.color_replace_replace_color, true);
			shader_set_uniform_f_array(global.color_replace_src_color, global.racer_color_replace_src);
			shader_set_uniform_f_array(global.color_replace_dst_color, racer_color_replace_dst);
			draw_sprite_ext(vehicle_detail_index, vehicle_detail_subimage, 64, 64, image_xscale, 1, turn_adjust, c_white, 1);
			surface_scale = [0.5, 0.625];
			break;
		case VEHICLE_TYPE.CAR:
			draw_sprite_ext(vehicle_detail_index, vehicle_detail_subimage, 32, 48, 1, 1, 0, vehicle_color.primary, 1);
			break;
	}
	surface_reset_target();
	shader_reset();
	
	// vertex buffer for rendering
	var w = sprite_get_width(vehicle_detail_index) * 0.5;
	var h = sprite_get_height(vehicle_detail_index) * 0.625;
	var tex = surface_get_texture(render_surface);
	var uv = texture_get_uvs(tex);
	var x0 = x + lengthdir_x(w, direction+90);
	var y0 = y + lengthdir_y(w, direction+90);
	var x1 = x + lengthdir_x(w, direction-90);
	var y1 = y + lengthdir_y(w, direction-90);
	
	vertex_delete_buffer(vehicle_vertex_buffer);
	vehicle_vertex_buffer = vertex_create_buffer();

	vertex_begin(vehicle_vertex_buffer, vehicle_vertex_format);
	vertex_position_3d_uv(vehicle_vertex_buffer, x0, y0, z+h	, uv[0], uv[1]);
	vertex_position_3d_uv(vehicle_vertex_buffer, x0, y0, z		, uv[0], uv[3]);
	vertex_position_3d_uv(vehicle_vertex_buffer, x1, y1, z+h	, uv[2], uv[1]);
	
	vertex_position_3d_uv(vehicle_vertex_buffer, x1, y1, z+h, uv[2], uv[1]);
	vertex_position_3d_uv(vehicle_vertex_buffer, x0, y0, z, uv[0], uv[3]);
	vertex_position_3d_uv(vehicle_vertex_buffer, x1, y1, z, uv[2], uv[3]);
	vertex_end(vehicle_vertex_buffer);
	vertex_freeze(vehicle_vertex_buffer);
	
	// sprite billboard
	//shader_set(shd_sprite_billboard);
	//matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, 0, 0.5, 0.5, 0.5));
	// draw_surface_ext(render_surface, -32, 40, surface_scale[0], -surface_scale[1], 0, c_white, 1);
	// vertex_submit(vehicle_vertex_buffer, pr_trianglelist, tex);
	//matrix_set(matrix_world, global.IDENTITY_MATRIX);
	//shader_reset();
	
	
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
	matrix_set(matrix_world, global.IDENTITY_MATRIX);
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