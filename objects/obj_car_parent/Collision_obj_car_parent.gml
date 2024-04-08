if (other != self) {
	if (abs(other.z - z) < 16) {
		if (!other.is_respawning) {
			var deg = angle_difference(image_angle, point_direction(x,y,other.x,other.y));
			
			if (!is_completed) {
				hp -= abs(other.velocity - velocity * dsin(deg)) * abs(mass - other.mass) / 10000;
			}
			if (hp <= 0) {
				zspeed += velocity / 4000;
			}
			
			push_vector.x += abs(other.velocity - velocity) * dcos(deg) * other.mass;
			push_vector.y += abs(other.velocity - velocity) * dsin(deg) * other.mass;
			turn_rate = push_vector.y / (mass * 100);
			zspeed += velocity / mass / 10;
			move_contact_solid(point_direction(other.x,other.y,x,y),1);
			hp_regen_delay = -3;
		}
	}
}