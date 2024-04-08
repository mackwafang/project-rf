var dist = max(1, point_distance(x, y, other.x, other.y));
var a = new Point(
	lengthdir_x(1, direction),
	lengthdir_y(1, direction)
);
var b = new Point(
	(other.x - x) / dist,
	(other.y - y) / dist
);
var _d = abs(dot_product(b.x, b.y, a.x, a.y));

if (abs(z-other.z) < 8) {
	if (other.display_sprite_index == spr_prop) {
		switch(other.display_image_index) {
			case 0:
				hp -= (max_hp * _d);
				turn_rate *= _d * 2;
				break;
			case 1:
				//if (zspeed <= global.gravity_3d) {
				//	zspeed += velocity / mass / 10;
				//}
			
				//if (is_player) {
				//	print($"yeet {other.id} {zspeed}");
				//}
				break;
		}
	}
}