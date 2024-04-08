function torque_lookup(rpm) {
	var torque_table = [
		50,			// 0k rpm
		400,		// 1k rpm
		420,		// 2k rpm
		500,		// 3k rpm
		510,		// 4k rpm
		520,		// 5k rpm
		490,		// 6k rpm
		470,		// 7k rpm
		430,		// 8k rpm
		400,		// 9k rpm
		300,		// 10k rpm
	]
	var index = max(1, min(array_length(torque_table)-2, rpm div 1000));
	var lerp_value = (rpm - (rpm div 1000)) / 1000;
	return lerp(torque_table[index-1], torque_table[index], lerp_value);
}