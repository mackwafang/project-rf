shader_set(shd_sprite_billboard_color_replace);
matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, 0, 0.5, 0.5, 0.5));
shader_set_uniform_f(global.sbcr_color, true);
shader_set_uniform_f_array(global.sbcr_src_color, global.racer_color_replace_src);
shader_set_uniform_f_array(global.sbcr_dst_color, racer_color_replace_dst);
draw_sprite_ext(display_sprite_index, 0, 0, 0, 0.5, -0.625, 0, c_white, 1);
matrix_set(matrix_world, matrix_build_identity());
shader_reset();