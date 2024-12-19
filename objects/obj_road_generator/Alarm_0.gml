// here to fix issue with game no rendering prop at the begining of the race
vertex_delete_buffer(global.road_vertex_buffer);
vertex_delete_buffer(global.prop_vertex_buffer);
global.road_vertex_buffer = -1;
global.prop_vertex_buffer = -1;
render_control_point(0, 3);