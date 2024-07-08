// Feather disable all
/// @desc  Sets the exponent used in the specular reflections; a lower value means the specular reflections will be more spread out over the surface, while a higher value will cause the reflections to be more focused
/// @param {real} exponent Generally a value around 32 or so is good
function cluck_set_spec_exponent(exponent) {
    global.__cluck_specular_exponent = exponent;
}