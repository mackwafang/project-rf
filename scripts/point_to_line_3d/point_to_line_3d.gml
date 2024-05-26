
function point_to_line_3d(A, B, pos) {
	/// @function			point_to_line_3d(a, b, pos)
	/// @description		Get the point to intersect line AB at the perpendicular in 3d space
	/// @param {Vec3}		a point a
	/// @param {Vec3}		b point b
	/// @param {Vec3}		pos	position to check
	var r = dist_on_line(A,B,pos);
	var dist = point_distance(A.x, A.y, B.x, B.y);
	var s = point_direction(A.x, A.y, B.x, B.y);
	var t = darccos((A.z - B.z) / point_distance_3d(A.x, A.y, A.z, B.x, B.y, B.z));
	var loc = new Point3D(
		A.x + (r * dcos(s) * dsin(t)),
		A.y + (r * dsin(s) * dsin(t)),
		A.z + (r * dcos(t))
	)
	return loc;
}