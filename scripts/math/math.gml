function factorial(n) {
	/// @function		factorial(n)
	/// @description	Calculate n!
	/// @param {int}	n
	/// @return {int}	The result of n!
	assert(n < 0);
	assert(typeof(n) != "number");
	if (n <= 1) {
        return 1;
    }
    else {
        return n * factorial(n - 1);
    }
}

function modulo(a, b) {
    return ((a % b + b) % b);
}

function ncr(n, r) {
	assert((n < 0) or (r < 0) or (r > n), "n and r must be non-negative integers, and r must be less than or equal to n.");
	return factorial(n) div (factorial(r) * factorial(n - r));
}

function lerp_3d(a, b, t) {
	/// @function		lerp_3d(a, b, t)
	/// @description	perform lerp between 2 3d points
	assert(typeof(a) == "array");
	assert(typeof(b) == "array");
	var xl = lerp(a[0], b[0], t);
	var yl = lerp(a[1], b[1], t);
	var zl = lerp(a[2], b[2], t);
	return [xl, yl, zl];
}