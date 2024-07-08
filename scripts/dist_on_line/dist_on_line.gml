function dist_on_line(ax, ay, bx, by, posx, posy) {
	/// @function			dist_on_line(a, b, pos)
	/// @description		Get the scalar projection distance from point a on line AB
	/// @param {Point}		a point a
	/// @param {Point}		b point b
	/// @param {Point}		pos	position to check
	var a_x = bx - ax;
	var a_y = by - ay;
	var b_x = posx - ax;
	var b_y = posy - ay;
	
	try {
		var line_dir = point_direction(ax, ay, bx, by);
		var length_a = sqrt((a_x*a_x) + (a_y*a_y));
		var length_b = sqrt((b_x*b_x) + (b_y*b_y));
		var a_hat_x = a_x / length_a;
		var a_hat_y = a_y / length_a;
		var ba = dot_product(b_x, b_y, a_hat_x, a_hat_y);
		return ba;
	}
	catch (_e) {
		print($"dist_on_line exception: {_e}");
		return 0;
	}
}