global.DEBUG_ROAD_DRAW_CONTROL_POINTS = false;
global.DEBUG_ROAD_DRAW_ROAD_POINTS = false;
global.DEBUG_ROAD_DRAW_ROAD_LANES_POINTS = false;
global.DEBUG_ROAD_DRAW_COLLISION_POINTS = false;
global.DEBUG_DRAW_MINIMAP = false;
global.DEBUG_CAR = false;
global.DEBUG_STRAIGHT_MAP = false;
global.DEBUG_SPRITE_UV_TESTER_UV = texture_get_uvs(sprite_get_texture(spr_uv_test, 0));
global.DEBUG_PRINT = false;
global.DEBUG_PRINT_VEHICLE_CRASH_REASON = false;

global.DEBUG_FREE_CAMERA = false;

global.GAMEPLAY_TURN_GUIDE = true;
global.GAMEPLAY_CARS = true;
global.GAMEPLAY_TREES = true;
global.GAMEPLAY_MEASURE_METRICS = MEASURE.METRIC;
global.GAMEPLAY_LIGHTING = false;
global.GAMEPLAY_COURSE = COURSES.CITY;
global.GAMEPLAY_COURSE_ZONE_WEIGHT = {
	CITY: {
		STARTING_ZONE: ZONE.CITY,
		ZONES: [ZONE.CITY, ZONE.TOWN, ZONE.SUBURBAN, ZONE.TUNNEL, ZONE.RIVER],
		WEIGTHS: [100, 50, 30, 20, 5],
		MIN_LANES: 2,
		MAX_LANES: 3,
		Z_ROUGHNESS: 50,
	},
	SUBURBAN: {
		STARTING_ZONE: ZONE.TOWN,
		ZONES: [ZONE.TOWN, ZONE.FOREST, ZONE.SUBURBAN, ZONE.RIVER],
		WEIGTHS: [100, 200, 100, 10],
		MIN_LANES: 1,
		MAX_LANES: 2,
		Z_ROUGHNESS: 50,
	},
	DESERT: {
		STARTING_ZONE: ZONE.DESERT,
		ZONES: [ZONE.TOWN, ZONE.DESERT],
		WEIGTHS: [20, 100],
		MIN_LANES: 1,
		MAX_LANES: 2,
		Z_ROUGHNESS: 200,
	},
	MOUNTAIN: {
		STARTING_ZONE: ZONE.SUBURBAN,
		ZONES: [ZONE.FOREST, ZONE.RIVER, ZONE.SUBURBAN, ZONE.TOWN],
		WEIGTHS: [200, 30, 20, 50],
		MIN_LANES: 1,
		MAX_LANES: 2,
		Z_ROUGHNESS: 100,
	},
	HILL: {
		STARTING_ZONE: ZONE.FOREST,
		ZONES: [ZONE.MOUNTAIN, ZONE.TUNNEL],
		WEIGTHS: [500, 100],
		MIN_LANES: 1,
		MAX_LANES: 2,
		Z_ROUGHNESS: 200,
	},
}

global.CAMERA_MODE_3D = true;

global.WORLD_TO_REAL_SCALE = 1.4;
global.REAL_TO_WORLD_SCALE = 1/global.WORLD_TO_REAL_SCALE;

global.ROAD_SPRITE_INDEX = [
	undefined,
	spr_road_1_lane,
	spr_road_2_lane,
	spr_road_3_lane,
]

global.LEVEL_TO_DIFFICULTY = [1, 1.25, 1.5, 1.75, 2];
global.IDENTITY_MATRIX = matrix_build_identity();

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