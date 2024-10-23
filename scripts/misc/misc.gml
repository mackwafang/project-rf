function print(str) {
	show_debug_message(str);
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
	}
}