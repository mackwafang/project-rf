function clean_level() {
	///@function	clean_level
	///@description	remove buffers and data that may cuase leaks
	vertex_delete_buffer(global.building_vertex_buffer);
	vertex_delete_buffer(global.prop_vertex_buffer);
	vertex_delete_buffer(global.road_vertex_buffer);
	audio_stop_all();
	if (instance_exists(obj_road_generator)) {
		with (obj_road_generator) {
			vertex_format_delete(building_vertex_format);
			vertex_format_delete(prop_vertex_format);
			vertex_format_delete(road_vertex_format);
		}
	}
}