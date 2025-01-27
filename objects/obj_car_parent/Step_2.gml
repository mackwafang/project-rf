if (global.game_state_paused) {exit;}
// crash timer count down
// from ground to standup
if (crash_timer.to_stand > 0) {
	crash_timer.to_stand -= global.deltatime;
	if (crash_timer.to_stand <= 0) {
		crash_timer.is_walking = true;
		on_stand_up();
	}
}

// from walking to get on
if (crash_timer.to_get_on > 0) {
	crash_timer.to_get_on -= global.deltatime;
	if (crash_timer.to_get_on <= 0) {
		crash_timer.is_walking = false;
		on_respawn();
	}
}

if (hit_immune > 0) {
	hit_immune -= global.deltatime;
}