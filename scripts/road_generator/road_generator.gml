function RoadNode(_Point) constructor {
	/// @function		RoadNode(_Point)
	/// @param			_Point a Point3D Object
	x = _Point.x;				// x position
	y = _Point.y;				// y position
	z = _Point.z;				// z position
	direction = 0;				// road's direction to the next segment
	length = 0;					// length of segment
	ideal_throttle = 0;			// ideal throttle for ai
	lanes = [1, 0, 1];			// lanes [left, median , right]
	lane_width = 0;				// lane width in pixels
	length_to_point = 0;		// distance from the begining to this point
	collision_points = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];	// list of collisions for this road node
	shoulder = [true, true];	// shoulder for rendering for [left, right]
	shoulder_z = [0, 0];		// extra z for shoulders
	shoulder_image_index = 0;	// sprite index for shoulder
	_id = -1;
	next_road = -1;
	elevation = 0;				// segment elevation in rad
	zone = ZONE.SUBURBAN		// road's current zone to render surrounding enviornment
	zone_feature = ZONE_FEATURE.NONE;
	transition_lane	= false;	// is road is transitioning to new lane count
	intersection = false;		// is segment an intersection?
	beyond_range = [new Point3D(0,0,0), new Point3D(0,0,0)]		// off road area
	sea_level = 0;				// level for water
	props = [];					// list of props in this segment
	buildings = [];				// buildings in this segment
	collision_3d = undefined;	// cm object collision data
	building_color = c_white;	// change this zone's building color 
	
	toString = function() {
		return $"({x}, {y}, {z}), direction: {direction}, Lanes: {lanes}\n";
	}
	
	set_lanes_left = function(_lanes) {lanes[0] = _lanes;}
	set_lanes_right = function(_lanes) {lanes[2] = _lanes;}
	set_lanes_side = function(_lanes) {lanes[0] = _lanes; lanes[2] = _lanes;}
	
	get_id = function() {return _id;}
	
	get_direction = function() {
		return direction;
	}
	
	get_length = function() {
		return length;
	}
	
	get_ideal_throttle = function() {
		return ideal_throttle;
	}
	
	get_lanes = function() {
		/// @function			get_lanes()
		/// @description		Return the total number of lanes this sector has
		/// @return {real}
		sum = 0;
		for (var i = 0; i < array_length(lanes); i++) {
			sum += lanes[i];
		}
		return sum;
	}
	
	get_lane_width = function() {
		/// @function			get_lane_width()
		/// @description		Return lane width in pixel
		/// @return {real}
		return lane_width;
	}
	
	get_lanes_left = function() {
		/// @function			get_lanes_left()
		/// @description		Return the number of left lanes
		/// @return {real}
		return lanes[0];
	}
	
	get_lanes_right = function() {
		/// @function			get_lanes_right()
		/// @description		Return the number of right lanes
		/// @return {real}
		return lanes[2];
	}
	
	get_lanes_middle = function() {
		/// @function			get_lanes_middle()
		/// @description		Return the number of median lanes
		/// @return {real}
		return lanes[1];
	}
	
	get_collision_x = function() {
		/// @function			get_collision_x()
		/// @description		Return the x coordinates for collision
		/// @return {real}
		return collision_points[0];
	}
	
	get_collision_y = function() {
		/// @function			get_collision_y()
		/// @description		Return the y coordinates for collision
		/// @return {real}
		return collision_points[1];
	}
	
	get_collision_points = function() {
		/// @function			get_collision_points()
		/// @description		Return the coordinates for collision
		/// @return {real}
		return collision_points;
	}
	
	get_zdiff = function() {
		/// @function			get_ziff()
		/// @description		Return the difference in z height between this road and the next;
		/// @return {real}
		return next_road.z - z;
	}
}

function cutmull_rom(P, t) {
	var tt = t*t;
	var ttt = tt*t;
	
	var px = P[1].x * 2;
	px += (-P[0].x + P[2].x) * t;
	px += ((2*P[0].x) - (5*P[1].x) + (4*P[2].x) - P[3].x) * tt;
	px += (-P[0].x + (3*P[1].x) - (3*P[2].x) + P[3].x) * ttt;
	
	var py = P[1].y * 2;
	py += (-P[0].y + P[2].y) * t;
	py += ((2*P[0].y) - (5*P[1].y) + (4*P[2].y) - P[3].y) * tt;
	py += (-P[0].y + (3*P[1].y) - (3*P[2].y) + P[3].y) * ttt;
	
	var pz = P[1].z * 2;
	pz += (-P[0].z + P[2].z) * t;
	pz += ((2*P[0].z) - (5*P[1].z) + (4*P[2].z) - P[3].z) * tt;
	pz += (-P[0].z + (3*P[1].z) - (3*P[2].z) + P[3].z) * ttt;
	
	
	return new Point3D(px / 2, py / 2, pz/2);
}

function generate_roads(control_points, _steps) {
	/// @function								generate_roads(control_points, _steps, _primary_segment_dist)
	/// @description							Generate roads
	/// @param {array} control_points			array of control points
	/// @param {int} _steps						number of secondary points between primary points
	
	// initialize control points
	var P = control_points;
	var nP = array_length(control_points);
	
	var _road_node_list = []; // hold the road nodes for rendering
	
	//calculate secondary points
	for (var i = 0; i < nP-3; i++) {
		var p = [];
		array_copy(p, 0, P, i, 4); // "array slice"
		for (var j = 0; j < _steps; j++) {
			var t = j/_steps;
			var point = new RoadNode(cutmull_rom(p, t));
			_road_node_list[array_length(_road_node_list)] = point;
		}
	}
	return _road_node_list;
}