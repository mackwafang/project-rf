// Feather disable all
/// @desc Define a directional light. Directional lights are used to simulate a light source that is very bright and very far away; in almost all cases, this means the sun or some other omnipresent source of light.
/// @param {real} index The index of the light source (0 through 64 on Windows, 32 everywhere else)
/// @param {constant.Color} color The color of light source
/// @param {real} dx The x component of the vector representing the light's direction
/// @param {real} dy The y component of the vector representing the light's direction
/// @param {real} dz The z component of the vector representing the light's direction
function cluck_set_light_direction(index, color, dx, dy, dz) {
    var position = index * __cluck_light_data_size;
    var dist = -max(0.001, point_distance_3d(0, 0, 0, dx, dy, dz));
    global.__cluck_light_data[position +  0] = dx / dist;
    global.__cluck_light_data[position +  1] = dy / dist;
    global.__cluck_light_data[position +  2] = dz / dist;
    global.__cluck_light_data[position +  3] = CLUCK_LIGHT_DIRECTIONAL;
    // 4 unused
    // 5 unused
    // 6 unused
    // 7 unused
    global.__cluck_light_data[position +  8] = colour_get_red(color) / 0xff;
    global.__cluck_light_data[position +  9] = colour_get_green(color) / 0xff;
    global.__cluck_light_data[position + 10] = colour_get_blue(color) / 0xff;
    // 11 unused
}