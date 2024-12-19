on_road_index = find_nearest_road(x, y, on_road_index._id);

var vel = velocity;

if (keyboard_check(vk_shift)) {vel *= 2;}

if (keyboard_check(ord("W"))) {	
	x += lengthdir_x(vel * global.deltatime, image_angle);
	y += lengthdir_y(vel * global.deltatime, image_angle);
}
if (keyboard_check(ord("S"))) {
	x += lengthdir_x(-vel * global.deltatime, image_angle);
	y += lengthdir_y(-vel * global.deltatime, image_angle);
}
if (keyboard_check(ord("A"))) {
	x += lengthdir_x(vel * global.deltatime, image_angle+90);
	y += lengthdir_y(vel * global.deltatime, image_angle+90);
}
if (keyboard_check(ord("D"))) {
	x += lengthdir_x(vel * global.deltatime, image_angle-90);
	y += lengthdir_y(vel * global.deltatime, image_angle-90);
}

if (mouse_check_button_pressed(mb_any)) {
	last_mouse_x = window_mouse_get_x();
}

if (mouse_check_button(mb_any)) {
	direction -= dsin(window_mouse_get_x() - last_mouse_x);
	image_angle = direction;
	
	last_mouse_x = lerp(last_mouse_x, window_mouse_get_x(), 0.1);
}