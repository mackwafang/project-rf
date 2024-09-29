event_inherited();
display_sprite_index = spr_prop;
switch(display_image_index) {
	case 1: case 6:
		render_scale.x *= 0.5;
		render_scale.y *= 0.5;
		break;
}
image_xscale = 16;
image_yscale = 16;