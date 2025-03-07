function print(str) {
	show_debug_message(str);
}

function print_debug(str) {
	if (global.DEBUG_PRINT) {
		print(str);
	}
}

function get_course_weights(course) {
	switch(course) {
		case COURSES.CITY:
			return global.GAMEPLAY_COURSE_ZONE_WEIGHT.CITY;
		case COURSES.DESERT:
			return global.GAMEPLAY_COURSE_ZONE_WEIGHT.DESERT;
		case COURSES.SUBURBAN:
			return global.GAMEPLAY_COURSE_ZONE_WEIGHT.SUBURBAN;
		case COURSES.MOUNTAIN:
			return global.GAMEPLAY_COURSE_ZONE_WEIGHT.MOUNTAIN;
		case COURSES.HILL:
			return global.GAMEPLAY_COURSE_ZONE_WEIGHT.HILL;
		case COURSES.PACIFIC:
			return global.GAMEPLAY_COURSE_ZONE_WEIGHT.PACIFIC;
		case COURSES.RANDOM:
			return global.GAMEPLAY_COURSE_ZONE_WEIGHT.RANDOM;
		default:
			show_error(
				$"course {course} is not a known course to get weight data.\n"+
				"Check get_course_weights to see if course {course} has data"
			, true);
	}
}

function load_racer_names() {
	global.racer_names = [];
	filename = "random_first_names.csv";
	fd = file_text_open_read(working_directory + filename);
	while (!file_text_eof(fd)) {
		name = file_text_readln(fd);
		array_push(global.racer_names, name);
	}
}