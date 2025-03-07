if (global.game_state_paused) {exit;}
	
/************ vertical height ************/
if (_z_restrict) {
    var road = on_road_index;
    //var lerp_value = point_distance(road.x, road.y, vec_to_road.x, vec_to_road.y) / road.length;
    //zlerp = lerp(road.z, road.next_road.z, lerp_value);
    if (is_undefined(on_road_index)) {
        exit;
    }
    
    var road_col_x = road.collision_points[0];
    var road_col_y = road.collision_points[1];
    var road_col_z = road.collision_points[2];
    var lerp_value = clamp(
        point_distance_3d(road.x, road.y, road.z, vec_to_road_3d.x, vec_to_road_3d.y, vec_to_road_3d.z) / road.length,
        0,
        1
    );
    var lerp_left = lerp_3d(
        [road_col_x[0], road_col_y[0], road_col_z[0]], 
        [road_col_x[1], road_col_y[1], road_col_z[1]], 
        lerp_value
    );
    var lerp_right = lerp_3d(
        [road_col_x[3], road_col_y[3], road_col_z[3]], 
        [road_col_x[2], road_col_y[2], road_col_z[2]], 
        lerp_value
    );
    zlerp = lerp_3d(lerp_left, lerp_right, point_distance_3d(x, y, z, vec_to_road_3d.x, vec_to_road_3d.y, vec_to_road_3d.z)  / road.length)[2];
    
    vertical_on_road = (z+zspeed <= zlerp);
    
    if (on_road_index.zone == ZONE.RIVER) {
        if (!on_road) {
            zlerp += on_road_index.sea_level;
        }
        
        // vertical_on_road = on_road;
        //if (on_road && z < zlerp - min(20, abs(on_road_index.z - on_road_index.next_road.z)*2)) {
        //	vertical_on_road = false;
        //	on_road = false;
        //}
    }
    
    if (vertical_on_road) {
        zspeed += -sin(on_road_index.elevation) * global.deltatime;
        if (!on_road && on_road_index.zone != ZONE.RIVER) {
            zspeed += (global.gravity_3d) * global.deltatime / 2;
        }
    }
    else {
        // FREE FALLING
        zspeed -= (global.gravity_3d) * 1 * global.deltatime;
        if (z+zspeed <= zlerp) {
            if (zspeed > global.gravity_3d) {
                zspeed *= -1/3;
                //turn_rate *= 3;
            }
        }
    }
    z += zspeed;
    z = clamp(z, zlerp, zlerp + 500);
    
	// kill zone
    if (z < on_road_index.z - 400) {
        hp = 0;
        //print($"object {id} (part_of_race: {ai_behavior.part_of_race}, reverse: {ai_behavior.reversed_direction}) destroyed. Out of z-bound");
    }
}
// crash timer count down
// from ground to standup
if (crash_timer.to_stand > 0) {
	crash_timer.to_stand -= global.deltatime;
	if (crash_timer.to_stand <= 0) {
		crash_timer.is_walking = true;
		on_stand_up();
	}
}

// from walking to get on
if (crash_timer.to_get_on > 0) {
	crash_timer.to_get_on -= global.deltatime;
	if (crash_timer.to_get_on <= 0) {
		crash_timer.is_walking = false;
		on_respawn();
	}
}

if (hit_immune > 0) {
	hit_immune -= global.deltatime;
}