event_inherited();

if (!ai_behavior.part_of_race) {
	vehicle_type = choose(VEHICLE_TYPE.CAR, VEHICLE_TYPE.BIKE);
}

if (vehicle_type == VEHICLE_TYPE.CAR) {
	vehicle_detail_index = spr_car_3d;
	vehicle_detail_subimage = irandom(sprite_get_number(vehicle_detail_index));
	if (!ai_behavior.part_of_race) {
		mass += 6000;
		engine.horsepower += 100;
		max_hp += 3000;
		hp += 3000;
	}
}
vehicle_color = {
	primary: min($ffffff, make_color_rgb(irandom(32) * 8, irandom(32) * 8, irandom(32) * 8)),
	secondary: min($ffffff, make_color_rgb(irandom(32) * 8, irandom(32) * 8, irandom(32) * 8)),
	tetriary: min($ffffff, make_color_rgb(irandom(32) * 8, irandom(32) * 8, irandom(32) * 8))
};

racer_color_replace_dst = [
	color_get_red(vehicle_color.primary)/255, color_get_green(vehicle_color.primary)/255, color_get_blue(vehicle_color.primary)/255,
	(color_get_red(vehicle_color.primary)-30)/255, (color_get_green(vehicle_color.primary)-30)/255, (color_get_blue(vehicle_color.primary)-30)/255,
	(color_get_red(vehicle_color.primary)-60)/255, (color_get_green(vehicle_color.primary)-60)/255, (color_get_blue(vehicle_color.primary)-60)/255,
	(color_get_red(vehicle_color.primary))/255, (color_get_green(vehicle_color.primary)+30)/255, (color_get_blue(vehicle_color.primary)+60)/255,
	(color_get_red(vehicle_color.secondary))/255, (color_get_green(vehicle_color.secondary))/255, (color_get_blue(vehicle_color.secondary))/255,
	(color_get_red(vehicle_color.tetriary))/255, (color_get_green(vehicle_color.tetriary))/255, (color_get_blue(vehicle_color.tetriary))/255,
	(color_get_red(vehicle_color.tetriary)-30)/255, (color_get_green(vehicle_color.tetriary)-30)/255, (color_get_blue(vehicle_color.tetriary)-30)/255,
	(color_get_red(vehicle_color.tetriary)-60)/255, (color_get_green(vehicle_color.tetriary)-60)/255, (color_get_blue(vehicle_color.tetriary)-60)/255
];