// Feather disable all
/// @desc Define a spot light. Spot lights can be though of as a combination of point and directional lights: they are defined at a point in space and have a maximum radius after which they will have no effect, but they are also oriented in a specific direction and only affect things within a certain angle of their direction. They are often used to represent lights which can be pointed in a specific direction, such as a flashlight or head lamp.
/// @param {real} index The index of the light source (0 through 64 on Windows, 32 on everything else)
/// @param {constant.Color} color The color of light source
/// @param {real} x The x component of the vector representing the light's position in the world
/// @param {real} y The y component of the vector representing the light's position in the world
/// @param {real} z The z component of the vector representing the light's position in the world
/// @param {real} dx The x component of the vector representing the light's direction
/// @param {real} dy The y component of the vector representing the light's direction
/// @param {real} dz The z component of the vector representing the light's direction
/// @param {real} range The maximum range of the light source
/// @param {real} cutoff The angle of the light cone (in degrees)
/// @param {real} [cutoff_inner] Optional; the angle from the center of the cone where light will start to attenuate; defaults to 0
function cluck_set_light_spot(index, color, x, y, z, dx, dy, dz, range, cutoff, cutoff_inner = 0) {
    var position = index * __cluck_light_data_size;
    var dist = -max(0.001, point_distance_3d(0, 0, 0, dx, dy, dz));
    global.__cluck_light_data[position +  0] = x;
    global.__cluck_light_data[position +  1] = y;
    global.__cluck_light_data[position +  2] = z;
    global.__cluck_light_data[position +  3] = CLUCK_LIGHT_SPOT | (floor(dcos(cutoff_inner) * 128) << 4);
    global.__cluck_light_data[position +  4] = dx / dist;
    global.__cluck_light_data[position +  5] = dy / dist;
    global.__cluck_light_data[position +  6] = dz / dist;
    global.__cluck_light_data[position +  7] = range;
    global.__cluck_light_data[position +  8] = colour_get_red(color) / 0xff;
    global.__cluck_light_data[position +  9] = colour_get_green(color) / 0xff;
    global.__cluck_light_data[position + 10] = colour_get_blue(color) / 0xff;
    global.__cluck_light_data[position + 11] = dcos(cutoff);
}