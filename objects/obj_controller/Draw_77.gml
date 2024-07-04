if (!surface_exists(game_surface)) {
	game_surface = surface_create(main_camera_size.width, main_camera_size.height);
	surface_set_target(game_surface);
	draw_clear_alpha(c_white, 0);
	surface_reset_target();
}
var temp_surf = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));
shader_set(shd_game_world);
surface_copy(temp_surf, 0, 0, application_surface);
shader_reset();


// put background on blank surface
surface_set_target(game_surface);
draw_clear_alpha(c_white, 0);
var dir = (main_camera_target.image_angle / 360) * sprite_get_width(global.bkg_sprite_index);
draw_sprite_ext(global.bkg_sprite_index, 0, dir, 0, 1, 1, 0, c_white, 1);
draw_sprite_ext(global.bkg_sprite_index, 0, dir, 0, -1, 1, 0, c_white, 1);
surface_reset_target();

// put everything else on blank surface now with cloud
surface_copy(game_surface, 0, 0, temp_surf);

// put blank surface with cloud and game back
surface_copy(application_surface, 0, 0, game_surface);

surface_free(temp_surf);