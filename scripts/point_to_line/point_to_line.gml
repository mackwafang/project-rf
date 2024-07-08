
function point_to_line(ax, ay, bx, by, posx, posy) {
	/// @function			point_to_line(a, b, pos)
	/// @description		Get the point to intersect line AB at the perpendicular
	/// @param {Real}		ax point ax
	/// @param {Real}		ay point ay
	/// @param {Real}		bx point bx
	/// @param {Real}		by point by
	/// @param {Real}		posx	position x to check
	/// @param {Real}		posy	position y to check
	var ba = dist_on_line(ax, ay, bx, by, posx, posy);
	var line_dir = point_direction(ax, ay, bx, by);
	var loc = new Point(
		ax + lengthdir_x(ba, line_dir),
		ay + lengthdir_y(ba, line_dir)
	)
	return loc;
}