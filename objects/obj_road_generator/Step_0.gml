var cam_obj = obj_controller.main_camera_target;
var nearest_cp = find_nearest_cp(cam_obj.x, cam_obj.y, cam_obj.on_road_index._id div road_segments);
if (nearest_cp != current_cp) {
	vertex_delete_buffer(global.road_vertex_buffer);
	vertex_delete_buffer(global.prop_vertex_buffer);
	global.road_vertex_buffer = -1;
	global.prop_vertex_buffer = -1;
	
	render_control_point(nearest_cp, 3);
	
	current_cp = nearest_cp;
}