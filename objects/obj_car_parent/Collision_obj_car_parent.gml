if (other != self) {
	if (abs(other.z - z) < 16) {
		if (!other.is_respawning) {
			var deg = angle_difference(image_angle, point_direction(x,y,other.x,other.y));
			
			if (!is_completed) {
				hp -= abs((abs(other.velocity - velocity) / velocity) * dsin(deg) * ((other.mass - mass) / mass)) * 3;
			}
			
			// push_vector.x += abs(other.velocity - velocity) * dcos(deg) * other.mass;
			push_vector.y += abs(other.velocity - velocity) * dsin(deg) * abs(other.mass - mass);
			turn_rate = push_vector.y / (mass * 100);
			if (hp <= 0) {
				zspeed += max(height / 2, abs(height - other.height / 2)) / (mass / 50);
			}
			move_contact_solid(point_direction(other.x,other.y,x,y),1);
			hp_regen_delay = -3;
		}
	}
}