// Feather disable all
/// @desc  Use this function to enable or disable using a gradient sprite for fog. The gradient sprite only needs to be 1 pixel tall and may have a color gradient (for the fog color from near to far) and an alpha gradient (usually 0 on the left and 1 on the right).
/// @param {bool} use_gradient True if you want to use a fog gradient sprite, false otherwise
/// @param {asset.GMSprite} gradient_sprite The gradient sprite you want to use
/// @param {real} gradient_index The image index of the gradient sprite you want to use
/// @param {bool} gradient_texcilter True if you want to use bilinear texture filtering on the fog gradient to smooth out the transition, false otherwise
function cluck_set_fog_gradient(use_gradient, gradient_sprite = undefined, gradient_index = 0, gradient_texfilter = false) {
    global.__cluck_fog_use_gradient = use_gradient;
    global.__cluck_fog_gradient = gradient_sprite;
    global.__cluck_fog_gradient_index = gradient_index;
    global.__cluck_fog_gradient_texfilter = gradient_texfilter;
}