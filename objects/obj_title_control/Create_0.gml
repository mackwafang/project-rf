global.display_freq = display_get_frequency();
game_set_speed(global.display_freq, gamespeed_fps);

level_options = [0, 0];
level_option_selected = 0;
LEVEL_OPTIONS_INDEX_DIFFICULTY = 0;
LEVEL_OPTIONS_INDEX_COURSE = 1;

global.difficulty = 1;
global.level = 1;
_level_distance = [5, 12, 20, 30, 35]; // estimated distance in kilometer
course_string = [
	"The City",
	"Sub-Urban",
	"The Desert",
	"Snake Trail",
	"Mountain View",
	"Seaside Freeway",
	"Chaos",
];

wait_timer = 0;
proceed_to_level = false;

init_data();