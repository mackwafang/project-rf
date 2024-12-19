event_inherited();
display_sprite_index = spr_tree;
image_xscale = 8;
image_yscale = 8;
mass = 1000;

if (!global.GAMEPLAY_TREES) {
	instance_destroy();
}