if (other != self) {
	if (abs(other.z - z) < 16) {
		if (!other.is_respawning) {
			var dir = point_direction(other.x,other.y,x,y);
			var side = sign(angle_difference(dir, direction));
			var force = ((mass * velocity) + (other.mass + other.velocity)) / global.deltatime;
			var base_collision_hp_lost = (force / 500000);
			if (!is_completed) {
				if (hit_immune <= 0) {
					var collision_sound_max_dist = 256;
					var collision_sound_fall_off = 196;
					
					if (abs(angle_difference(direction, dir)) < 120) {
						base_collision_hp_lost /= 2;
					}
					turn_rate = sign(force) * side * (other.mass / mass) / 10;
					hp -= base_collision_hp_lost;
					
					if (base_collision_hp_lost < 20) {
						audio_play_sound_at(snd_hit_light, x, y, z, collision_sound_fall_off, collision_sound_max_dist, 1, false, 6);
					}
					else if (base_collision_hp_lost < 50) {
						audio_play_sound_at(snd_hit_med, x, y, z, collision_sound_fall_off, collision_sound_max_dist, 1, false, 6);
					}
					else {
						audio_play_sound_at(snd_hit_hard, x, y, z, collision_sound_fall_off, collision_sound_max_dist, 1, false, 6);
					}
					hit_immune = 1;
				}
			}
			push_vector.y += abs(force);
			if (hp <= 0) {
				zspeed += abs(((vehicle_type == VEHICLE_TYPE.BIKE ? height/2 : height) - other.height) / 4) * (velocity / max_velocity);
				turn_rate = 0;
			}
			if (is_respawning) {
				if (crash_timer.is_walking) {
					hp = 0;
					on_death();
					crash_timer.is_walking = false;
					crash_timer.to_get_on = -1;
					crash_timer.to_stand = crash_timer.TIME_TO_STAND;
				}
			}
			move_contact_solid(dir,10);
			move_and_collide(dcos(dir), dsin(dir), obj_car_parent);
			hp_regen_delay = -3;
		}
	}
}