
//@desc render current control point
function render_control_point(cp, range=0) {
	// calculate render polygons
	if (global.road_vertex_buffer == -1) {global.road_vertex_buffer = vertex_create_buffer();}
	if (global.prop_vertex_buffer == -1) {global.prop_vertex_buffer = vertex_create_buffer();}
	var ri_start = max(0, (cp - 2) * obj_road_generator.road_segments);
	var ri_end = min(global.road_list_length, max(1, cp+range) * obj_road_generator.road_segments);
	
	
	vertex_begin(global.road_vertex_buffer, road_vertex_format);
	for (var i = ri_start; i < ri_end - 1; i++) {
		var road = road_list[@ i];
		var next_road = road_list[@ i + 1];
		
		var left_lanes = road.get_lanes_left();
		var right_lanes = road.get_lanes_right();
		var next_left_lanes = next_road.get_lanes_left();
		var next_right_lanes = next_road.get_lanes_right();
		var left_subimage = 2;
		var right_subimage = 2;
		var left_lane_sprite = global.ROAD_SPRITE_INDEX[left_lanes];
		var right_lane_sprite = global.ROAD_SPRITE_INDEX[right_lanes];
		var left_shoulder_uv = sprite_get_uvs(spr_road_shoulder, 0);
		var right_shoulder_uv = sprite_get_uvs(spr_road_shoulder, 0);
		var left_grass_uv = sprite_get_uvs(spr_grass, 0);
		var right_grass_uv = sprite_get_uvs(spr_grass, 0);
		var shoulder_left_z = road.z-5;
		var shoulder_right_z = road.z-5;
		var off_shoulder_left_z = road.beyond_range[0].z;
		var off_shoulder_right_z = road.beyond_range[1].z;
		var next_shoulder_left_z = next_road.z-5;
		var next_shoulder_right_z = next_road.z-5;
		var next_off_shoulder_left_z = next_road.beyond_range[0].z;
		var next_off_shoulder_right_z = next_road.beyond_range[1].z;
		var tunnel_outer_uv = sprite_get_uvs(spr_grass, 4);
		var tunnel_uv = sprite_get_uvs(spr_tunnel_wall, 0);
		var tunnel_roof_uv = sprite_get_uvs(spr_tunnel_wall, 1);
		
		// change grass and shoulder texture
		switch(road.zone) {
			case ZONE.DESERT: case ZONE.BEACH:
				left_shoulder_uv = sprite_get_uvs(spr_road_shoulder, 3);
				right_shoulder_uv = sprite_get_uvs(spr_road_shoulder, 3);
				left_grass_uv = sprite_get_uvs(spr_grass, 2);
				right_grass_uv = sprite_get_uvs(spr_grass, 2);
				break;
			case ZONE.CITY: case ZONE.TOWN: case ZONE.TUNNEL:
				left_shoulder_uv = sprite_get_uvs(spr_road_shoulder, 1);
				right_shoulder_uv = sprite_get_uvs(spr_road_shoulder, 1);
				left_grass_uv = sprite_get_uvs(spr_grass, 1);
				right_grass_uv = sprite_get_uvs(spr_grass, 1);
				break;
			case ZONE.MOUNTAIN:	
				if (((road.zone_feature >> ZONE_FEATURE.MOUNTAIN_SIDE_LEFT-1) & 1) == 1) {
					// mountain on left side
					shoulder_left_z = road.z + 100;
					next_shoulder_left_z = next_road.z + 100;
				}
				
				if (((road.zone_feature >> ZONE_FEATURE.MOUNTAIN_SIDE_RIGHT-1) & 1) == 1) {
					// mountain on right side
					shoulder_right_z = road.z + 100;
					next_shoulder_right_z = next_road.z + 100;
				}
				break;
			case ZONE.RIVER:
				left_shoulder_uv = sprite_get_uvs(spr_road_shoulder, 3);
				right_shoulder_uv = sprite_get_uvs(spr_road_shoulder, 3);
				left_grass_uv = sprite_get_uvs(spr_grass, 3);
				right_grass_uv = sprite_get_uvs(spr_grass, 3);
				shoulder_left_z = road.sea_level;
				shoulder_right_z = road.sea_level;
				next_shoulder_left_z = next_road.sea_level;
				next_shoulder_right_z = next_road.sea_level;
				
				off_shoulder_left_z = road.sea_level;
				off_shoulder_right_z = road.sea_level;
				next_off_shoulder_left_z = next_road.sea_level;
				next_off_shoulder_right_z = next_road.sea_level;
				break;
		}
		
		if (road.zone == ZONE.RIVER and next_road.zone != ZONE.RIVER) {
			shoulder_left_z = road.sea_level;
			shoulder_right_z = road.sea_level;
			next_shoulder_left_z = road.sea_level;
			next_shoulder_right_z = road.sea_level;
			off_shoulder_left_z = road.sea_level;
			off_shoulder_right_z = road.sea_level;
			next_off_shoulder_left_z = road.sea_level;
			next_off_shoulder_right_z = road.sea_level;
		}
		
		// switch road texture during transition
		// lane change 
		if (left_lanes != next_left_lanes) {
			left_lane_sprite = global.ROAD_SPRITE_INDEX[min(left_lanes, next_left_lanes)];
			left_subimage = 2;
		}
		if (right_lanes != next_right_lanes) {
			right_lane_sprite = global.ROAD_SPRITE_INDEX[min(right_lanes, next_right_lanes)];
			right_subimage = 2;
		}
		
		if (road.intersection) {
			// create lane intersection
			if (road.zone == ZONE.BEACH) {
				var seed = random_get_seed();
				var side = seed % 2;
				if (side == 0) {
					left_shoulder_uv = sprite_get_uvs(spr_road_shoulder, 2);
					left_grass_uv = sprite_get_uvs(spr_road_side, 0);
				}
				if (side == 1) {
					right_shoulder_uv = sprite_get_uvs(spr_road_shoulder, 2);
					right_grass_uv = sprite_get_uvs(spr_road_side, 0);
				}
			}
			else {
				left_shoulder_uv = sprite_get_uvs(spr_road_shoulder, 2);
				right_shoulder_uv = sprite_get_uvs(spr_road_shoulder, 2);
				left_grass_uv = sprite_get_uvs(spr_road_side, 0);
				right_grass_uv = sprite_get_uvs(spr_road_side, 0);
			}
			left_subimage = 0;
			right_subimage = 0;
		}
		else {
			// change road sprite for crosswalk
			if (next_road.intersection) {
				left_subimage = 4;
				right_subimage = 4;
			}
			if (i > 0) {
				if (road_list[@ i-1].intersection) {
					left_subimage = 3;
					right_subimage = 3;
				}
			}
		}
		
		if (i == global.destination_road_index) {
			left_lane_sprite = spr_checkered;
			right_lane_sprite = spr_checkered;
			left_subimage = 0;
			right_subimage = 0;
		}
	
		var left_uv = sprite_get_uvs(left_lane_sprite, left_subimage);		// left lanes uv
		var right_uv = sprite_get_uvs(right_lane_sprite, right_subimage);	// right lanes uv
		var left_change_uv = sprite_get_uvs(spr_road_1_lane, 0);			// left lanes uv for lane change
		var right_change_uv = sprite_get_uvs(spr_road_1_lane, 0);			// right lanes uv for lane change
		var road_render_points = [
			 [
				road.x+lengthdir_x(lane_width*min(left_lanes, next_left_lanes), road.direction+90),
				next_road.x+lengthdir_x(lane_width*min(left_lanes, next_left_lanes), next_road.direction+90),
				next_road.x+lengthdir_x(lane_width*min(right_lanes, next_right_lanes), next_road.direction-90),
				road.x+lengthdir_x(lane_width*min(right_lanes, next_right_lanes), road.direction-90),
			],
			[
				road.y+lengthdir_y(lane_width*min(left_lanes, next_left_lanes), road.direction+90),
				next_road.y+lengthdir_y(lane_width*min(left_lanes, next_left_lanes), next_road.direction+90),
				next_road.y+lengthdir_y(lane_width*min(right_lanes, next_right_lanes), next_road.direction-90),
				road.y+lengthdir_y(lane_width*min(right_lanes, next_right_lanes), road.direction-90),
			]
		];
		var shoulder_coord = {
			left: [
				[road.x+lengthdir_x(lane_width * (left_lanes), road.direction+90),					road.y+lengthdir_y(lane_width * (left_lanes), road.direction+90)],
				[next_road.x+lengthdir_x(lane_width * next_left_lanes, next_road.direction+90),		next_road.y+lengthdir_y(lane_width * next_left_lanes, next_road.direction+90)],
				[next_road.x+lengthdir_x(lane_width * (next_left_lanes+1), next_road.direction+90),	next_road.y+lengthdir_y(lane_width * (next_left_lanes+1), next_road.direction+90)],
				[road.x+lengthdir_x(lane_width * (left_lanes+1), road.direction+90),				road.y+lengthdir_y(lane_width * (left_lanes+1), road.direction+90)],
			],
			right: [
				[next_road.x+lengthdir_x(lane_width * next_right_lanes, next_road.direction-90),	next_road.y+lengthdir_y(lane_width * next_right_lanes, next_road.direction-90)],
				[road.x+lengthdir_x(lane_width * (right_lanes), road.direction-90),					road.y+lengthdir_y(lane_width * (right_lanes), road.direction-90)],
				[road.x+lengthdir_x(lane_width * (right_lanes+1), road.direction-90),				road.y+lengthdir_y(lane_width * (right_lanes+1), road.direction-90)],
				[next_road.x+lengthdir_x(lane_width*(next_right_lanes+1), next_road.direction-90),	next_road.y+lengthdir_y(lane_width*(next_right_lanes+1), next_road.direction-90)],
			]
		}
		var grass_coord = {
			left: [
				[road.x+lengthdir_x(lane_width * (left_lanes+1), road.direction+90),					road.y+lengthdir_y(lane_width * (left_lanes+1), road.direction+90),				 road.z],
				[next_road.x+lengthdir_x(lane_width * (next_left_lanes+1), next_road.direction+90),	next_road.y+lengthdir_y(lane_width * (next_left_lanes+1), next_road.direction+90), next_road.z],
				[next_road.beyond_range[0].x, next_road.beyond_range[0].y, next_road.beyond_range[0].z],
				[road.beyond_range[0].x, road.beyond_range[0].y, next_road.beyond_range[0].z]
				//[shoulder_coord.left[2][0]+lengthdir_x(next_road.beyond_range, next_road.direction+90), shoulder_coord.left[2][1]+lengthdir_y(next_road.beyond_range, next_road.direction+90)],
				//[shoulder_coord.left[3][0]+lengthdir_x(road.beyond_range, road.direction+90), shoulder_coord.left[3][1]+lengthdir_y(road.beyond_range, road.direction+90)]
			],
			right: [
				[next_road.x+lengthdir_x(lane_width * (next_right_lanes+1), next_road.direction-90),	next_road.y+lengthdir_y(lane_width * (next_right_lanes+1), next_road.direction-90),	next_road.z],
				[road.x+lengthdir_x(lane_width * (right_lanes+1), road.direction-90),					road.y+lengthdir_y(lane_width * (right_lanes+1), road.direction-90),					road.z],
				[road.beyond_range[1].x, road.beyond_range[1].y, next_road.beyond_range[1].z],
				[next_road.beyond_range[1].x, next_road.beyond_range[1].y, next_road.beyond_range[1].z],
				//[shoulder_coord.right[2][0]+lengthdir_x(road.beyond_range, road.direction-90), shoulder_coord.right[2][1]+lengthdir_y(road.beyond_range, road.direction-90)],
				//[shoulder_coord.right[3][0]+lengthdir_x(next_road.beyond_range, next_road.direction-90), shoulder_coord.right[3][1]+lengthdir_y(next_road.beyond_range, next_road.direction-90)],
			]
		}
		
		// post initalization adjustments
		// adjust grass cord for mountain zones
		if (road.zone == ZONE.MOUNTAIN) {
			if (((road.zone_feature >> ZONE_FEATURE.MOUNTAIN_SIDE_LEFT-1) & 1) == 1) {
				grass_coord.left[0] = [
					road.x+lengthdir_x(lane_width * (left_lanes+1),
					road.direction+90), road.y+lengthdir_y(lane_width * (left_lanes+1), road.direction+90),
					road.z
				];
				grass_coord.left[1] = [
					next_road.x+lengthdir_x(lane_width * (next_left_lanes+1), next_road.direction+90),
					next_road.y+lengthdir_y(lane_width * (next_left_lanes+1), next_road.direction+90),
					next_road.z
				];
			}
			
			if (((road.zone_feature >> ZONE_FEATURE.MOUNTAIN_SIDE_RIGHT-1) & 1) == 1) {
				grass_coord.right[0] = [
					next_road.x+lengthdir_x(lane_width * (next_right_lanes+1), next_road.direction-90),
					next_road.y+lengthdir_y(lane_width * (next_right_lanes+1), next_road.direction-90),	
					next_road.z
				];
				grass_coord.right[1] = [
					road.x+lengthdir_x(lane_width * (right_lanes+1), road.direction-90),
					road.y+lengthdir_y(lane_width * (right_lanes+1), road.direction-90),
					road.z
				];
			}
		}
		
		#region Road Render Polygons
		var road_seg_data = array_concat(
			// left grass
			polygon_create_square_points_3d(
				new Point3D(grass_coord.left[2][0], grass_coord.left[2][1], next_off_shoulder_left_z),
				new Point3D(grass_coord.left[1][0], grass_coord.left[1][1], next_shoulder_left_z),
				new Point3D(grass_coord.left[0][0], grass_coord.left[0][1], shoulder_left_z),
				new Point3D(grass_coord.left[3][0], grass_coord.left[3][1], off_shoulder_left_z),
				left_grass_uv
			),
			
			// left shoulder
			polygon_create_square_points_3d(
				new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.z + next_road.shoulder_z[0]),
				new Point3D(shoulder_coord.left[1][0], shoulder_coord.left[1][1], next_road.z + next_road.shoulder_z[0]),
				new Point3D(shoulder_coord.left[0][0], shoulder_coord.left[0][1], road.z + road.shoulder_z[0]),
				new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + road.shoulder_z[0]),
				left_shoulder_uv
			),
			
			// left shoulder wall
			polygon_create_square_points_3d(
				new Point3D(shoulder_coord.left[0][0], shoulder_coord.left[0][1], road.z),
				new Point3D(shoulder_coord.left[0][0], shoulder_coord.left[0][1], road.z + road.shoulder_z[0]),
				new Point3D(shoulder_coord.left[1][0], shoulder_coord.left[1][1], next_road.z + next_road.shoulder_z[0]),
				new Point3D(shoulder_coord.left[1][0], shoulder_coord.left[1][1], next_road.z),
				left_shoulder_uv
			),
			
			// left road
			polygon_create_square_points_3d(
				new Point3D(road_render_points[0][1], road_render_points[1][1], next_road.z),
				new Point3D(next_road.x, next_road.y, next_road.z),
				new Point3D(road.x, road.y, road.z),
				new Point3D(road_render_points[0][0], road_render_points[1][0], road.z),
				left_uv
			),
			
			// right road
			polygon_create_square_points_3d(
				new Point3D(next_road.x, next_road.y, next_road.z),
				new Point3D(road_render_points[0][2], road_render_points[1][2], next_road.z),
				new Point3D(road_render_points[0][3], road_render_points[1][3], road.z),
				new Point3D(road.x, road.y, road.z),
				[right_uv[2], right_uv[1], right_uv[0], right_uv[3]] // flip left and right uv
			),
			
			// right shoulder wall
			polygon_create_square_points_3d(
				new Point3D(shoulder_coord.right[1][0], shoulder_coord.right[1][1], road.z + road.shoulder_z[1]),
				new Point3D(shoulder_coord.right[1][0], shoulder_coord.right[1][1], road.z),
				new Point3D(shoulder_coord.right[0][0], shoulder_coord.right[0][1], next_road.z),
				new Point3D(shoulder_coord.right[0][0], shoulder_coord.right[0][1], next_road.z + next_road.shoulder_z[1]),
				right_shoulder_uv
			),
			
			// right shoulder
			polygon_create_square_points_3d(
				new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + road.shoulder_z[1]),
				new Point3D(shoulder_coord.right[1][0], shoulder_coord.right[1][1], road.z + road.shoulder_z[1]),
				new Point3D(shoulder_coord.right[0][0], shoulder_coord.right[0][1], next_road.z + next_road.shoulder_z[1]),
				new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.z + next_road.shoulder_z[1]),
				right_shoulder_uv
			),
			
			// right grass
			polygon_create_square_points_3d(
				new Point3D(grass_coord.right[2][0], grass_coord.right[2][1], off_shoulder_right_z),
				new Point3D(grass_coord.right[1][0], grass_coord.right[1][1], shoulder_right_z),
				new Point3D(grass_coord.right[0][0], grass_coord.right[0][1], next_shoulder_right_z),
				new Point3D(grass_coord.right[3][0], grass_coord.right[3][1], next_off_shoulder_right_z),
				right_grass_uv
			),
		);
        
        #region Add polygon to cover hole from transition from non-mountain to mountain
        
		if (road.zone != ZONE.MOUNTAIN and next_road.zone == ZONE.MOUNTAIN) {
            road_seg_data = array_concat(
                road_seg_data, 
                polygon_create_triangle_points_3d(
                    new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.z),
                    new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.z+100),
                    new Point3D(grass_coord.left[2][0], grass_coord.left[2][1], next_off_shoulder_left_z),
                    new Point(left_grass_uv[0], left_grass_uv[1]),
                    new Point(left_grass_uv[2], left_grass_uv[3]),
                    new Point(left_grass_uv[2], left_grass_uv[1])
                ),
            );
            road_seg_data = array_concat(
                road_seg_data, 
                polygon_create_triangle_points_3d(
                    new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.z),
                    new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.z+100),
                    new Point3D(grass_coord.right[3][0], grass_coord.right[3][1], next_off_shoulder_right_z),
                    new Point(right_grass_uv[0], right_grass_uv[1]),
                    new Point(right_grass_uv[2], right_grass_uv[3]),
                    new Point(right_grass_uv[2], right_grass_uv[1])
                ),
            );
        }
        #endregion
		
		// create tunnel polygons
		if (road.zone == ZONE.TUNNEL) {
			#region main tunnel
			road_seg_data = array_concat(
				road_seg_data, 
				//right tunnel wall
				polygon_create_square_points_3d(
					new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + (tunnel_height / 2)),
					new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.z + (tunnel_height / 2)),
					new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.z),
					new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z),
					tunnel_uv
				),
				
				// left angled roof
				polygon_create_square_points_3d(
					new Point3D(shoulder_coord.left[0][0], shoulder_coord.left[0][1], road.z + tunnel_height),
					new Point3D(shoulder_coord.left[1][0], shoulder_coord.left[1][1], next_road.z + tunnel_height),
					new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.z + (tunnel_height / 2)),
					new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + (tunnel_height / 2)),
					tunnel_uv
				),
				
				//right tunnel wall
				polygon_create_square_points_3d(
					new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.z + (tunnel_height / 2)),
					new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + (tunnel_height / 2)),
					new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z),
					new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.z),
					tunnel_uv
				),
				
				//right angled roof
				polygon_create_square_points_3d(
					new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + (tunnel_height / 2)),
					new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.z + (tunnel_height / 2)),
					new Point3D(shoulder_coord.right[0][0], shoulder_coord.right[0][1], next_road.z + tunnel_height),
					new Point3D(shoulder_coord.right[1][0], shoulder_coord.right[1][1], road.z + tunnel_height),
					tunnel_uv
				),
				
				// roof
				polygon_create_square_points_3d(
					new Point3D(shoulder_coord.left[1][0], shoulder_coord.left[1][1], next_road.z + tunnel_height),
					new Point3D(shoulder_coord.left[0][0], shoulder_coord.left[0][1], road.z + tunnel_height),
					new Point3D(shoulder_coord.right[1][0], shoulder_coord.right[1][1], road.z + tunnel_height),
					new Point3D(shoulder_coord.right[0][0], shoulder_coord.right[0][1], next_road.z + tunnel_height),
					tunnel_roof_uv
				),
			);
			#endregion
			#region create wall to hide culled side
			if (road_list[@i-1].zone != ZONE.TUNNEL) {
				// left triangle dirt
				road_seg_data = array_concat(
					road_seg_data, 
					polygon_create_triangle_points_3d(
						new Point3D(shoulder_coord.left[0][0], shoulder_coord.left[0][1], road.z + tunnel_height),
						new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + tunnel_height),
						new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + (tunnel_height / 2)),
						new Point(tunnel_outer_uv[0], tunnel_outer_uv[1]),
						new Point(tunnel_outer_uv[2], tunnel_outer_uv[1]),
						new Point(tunnel_outer_uv[2], tunnel_outer_uv[3])
					),
				);
				
				// left off grid dirt
				road_seg_data = array_concat(
					road_seg_data, 
					polygon_create_square_points_3d(
						new Point3D(grass_coord.left[3][0], grass_coord.left[3][1], off_shoulder_right_z + tunnel_height),
						new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + tunnel_height),
						new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z),
						new Point3D(grass_coord.left[3][0], grass_coord.left[3][1], off_shoulder_right_z),
						tunnel_outer_uv
					),
				);
				
				// right triangle dirt
				road_seg_data = array_concat(
					road_seg_data, 
					polygon_create_triangle_points_3d(
						new Point3D(shoulder_coord.right[1][0], shoulder_coord.right[1][1], road.z + tunnel_height),
						new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + (tunnel_height / 2)),
						new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + tunnel_height),
						new Point(tunnel_outer_uv[0], tunnel_outer_uv[1]),
						new Point(tunnel_outer_uv[2], tunnel_outer_uv[3]),
						new Point(tunnel_outer_uv[2], tunnel_outer_uv[1])
					),
				);
				// right off grid dirt
				road_seg_data = array_concat(
					road_seg_data, 
					polygon_create_square_points_3d(
						new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + tunnel_height),
						new Point3D(grass_coord.right[2][0], grass_coord.right[2][1], off_shoulder_right_z + tunnel_height),
						new Point3D(grass_coord.right[2][0], grass_coord.right[2][1], off_shoulder_right_z),
						new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z),
						tunnel_outer_uv
					),
				);
				
				var tunnel_z_side = road.z + tunnel_height + max(road_list[@i-1].beyond_range[0].z, road_list[@i-1].beyond_range[1].z);
				// center
				road_seg_data = array_concat(
					road_seg_data, 
					polygon_create_square_points_3d(
						new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + tunnel_height),
						new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + tunnel_height*2),
						new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + tunnel_height*2),
						new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + tunnel_height),
						tunnel_outer_uv
					),
				);
				if (((road_list[@i-1].zone_feature >> ZONE_FEATURE.MOUNTAIN_SIDE_LEFT-1) & 1) == 1) {
					// top-left
					road_seg_data = array_concat(
						road_seg_data, 
						polygon_create_triangle_points_3d(
							new Point3D(grass_coord.left[3][0], grass_coord.left[3][1], tunnel_z_side),
							new Point3D(grass_coord.left[3][0], grass_coord.left[3][1], road.z + tunnel_height*2),
							new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + tunnel_height*2),
							new Point(tunnel_outer_uv[0], tunnel_outer_uv[1]),
							new Point(tunnel_outer_uv[2], tunnel_outer_uv[3]),
							new Point(tunnel_outer_uv[2], tunnel_outer_uv[1])
						),
					);
					// middle-left
					road_seg_data = array_concat(
						road_seg_data, 
						polygon_create_square_points_3d(
							new Point3D(grass_coord.left[3][0], grass_coord.left[3][1], road.z + tunnel_height),
							new Point3D(grass_coord.left[3][0], grass_coord.left[3][1], road.z + tunnel_height*2),
							new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + tunnel_height*2),
							new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + tunnel_height),
							tunnel_outer_uv
						),
					);
					// top-right
					road_seg_data = array_concat(
						road_seg_data, 
						polygon_create_triangle_points_3d(
							new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + tunnel_height*2),
							new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + tunnel_height),
							new Point3D(grass_coord.right[2][0], grass_coord.right[2][1], road.z + tunnel_height),
							new Point(tunnel_outer_uv[0], tunnel_outer_uv[1]),
							new Point(tunnel_outer_uv[2], tunnel_outer_uv[3]),
							new Point(tunnel_outer_uv[2], tunnel_outer_uv[1])
						),
					);
				}
				
				if (((road_list[@i-1].zone_feature >> ZONE_FEATURE.MOUNTAIN_SIDE_RIGHT-1) & 1) == 1) {
					// top-left
					road_seg_data = array_concat(
						road_seg_data, 
						polygon_create_triangle_points_3d(
							new Point3D(grass_coord.right[2][0], grass_coord.right[2][1], road.z + tunnel_height*2),
							new Point3D(grass_coord.right[2][0], grass_coord.right[2][1], tunnel_z_side),
							new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + tunnel_height*2),
							new Point(tunnel_outer_uv[0], tunnel_outer_uv[1]),
							new Point(tunnel_outer_uv[2], tunnel_outer_uv[3]),
							new Point(tunnel_outer_uv[2], tunnel_outer_uv[1])
						),
					);
					// middle-left
					road_seg_data = array_concat(
						road_seg_data, 
						polygon_create_square_points_3d(
							new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + tunnel_height),
							new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.z + tunnel_height*2),
							new Point3D(grass_coord.right[2][0], grass_coord.right[2][1], road.z + tunnel_height*2),
							new Point3D(grass_coord.right[2][0], grass_coord.right[2][1], road.z + tunnel_height),
							tunnel_outer_uv
						),
					);
					// top-right
					road_seg_data = array_concat(
						road_seg_data, 
						polygon_create_triangle_points_3d(
							new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + tunnel_height),
							new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.z + tunnel_height*2),
							new Point3D(grass_coord.left[3][0], grass_coord.left[3][1], road.z + tunnel_height),
							new Point(tunnel_outer_uv[0], tunnel_outer_uv[1]),
							new Point(tunnel_outer_uv[2], tunnel_outer_uv[3]),
							new Point(tunnel_outer_uv[2], tunnel_outer_uv[1])
						),
					);
				}
				
			}
			#endregion
			
		}
		
		// added missing segment when lane changes
		if (road.get_lanes() != next_road.get_lanes()) {
			road_seg_data = array_concat(road_seg_data,[
				[new Point3D(road_render_points[0][0], road_render_points[1][0], road.z), new Point(left_change_uv[2], left_change_uv[1])],
				[new Point3D(road_render_points[0][1], road_render_points[1][1], next_road.z), new Point(left_change_uv[2], left_change_uv[3])],
				[new Point3D(
					(left_lanes > next_left_lanes) ? shoulder_coord.left[0][0] : shoulder_coord.left[1][0], 
					(left_lanes > next_left_lanes) ? shoulder_coord.left[0][1] : shoulder_coord.left[1][1], 
					(left_lanes > next_left_lanes) ? road.z : next_road.z
				), new Point(right_change_uv[0], (right_lanes > next_right_lanes) ? right_change_uv[1] : right_change_uv[3])],
				
				[new Point3D(road_render_points[0][2], road_render_points[1][2], next_road.z), new Point(right_change_uv[0], right_change_uv[3])],
				[new Point3D(road_render_points[0][3], road_render_points[1][3], road.z), new Point(right_change_uv[0], right_change_uv[1])],
				[new Point3D(
					(right_lanes > next_right_lanes) ? shoulder_coord.right[1][0] : shoulder_coord.right[0][0], 
					(right_lanes > next_right_lanes) ? shoulder_coord.right[1][1] : shoulder_coord.right[0][1], 
					(right_lanes > next_right_lanes) ? road.z : next_road.z
				), new Point(right_change_uv[2], (right_lanes > next_right_lanes) ? right_change_uv[1] : right_change_uv[3])],
			]);
		}
		if (i > 0) {
			if (road.zone == ZONE.RIVER) {
				road_seg_data = array_concat(road_seg_data,[
					// missing grass floor on the center
					[new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.sea_level), new Point(left_grass_uv[0], left_grass_uv[1])],
					[new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.sea_level), new Point(left_grass_uv[2], left_grass_uv[3])],
					[new Point3D(shoulder_coord.left[2][0], shoulder_coord.left[2][1], next_road.sea_level), new Point(left_grass_uv[0], left_grass_uv[3])],
					
					[new Point3D(shoulder_coord.left[3][0], shoulder_coord.left[3][1], road.sea_level), new Point(left_grass_uv[0], left_grass_uv[1])],
					[new Point3D(shoulder_coord.right[2][0], shoulder_coord.right[2][1], road.sea_level), new Point(left_grass_uv[2], left_grass_uv[1])],
					[new Point3D(shoulder_coord.right[3][0], shoulder_coord.right[3][1], next_road.sea_level), new Point(left_grass_uv[2], left_grass_uv[3])],
				]);
			}
			
			if (road.zone != ZONE.RIVER && road_list[@ i-1].zone == ZONE.RIVER) {
				var prev_road = road_list[@ i-1];
				road_seg_data = array_concat(road_seg_data,[
					// wall
					[new Point3D(road.x, road.y, road.z), new Point(right_grass_uv[0], right_grass_uv[1])],
					[new Point3D(road.x, road.y, prev_road.sea_level), new Point(right_grass_uv[0], right_grass_uv[3])],
					[new Point3D(road.beyond_range[1].x, road.beyond_range[1].y, road.z), new Point(right_grass_uv[2], right_grass_uv[1])],
		
					[new Point3D(road.x, road.y, prev_road.sea_level), new Point(right_grass_uv[0], right_grass_uv[3])],
					[new Point3D(road.beyond_range[1].x, road.beyond_range[1].y, prev_road.sea_level), new Point(right_grass_uv[2], right_grass_uv[3])],
					[new Point3D(road.beyond_range[1].x, road.beyond_range[1].y, road.z), new Point(right_grass_uv[2], right_grass_uv[1])],
					
					
					[new Point3D(road.x, road.y, road.z), new Point(left_grass_uv[0], left_grass_uv[1])],
					[new Point3D(road.beyond_range[0].x, road.beyond_range[0].y, road.z), new Point(left_grass_uv[2], left_grass_uv[1])],
					[new Point3D(road.x, road.y, prev_road.sea_level), new Point(left_grass_uv[0], left_grass_uv[3])],
		
					[new Point3D(road.x, road.y, prev_road.sea_level), new Point(left_grass_uv[0], left_grass_uv[3])],
					[new Point3D(road.beyond_range[0].x, road.beyond_range[0].y, road.z), new Point(left_grass_uv[2], left_grass_uv[1])],
					[new Point3D(road.beyond_range[0].x, road.beyond_range[0].y, prev_road.sea_level), new Point(left_grass_uv[2], left_grass_uv[3])],
				]);
			}
		}
		
		for (var di = 0; di < array_length(road_seg_data); di++) {
			var data = road_seg_data[di];
			var pos = data[0];
			var uv = data[1];
			if (global.CAMERA_MODE_3D) {vertex_position_3d(global.road_vertex_buffer, pos.x, pos.y, pos.z - 3);} else {vertex_position(global.road_vertex_buffer, pos.x, pos.y);}
			vertex_color(global.road_vertex_buffer, c_white, 1);
			vertex_texcoord(global.road_vertex_buffer, uv.x, uv.y);
			vertex_normal(global.road_vertex_buffer, 0, 0, 1);
			
		}
		
		for (var p_i = 0; p_i < array_length(road.buildings); p_i++) {
			road.buildings[p_i].init_vertex_buffer();
		}
		#endregion
	}
	vertex_end(global.road_vertex_buffer);
	global.road_vertex_buffer = calc_vertex_normal(global.road_vertex_buffer, road_vertex_format);
	vertex_freeze(global.road_vertex_buffer);	
	
	
	vertex_begin(global.prop_vertex_buffer, prop_vertex_format);
	for (var i = ri_start; i < ri_end - 1; i++) {
		var road = road_list[@ i];
		for (var p_i = 0; p_i < array_length(road.props); p_i++) {
			road.props[p_i].init_vertex_buffer();
		}
	}
	vertex_end(global.prop_vertex_buffer);
	if (vertex_get_number(global.prop_vertex_buffer) > 0) {
		global.prop_vertex_buffer = calc_vertex_normal(global.prop_vertex_buffer, prop_vertex_format);
		vertex_freeze(global.prop_vertex_buffer);
	}
}