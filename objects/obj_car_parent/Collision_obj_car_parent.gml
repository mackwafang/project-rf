if (other != self) {
	if (abs(other.z - z) < 16) {
		if (!other.is_respawning) {
			var deg = angle_difference(direction, point_direction(x,y,other.x,other.y));
			
			if (!is_completed) {
				hp -= abs(((other.velocity - velocity) / velocity) * dcos(deg) * ((other.mass - mass) / mass));
			}
			
			// push_vector.x += abs(other.velocity - velocity) * dcos(deg) * other.mass;
			push_vector.y += abs(other.velocity - velocity) * dcos(deg) * abs(other.mass - mass);
			turn_rate *= 3;
			if (hp <= 0) {
				zspeed += max(height / 4, abs(height - other.height / 4)) / (mass / 4);
			}
			move_contact_solid(point_direction(other.x,other.y,x,y),1);
			hp_regen_delay = -3;
		}
	}
}