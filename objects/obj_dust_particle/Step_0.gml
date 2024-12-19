image_xscale += extend_rate;
image_yscale += extend_rate;
image_alpha -= fade_rate;
image_blend = color;

if (image_alpha <= 0.5) {
	instance_destroy();
}