event_inherited();
display_sprite_index = spr_tree;

direction = irandom(360);

if (!global.GAMEPLAY_TREES) {
	instance_destroy();
}