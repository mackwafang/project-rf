// Feather disable all
/// @desc  Sets the strength of the specular reflections
/// @param {real} strength Should be a value between 0 and 1
function cluck_set_spec_strength(strength) {
    global.__cluck_specular_strength = strength;
}