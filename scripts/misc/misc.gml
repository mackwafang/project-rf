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
				$"Check get_course_weights to see if course {course} has data"
			, true);
	}
}

function init_level_minimap() {
    // generate the background image for minimap
    print("Generating level minimap");
    var t = current_time;
    
    var surface = surface_create(obj_controller.minimap_config.surface_width, obj_controller.minimap_config.surface_height);
    surface_set_target(surface);
    draw_clear_alpha(c_white, 0);
    surface_reset_target();
    
    var init_road_coord = new Point(
        ((obj_road_generator.control_path[0] % obj_road_generator.grid_width)*obj_controller.minimap_config.border),
        ((obj_road_generator.control_path[0] div obj_road_generator.grid_width)*obj_controller.minimap_config.border)
    );
    var last_road_coord = new Point(
        init_road_coord.x,
        init_road_coord.y
    );
    var scaling_factor = obj_road_generator.control_points_dist / obj_controller.minimap_config.border;
    surface_set_target(surface);
    draw_clear_alpha(0, 0);
    
    // draw the height map
    //for (var i = 0; i < (obj_road_generator.grid_width * obj_road_generator.grid_height)-3; i++) {
        //var xx = i % obj_road_generator.grid_width;
        //var yy = i div obj_road_generator.grid_width;
        //var value = clamp((obj_road_generator.grid[| i] * 255) + 127, 0, 255);
        //var c = make_color_rgb(value, value, value);
        //draw_rectangle_color(
            //xx * obj_controller.minimap_config.border, 
            //yy * obj_controller.minimap_config.border, 
            //(xx+1) * obj_controller.minimap_config.border,
            //(yy+1) * obj_controller.minimap_config.border,
            //c, c, c, c,
            //false
        //);
    //}
    
    // draw road
    for (var i = 0; i < array_length(obj_road_generator.road_list) - 1; i++) {
        var road = obj_road_generator.road_list[@i];
        var next_road = obj_road_generator.road_list[@i+1];
        var x1 = last_road_coord.x;
        var y1 = last_road_coord.y;
        var x2 = last_road_coord.x + lengthdir_x(road.length / scaling_factor, road.direction);
        var y2 = last_road_coord.y + lengthdir_y(road.length / scaling_factor, road.direction);
    
        last_road_coord.x = x2;
        last_road_coord.y = y2;
    
        draw_line_width_color(
            x1, 
            y1, 
            x2, 
            y2, 
            3 + max(road.get_lanes_left(), road.get_lanes_right()), c_red, c_red
        );
    }
    // create sprite to be drawn on screen
    var spr_map = sprite_create_from_surface(
        surface, 
        0, 0, 
        obj_controller.minimap_config.surface_width, obj_controller.minimap_config.surface_height,
        false,
        false,
        0, 0
    );
    surface_reset_target();
    surface_free(surface);
    print($"Level minimap completed in {(current_time - t) / 1000}s");
    return spr_map;
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