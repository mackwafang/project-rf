global.display_freq = display_get_frequency();
game_set_speed(global.display_freq, gamespeed_fps);

level = 0;
global.difficulty = 1;

wait_timer = 0;
proceed_to_level = false;

init_data();