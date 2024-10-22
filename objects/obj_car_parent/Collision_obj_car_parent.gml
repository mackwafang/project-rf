if (other != self) {
	if (abs(other.z - z) < 16) {
		if (!other.is_respawning) {
			var dir = point_direction(x, y, other.x, other.y);
			var force = ((mass * velocity) + (other.mass + other.velocity)) / global.deltatime;
			if (!is_completed) {
				var base_collision_hp_lost = (force / 1000000);
				hp -= base_collision_hp_lost / 2;
			}
			// push_vector.x += abs(other.velocity - velocity) * dcos(deg) * other.mass;
			push_vector.x -= force / 10000;
			push_vector.y += force / 10000;
			turn_rate *= 3;
			if (hp <= 0) {
				zspeed += abs(((vehicle_type == VEHICLE_TYPE.BIKE ? height/2 : height) - other.height) / 4) * (velocity / max_velocity);
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
			move_contact_solid(point_direction(other.x,other.y,x,y),1);
			move_and_collide(dcos(dir), dsin(dir), obj_car_parent);
			hp_regen_delay = -3;
		}
	}
}