global.DEBUG_ROAD_DRAW_CONTROL_POINTS = false;
global.DEBUG_ROAD_DRAW_ROAD_POINTS = false;
global.DEBUG_ROAD_DRAW_ROAD_LANES_POINTS = false;
global.DEBUG_ROAD_DRAW_COLLISION_POINTS = false;
global.DEBUG_DRAW_MINIMAP = false;
global.DEBUG_CAR = false;

global.DEBUG_FREE_CAMERA = false;

global.GAMEPLAY_TURN_GUIDE = true;
global.GAMEPLAY_CARS = true;
global.GAMEPLAY_TREES = true;
global.GAMEPLAY_MEASURE_METRICS = MEASURE.IMPERIAL;

global.CAMERA_MODE_3D = true;

global.WORLD_TO_REAL_SCALE = 1.5;
global.REAL_TO_WORLD_SCALE = 1/global.WORLD_TO_REAL_SCALE;

global.LEVEL_TO_DIFFICULTY = [1, 1.25, 1.5, 1.75, 2];

// player_input
global.player_input = {
	accelerate: ord("C"),
	boost: ord("X"),
	brake: ord("Z"),
	turn: {
		left: vk_left,
		right: vk_right,
	}
}