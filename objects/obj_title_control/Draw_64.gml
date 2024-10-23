draw_set_font(fnt_game);

var port_width = view_wport[0];
var port_height = view_hport[0];

draw_set_font(fnt_game);

draw_set_valign(fa_middle);
draw_set_halign(fa_center);
var anic = animcurve_get(anic_flash);
var flash_freq = global.display_freq div 3;
var alpha = animcurve_channel_evaluate(animcurve_get_channel(anic, 0), (wait_timer % flash_freq) / flash_freq);
var _level_length = _level_distance[level_options[LEVEL_OPTIONS_INDEX_DIFFICULTY] % 5] * (global.GAMEPLAY_MEASURE_METRICS == MEASURE.METRIC ? 1 : KMH_TO_MPH);
var _level_length_unit = (global.GAMEPLAY_MEASURE_METRICS == MEASURE.METRIC ? "KM" : "MI");
var color_diff = (level_option_selected == LEVEL_OPTIONS_INDEX_DIFFICULTY ? c_lime : c_white);
var color_course = (level_option_selected == LEVEL_OPTIONS_INDEX_COURSE ? c_lime : c_white);
draw_text_color(port_width / 2, port_height / 2, $"< Level {round(level_options[LEVEL_OPTIONS_INDEX_DIFFICULTY]+1)} >\n~{_level_length} {_level_length_unit}\n", color_diff, color_diff, color_diff, color_diff, alpha);
draw_text_color(port_width / 2, (port_height / 2) + 48, $"< {course_string[level_options[LEVEL_OPTIONS_INDEX_COURSE] % array_length(course_string)]} >", color_course, color_course, color_course, color_course, alpha);


draw_text(port_width / 2, port_height * 0.7, $"Left / Right - Turn\nC - Accelerate\nX - Boost\nZ - Brake\n\nPress <Space> to begin");

draw_set_valign(fa_bottom);
draw_set_halign(fa_center);
draw_text(port_width / 2, port_height, "created by meekuwufang");