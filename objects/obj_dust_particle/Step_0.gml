image_xscale += extend_rate;
image_yscale += extend_rate;
image_alpha -= fade_rate;
image_blend = color;
image_angle += irandom(10)/5;

if (image_alpha <= 0.1) {
	instance_destroy();
}