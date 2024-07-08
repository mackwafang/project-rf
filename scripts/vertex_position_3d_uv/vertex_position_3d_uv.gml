function vertex_position_3d_uv(buffer, _x, _y, _z, _u, _v, _color=c_white, _alpha=1) {
	/// @function		vertex_position_3d_uv(buffer, x, y, z, u, v, color, alpha)
	vertex_position_3d(buffer, _x, _y, _z);
	vertex_color(buffer, _color, _alpha);
	vertex_texcoord(buffer, _u, _v);
	vertex_normal(buffer, 0, 0, 1);
}