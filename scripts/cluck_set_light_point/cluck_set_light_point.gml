// Feather disable all
/// @desc Define a point light. Point lights are defined by a point in space, and a radius which they affect. They are often used to represent light sources which originate from a single point and radiate out in all directions, such as a torch flame or an unshaded lamp.
/// @param {real} index The index of the light source (0 through 64 on Windows, 32 on everything else)
/// @param {constant.Color} color The color of light source
/// @param {real} x The light's x coordinate in the world
/// @param {real} y The light's y coordinate in the world
/// @param {real} z The light's z coordinate in the world
/// @param {real} radius The maximum range of the light source
/// @param {real} [radius_inner] Optional; the distance from the light source where light will start to attenuate; defaults to 0
function cluck_set_light_point(index, color, x, y, z, radius, radius_inner = 0) {
    var position = index * __cluck_light_data_size;
    global.__cluck_light_data[position +  0] = x;
    global.__cluck_light_data[position +  1] = y;
    global.__cluck_light_data[position +  2] = z;
    global.__cluck_light_data[position +  3] = CLUCK_LIGHT_POINT;
    // 4 unused
    // 5 unused
    global.__cluck_light_data[position +  6] = radius_inner;
    global.__cluck_light_data[position +  7] = radius;
    global.__cluck_light_data[position +  8] = colour_get_red(color) / 0xff;
    global.__cluck_light_data[position +  9] = colour_get_green(color) / 0xff;
    global.__cluck_light_data[position + 10] = colour_get_blue(color) / 0xff;
    // 11 unused
}