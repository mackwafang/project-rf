function dist_on_line(A, B, pos) {
	/// @function			dist_on_line(a, b, pos)
	/// @description		Get the scalar projection distance from point A on line AB
	/// @param {Point}		a point a
	/// @param {Point}		b point b
	/// @param {Point}		pos	position to check
	var a = new Point(
		B.x - A.x,
		B.y - A.y
	);
	var b = new Point(
		pos.x - A.x,
		pos.y - A.y
	);
	try {
		var line_dir = point_direction(A.x, A.y, B.x, B.y);
		var length_a = sqrt((a.x*a.x) + (a.y*a.y));
		var length_b = sqrt((b.x*b.x) + (b.y*b.y));
		var a_hat = new Point(
			a.x / length_a,
			a.y / length_a
		);
		var ba = dot_product(b.x, b.y, a_hat.x, a_hat.y);
		return ba;
	}
	catch (_e) {
		print($"dist_on_line exception: {_e}");
		return 0;
	}
}