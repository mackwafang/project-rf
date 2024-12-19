// Feather disable all
/// @desc  Use this function to enable or disable distance fog.
/// @param {bool} enabled True if distance fog is to be enabled, false otherwise
/// @param {constant.Color} color The color of the fog
/// @param {real} strength The strength of the fog at the end distance (from 0 to 1)
/// @param {real} start The distance from the camera at which the fog will start to take effect
/// @param {real} finish The distance from the camera where the fog will be at its maximum strength
function cluck_set_fog(enabled, color, strength, start, finish) {
    global.__cluck_fog_enabled = enabled;
    global.__cluck_fog_strength = strength;
    global.__cluck_fog_color = color;
    global.__cluck_fog_start = start;
    global.__cluck_fog_end = finish;
}