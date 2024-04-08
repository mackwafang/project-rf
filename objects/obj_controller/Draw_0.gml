//if (global.CAMERA_MODE_3D) {
//	//shader_set(shd_lighting);
//	//shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_LightPosition"), 0, 0, 0);
//	//shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_LightRadius"), 1000);
//	//shader_set_uniform_f(shader_get_uniform(shd_lighting, "u_ViewPosition"), main_camera_pos.x, main_camera_pos.y, main_camera_pos.z);
	
//	matrix_set(matrix_world, matrix_build(main_camera_target.x, main_camera_target.y, main_camera_target.z + 50, 0, 0, 0, 2.5, 2.5, 2.5));
//	var tex = sprite_get_texture(spr_cloud, 0);
//	vertex_submit(skybox_vertex_buffer, pr_trianglelist, tex);
//	matrix_set(matrix_world, matrix_build_identity());
//	//shader_reset();
//}
