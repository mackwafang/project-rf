// Feather disable all
/// @desc Use this function to set the ambient light color.
/// 
/// The ambient light color is the color of regions where no light is applied. Most of the time this will be either black (regions outside of direct light will be completely black) or a shade of dark gray (regions outside of direct light will be very dark). Setting this to white will cause all lights to be ignored. Setting this to some other value may have some interesting atmospheric effects; feel free to experiment.
/// @param {constant.Color} color The color of unlit regions
function cluck_set_light_ambient(color) {
    global.__cluck_light_ambient = color;
}