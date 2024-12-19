function vertex_square() {
	vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z+h	, uv[0], uv[1]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z		, uv[0], uv[3]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z+h	, uv[2], uv[1]);
	
	vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z+h, uv[2], uv[1]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z, uv[0], uv[3]);
	vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z, uv[2], uv[3]);
}