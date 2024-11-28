event_inherited();

vehicle_color = {
	primary: min($ffffff, make_color_hsv(irandom_range(1, 32) * 8, 255, irandom_range(16, 32) * 8)),
	secondary: min($ffffff, make_color_hsv(irandom_range(1, 32) * 8, irandom_range(0, 16) * 8, irandom_range(16, 32) * 8)),
	tetriary: min($ffffff, make_color_hsv(irandom_range(1, 32) * 8, irandom_range(0, 16) * 8, irandom_range(16, 32) * 8))
};

racer_color_replace_dst = [
	color_get_red(vehicle_color.primary)/255, color_get_green(vehicle_color.primary)/255, color_get_blue(vehicle_color.primary)/255,
	(color_get_red(vehicle_color.primary)-30)/255, (color_get_green(vehicle_color.primary)-30)/255, (color_get_blue(vehicle_color.primary)-30)/255,
	(color_get_red(vehicle_color.primary)-60)/255, (color_get_green(vehicle_color.primary)-60)/255, (color_get_blue(vehicle_color.primary)-60)/255,
	(color_get_red(vehicle_color.primary))/255, (color_get_green(vehicle_color.primary)+30)/255, (color_get_blue(vehicle_color.primary)+60)/255,
	(color_get_red(vehicle_color.secondary))/255, (color_get_green(vehicle_color.secondary))/255, (color_get_blue(vehicle_color.secondary))/255,
	(color_get_red(vehicle_color.secondary))/255, (color_get_green(vehicle_color.secondary))/255, (color_get_blue(vehicle_color.secondary))/255,
	(color_get_red(vehicle_color.secondary))/255, (color_get_green(vehicle_color.secondary))/255, (color_get_blue(vehicle_color.secondary))/255,
	(color_get_red(vehicle_color.tetriary))/255, (color_get_green(vehicle_color.tetriary))/255, (color_get_blue(vehicle_color.tetriary))/255,
	(color_get_red(vehicle_color.tetriary)-30)/255, (color_get_green(vehicle_color.tetriary)-30)/255, (color_get_blue(vehicle_color.tetriary)-30)/255,
	(color_get_red(vehicle_color.tetriary)-60)/255, (color_get_green(vehicle_color.tetriary)-60)/255, (color_get_blue(vehicle_color.tetriary)-60)/255
];