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
if (is_player) {
    print(_d)
}
hp -= max_hp * _d;
turn_rate *= _d * 2;
velocity *= _d;

var dist_to_center = sqrt(sqr(other.building_width / 2) + sqr(other.building_height / 2));
var other_center_x = other.x + lengthdir_x(dist_to_center, other.direction);
var other_center_y = other.y + lengthdir_y(dist_to_center, other.direction);
var push_dir = point_direction(other_center_x, other_center_y, x, y)
move_and_collide(dcos(push_dir), dsin(push_dir), obj_building);
move_outside_all(point_direction(x, y, other_center_x, other_center_y)+180, velocity);