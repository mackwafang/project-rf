global.display_freq = display_get_frequency();
game_set_speed(global.display_freq, gamespeed_fps);

level = 0;
global.difficulty = 1;
_level_distance = [5, 12, 20, 30, 35]; // distance in kilometer

wait_timer = 0;
proceed_to_level = false;

init_data();