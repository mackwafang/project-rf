
if (!use_billboard) {exit;}
if (abs(obj_road_generator.current_cp-assigned_cp) > 3) {exit;}

shader_set(shd_sprite_billboard);
matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, 0, render_scale.x, render_scale.y, render_scale.z));
// draw_surface_ext(render_surface, -32, 40, surface_scale[0], -surface_scale[1], 0, c_white, 1);
draw_sprite_ext(display_sprite_index, display_image_index, 0, 0, render_scale.x, -render_scale.y, 0, c_white, 1);
matrix_set(matrix_world, global.IDENTITY_MATRIX);
shader_reset();