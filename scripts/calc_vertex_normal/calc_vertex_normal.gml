function calc_vertex_normal(vertex_buffer, vertex_format) {
		
	var buff = buffer_create_from_vertex_buffer_ext(vertex_buffer, buffer_fixed, 1, 0, vertex_get_number(vertex_buffer));
	
	for (var i = 0; i < buffer_get_size(buff); i += 36 * 3) {
		
		var x1 = buffer_peek(buff, i + 00, buffer_f32);
		var y1 = buffer_peek(buff, i + 04, buffer_f32);
		var z1 = buffer_peek(buff, i + 08, buffer_f32);
		
		var x2 = buffer_peek(buff, i + 36 + 00, buffer_f32);
		var y2 = buffer_peek(buff, i + 36 + 04, buffer_f32);
		var z2 = buffer_peek(buff, i + 36 + 08, buffer_f32);
		
		var x3 = buffer_peek(buff, i + 72 + 00, buffer_f32);
		var y3 = buffer_peek(buff, i + 72 + 04, buffer_f32);
		var z3 = buffer_peek(buff, i + 72 + 08, buffer_f32);
		
		var v1 = new Vec2(x1, y1, z1);
		var v2 = new Vec2(x2, y2, z2);
		var v3 = new Vec2(x3, y3, z3);
		
		v1 = v1.subtract(v1);
		
		var e1 = v2.subtract(v1);
		var e2 = v3.subtract(v1);
		
		var norm = (e1.cross(e2)).normalize();
		
		buffer_poke(buff, i + 24 + 0, buffer_f32, norm.x);
		buffer_poke(buff, i + 24 + 4, buffer_f32, norm.y);
		buffer_poke(buff, i + 24 + 8, buffer_f32, norm.z);
		
		buffer_poke(buff, i + 36 + 24, buffer_f32, norm.x);
		buffer_poke(buff, i + 36 + 24 + 4, buffer_f32, norm.y);
		buffer_poke(buff, i + 36 + 24 + 8, buffer_f32, norm.z);
		
		buffer_poke(buff, i + 72 + 24, buffer_f32, norm.x);
		buffer_poke(buff, i + 72 + 24 + 4, buffer_f32, norm.y);
		buffer_poke(buff, i + 72 + 24 + 8, buffer_f32, norm.z);
		
		var new_buff = vertex_create_buffer_from_buffer(buff, vertex_format);
		buffer_delete(buff);
		return new_buff;
	}
}