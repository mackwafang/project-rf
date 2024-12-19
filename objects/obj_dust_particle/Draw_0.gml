shader_set(shd_sprite_billboard);
matrix_set(matrix_world, matrix);
//vertex_submit(tree_vertex_buffer, pr_trianglelist, sprite_get_texture(sprite_index, image_index))
shader_set_uniform_f(global.color_replace_replace_color, false);
draw_sprite_ext(sprite_index, image_index, 0, 0, image_xscale, image_yscale, image_angle, color, image_alpha);
matrix_set(matrix_world, identity_matrix);
shader_reset();