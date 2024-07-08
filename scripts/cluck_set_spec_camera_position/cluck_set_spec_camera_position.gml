// Feather disable all
/// @desc  Defines the camera position used for specular reflections
/// @param {real} x
/// @param {real} y
/// @param {real} z cmon you know what these arguments are for
function cluck_set_spec_camera_position(x, y, z) {
    global.__cluck_camera_x = x;
    global.__cluck_camera_y = y;
    global.__cluck_camera_z = z;
}