// Feather disable all
/// @desc Function Disable a light at a specific index.
/// @param {real} index The index of the light source to disable (0 through 64 on Windows, 32 on everything else)
function cluck_set_light_disable(index) {
    var position = index * __cluck_light_data_size;
    global.__cluck_light_data[position +  0] = 0;
    global.__cluck_light_data[position +  1] = 0;
    global.__cluck_light_data[position +  2] = 0;
    global.__cluck_light_data[position +  3] = CLUCK_IS_WINDOWS ? CLUCK_LIGHT_NONE : CLUCK_LIGHT_DIRECTIONAL;
    global.__cluck_light_data[position +  4] = 0;
    global.__cluck_light_data[position +  5] = 0;
    global.__cluck_light_data[position +  6] = 0;
    global.__cluck_light_data[position +  7] = 0;
    global.__cluck_light_data[position +  8] = 0;
    global.__cluck_light_data[position +  9] = 0;
    global.__cluck_light_data[position + 10] = 0;
    global.__cluck_light_data[position + 11] = 0;
}