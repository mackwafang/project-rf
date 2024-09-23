if (wait_time > 0) {
	wait_time -= delta_time / 1000000;
}
else {
	alpha -= delta_time / 1000000;
}

if (alpha <= -1) {
	instance_create_layer(0, 0, "Instances", obj_title_control);
	instance_destroy();
}