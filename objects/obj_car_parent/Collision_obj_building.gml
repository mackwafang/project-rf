var dist_to_building = max(1, point_distance(x, y, other.x, other.y));
var a = new Point(
	lengthdir_x(1, direction),
	lengthdir_y(1, direction)
);
var b = new Point(
	(other.x - x) / dist_to_building,
	(other.y - y) / dist_to_building
);
var _d = clamp(abs(dot_product(b.x, b.y, a.x, a.y)), 0, 1);
hp -= max_hp * _d * 4;
turn_rate *= _d * 2;
velocity *= _d;
move_contact_solid(dist_to_building - 180, 6);