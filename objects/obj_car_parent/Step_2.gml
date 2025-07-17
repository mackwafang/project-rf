if (global.game_state_paused) {exit;}

if (hit_immune > 0) {
	hit_immune -= global.deltatime;
}