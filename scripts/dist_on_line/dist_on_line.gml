function dist_on_line(A, B, pos) {
	/// @function			dist_on_line(a, b, pos)
	/// @description		Get the scalar projection distance from point A on line AB
	/// @param {Point}		a point a
	/// @param {Point}		b point b
	/// @param {Point}		pos	position to check
	var a_x = B.x - A.x;
	var a_y = B.y - A.y;
	var b_x = pos.x - A.x;
	var b_y = pos.y - A.y;
	
	try {
		var line_dir = point_direction(A.x, A.y, B.x, B.y);
		var length_a = sqrt((a_x*a_x) + (a_y*a_y));
		var length_b = sqrt((b_x*b_x) + (b_y*b_y));
		var a_hat = [
			a_x / length_a,
			a_y / length_a
		];
		var ba = dot_product(b_x, b_y, a_hat[0], a_hat[1]);
		return ba;
	}
	catch (_e) {
		print($"dist_on_line exception: {_e}");
		return 0;
	}
}