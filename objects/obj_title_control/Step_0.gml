if (keyboard_check_pressed(vk_left)) {level_options[level_option_selected] -= 1;}
if (keyboard_check_pressed(vk_right)) {level_options[level_option_selected] += 1;}
if (keyboard_check_pressed(vk_up)) {level_option_selected -= 1;}
if (keyboard_check_pressed(vk_down)) {level_option_selected += 1;}
level_options[LEVEL_OPTIONS_INDEX_DIFFICULTY] = modulo(level_options[LEVEL_OPTIONS_INDEX_DIFFICULTY], 5);
level_options[LEVEL_OPTIONS_INDEX_COURSE] = modulo(level_options[LEVEL_OPTIONS_INDEX_COURSE], array_length(course_string));
level_option_selected = modulo(level_option_selected, array_length(level_options));

if (keyboard_check_pressed(vk_space)) {
	proceed_to_level = true;
}

if (proceed_to_level) {
	wait_timer += 1;
	if (wait_timer >= 3 * global.display_freq) {
		global.level = level_options[LEVEL_OPTIONS_INDEX_DIFFICULTY];
		global.difficulty = global.LEVEL_TO_DIFFICULTY[level_options[LEVEL_OPTIONS_INDEX_DIFFICULTY]];
		global.gameplay_course = level_options[LEVEL_OPTIONS_INDEX_COURSE];
		room_goto_next();
	}
}
else {
	if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right)) {audio_play_sound(snd_menu_select, 0, false);}
}

global.display_freq = display_get_frequency();