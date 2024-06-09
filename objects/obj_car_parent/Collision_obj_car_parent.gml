if (other != self) {
	if (abs(other.z - z) < 16) {
		if (!other.is_respawning) {
			var deg = angle_difference(image_angle, point_direction(x,y,other.x,other.y));
			
			if (!is_completed) {
				hp -= abs((abs(other.velocity - velocity) / velocity) * dsin(deg) * ((other.mass - mass) / mass)) * 1.5;
			}
			
			// push_vector.x += abs(other.velocity - velocity) * dcos(deg) * other.mass;
			push_vector.y += abs(other.velocity - velocity) * dsin(deg) * abs(other.mass - mass);
			turn_rate = push_vector.y / (mass * 100);
			zspeed += min(1.5, 0.5 * abs((abs(other.velocity - velocity) / velocity) * dsin(deg) * (abs(other.mass - mass) / mass)));
			move_contact_solid(point_direction(other.x,other.y,x,y),1);
			hp_regen_delay = -3;
		}
	}
}