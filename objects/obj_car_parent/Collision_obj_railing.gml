if (abs(z-other.z) < other.height) {
	var dist = point_distance(x, y, other.x, other.y);
	var a = new Point(
		lengthdir_x(1, direction),
		lengthdir_y(1, direction)
	);
	var b = new Point(
		lengthdir_x(1, other.direction - 90),
		lengthdir_y(1, other.direction - 90)
	);
	var _d = dot_product(a.x, a.y, b.x, b.y);
	
	var angle = other.direction + (90 * sign(-darccos(_d)+90));
	hp -= max_hp * power(abs(_d), 5);
	//move_outside_solid(angle, 6);
	var vel = (velocity) * global.deltatime / global.WORLD_TO_REAL_SCALE;
	move_outside_all(angle, vel);
	move_and_collide(dcos(direction), dsin(direction), obj_railing);
}