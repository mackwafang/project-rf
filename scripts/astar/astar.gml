
function a_star_heuristic(node, _end, width) {
	var node_x = node % width;
	var node_y = node div width;
	var goal_x = _end % width;
	var goal_y = _end div width;
	return sqrt((sqr(node_x - goal_x)) + (sqr(node_y - goal_y)));
}

function a_star(_grid, _start, _end, width, _h) {
	/// @function		a_star(_start, _end, width, _h)
	/// @param _grid	graph (expects a ds_list)
	/// @param _start	start grid
	/// @param _end		end grid
	/// @param width	width of grid
	/// @param _h		hueristic function pointer
	var t = current_time;
	var frontier = ds_priority_create();
	var searched = ds_list_create();
	var parent = ds_list_create();
	var g = ds_list_create();
	for (var i = 0; i < ds_list_size(_grid); i++) {
		ds_list_add(searched, false);
		ds_list_add(parent, 0);
		ds_list_add(g, 0);
	}
	ds_priority_add(frontier, _start, 0);
	var last_dir = 0;

	
	while (ds_priority_find_min(frontier) != _end) {
		var current = ds_priority_delete_min(frontier); // remove from queue
		
		// stop if on far edge
		// in case where road reached the edge but no at the right row
		if (current % width == width - 1) {
			_end = current;
			break;
		}
		
		searched[|current] = true; //  add to search
		
		// finding neighbors
		//var neighbor_index = [-1, 1, -width, width];
		//if (current % width == 0) {
		//	neighbor_index = [1, -width, width];
		//}
		//if (current % width == width-1) {
		//	neighbor_index = [-1, -width, width];
		//}
		
		var neighbor_index = [-1, 1, -width-1, -width, -width+1, width-1, width+1];
		if (current % width == 0) {
			neighbor_index = [1, -width, -width+1, width, width+1];
		}
		if (current % width == width-1) {
			neighbor_index = [-1, -width, -width-1, width, width-1];
		}
		
		var neighbors = ds_list_create();
		for (var ni = 0; ni < array_length(neighbor_index); ni++) {
			var n = current + neighbor_index[ni];
			if (0 <= n && n < ds_list_size(_grid)) {
				ds_list_add(neighbors, n);
			}
		}
		
		// for each neighbors
		for (var ni = 0; ni < ds_list_size(neighbors); ni++) {
			var n = neighbors[|ni];
			var cost = g[|current] + abs(_grid[|n] - _grid[|current]);
			
			// skips sharp turns
			var dir = point_direction(current % width, current div width, n % width, n div width);
			if (abs(angle_difference(dir, last_dir)) > 45) {continue;}
			
			if ((ds_priority_find_priority(frontier, n) != undefined) && (cost < g[|n])) {
				// new path is better
				ds_priority_delete_value(frontier, n);
			}
			
			if (searched[|n] && (cost < g[|n])) {
				searched[|n] = false;
			}
			
			if ((ds_priority_find_priority(frontier, n) == undefined) && !searched[|n]) {
				// add new
				g[|n] = cost;
				ds_priority_add(frontier, n, g[|n] + _h(n, _end, width));
				parent[|n] = current;
				last_dir = dir;
			}
		}
		// retry if take too long
		if (current_time - t > 3000) {
			ds_priority_destroy(frontier);
			ds_list_destroy(searched);
			ds_list_destroy(parent);
			ds_list_destroy(g);
			return [];
		}
		// post process
		ds_list_destroy(neighbors);
	}
	
	print("Retracing road");
	var path = [];
	var cur = parent[|_end];
	while (cur != _start) {
		path[array_length(path)] = cur;
		cur = parent[|cur];
	}
	path[array_length(path)] = _start;
	path = array_reverse(path);
	
	ds_priority_destroy(frontier);
	ds_list_destroy(searched);
	ds_list_destroy(parent);
	ds_list_destroy(g);
	
	return path;
}