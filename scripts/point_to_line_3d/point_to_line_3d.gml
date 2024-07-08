
function point_to_line_3d(ax, ay, az, bx, by, bz, posx, posy, posz) {
	/// @function			point_to_line_3d(a, b, pos)
	/// @description		Get the point to intersect line Ab at the perpendicular in 3d space
	/// @param {Real}		ax point ax
	/// @param {Real}		ay point ay
	/// @param {Real}		az point az
	/// @param {Real}		bx point bx
	/// @param {Real}		by point by
	/// @param {Real}		bz point bz
	/// @param {Real}		posx	position x to check
	/// @param {Real}		posy	position y to check
	/// @param {Real}		posz	position z to check
	var r = dist_on_line(ax, ay, bx, by, posx, posy);
	var dist = point_distance(ax, ay, bx, by);
	var s = point_direction(ax, ay, bx, by);
	var t = darccos((az - bz) / point_distance_3d(ax, ay, az, bx, by, bz));
	var loc = new Point3D(
		ax + (r * dcos(s) * dsin(t)),
		ay + (r * dsin(s) * dsin(t)),
		az + (r * dcos(t))
	)
	return loc;
}