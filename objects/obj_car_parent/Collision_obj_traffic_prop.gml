var dist = max(1, point_distance(x, y, other.x, other.y));
var dir = point_direction(x, y, other.x, other.y);
var a = new Point(
	lengthdir_x(1, direction),
	lengthdir_y(1, direction)
);
var b = new Point(
	(other.x - x) / dist,
	(other.y - y) / dist
);
var _d = 1 - abs(dot_product(b.x, b.y, a.x, a.y));

if (abs(z-other.z) < other.height) {
	if (other.display_sprite_index == spr_prop) {
		switch(other.display_image_index) {
			case 0:
				hp -= (max_hp * (_d/5));
				turn_rate *= _d * 2;
				break;
			case 1:
				if (zspeed <= global.gravity_3d) {
					zspeed += (other.height / 10) / (mass / velocity) * 0.25;
				}
				audio_play_sound_on(engine_sound_emitter, snd_hit_light, false, 2, 1, 0, random_range(0.95, 1.05));
				//if (is_player) {
				//	print($"yeet {other.id} {zspeed}");
				//}
				break;
			case 6:
				if (is_respawning) {
					on_collision_with_entity(0.5);
				}
				break;
		}
	}
}
//move_contact_solid(point_direction(other.x,other.y,x,y),1);
//move_and_collide(dcos(dir), dsin(dir), obj_car_parent);