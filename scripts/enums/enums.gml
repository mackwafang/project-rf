enum ROAD_LANE_CHANGE_AFFECT {
	NONE,
	LEFT,
	RIGHT,
	BOTH
}

enum VEHICLE_TYPE {
	NONE,
	CAR,
	BIKE,
	TRUCK
}

// defines the state of the bike (i.e. driving, rolling, walking)
enum BIKER_STATE {
	DRIVING, // ditto
	ROLLING, // after crash while going at a high speed
	GETUP,	 // recover from rolling
	WALKING, // walking to bike
	GETON,   // getting on bike
	WIN, 	 // placed a certain rank after crossing victory line
}

enum ZONE {
	CITY,
	TOWN,
	SUBURBAN,
	DESERT,
	BEACH,
	RIVER,
	FOREST,
	MOUNTAIN,
	TUNNEL,
}

enum ZONE_FEATURE {
	NONE,
	TUNNEL,
	MOUNTAIN_SIDE_LEFT,
	MOUNTAIN_SIDE_RIGHT,
	BEACH_LEFT,
	BEACH_RIGHT,
}

enum COURSES {
	CITY,
	SUBURBAN,
	DESERT,
	MOUNTAIN,
	HILL,
	PACIFIC,
	RANDOM,
}

enum INTERFACE_MODE {
	NONE = 0,
	FULL = 1,
	SIMPLE = 2
}

enum GAME_DISPLAY_MODE {
    WINDOWED = 0,
    BORDERLESS = 1
}

enum MEASURE {
	METRIC,
	IMPERIAL
}