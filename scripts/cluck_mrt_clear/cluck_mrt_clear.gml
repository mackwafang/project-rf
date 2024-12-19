// Feather disable all
/// @desc Clear the Chickens MRT surfaces. Analogous to calling one of the draw_clear functions. Do this before you start drawing things with a shader that uses MRT.
/// @param {struct} cluck_mrt The Chickens MRT struct you want to clear
/// @param {constant.color} [color] The color you want to clear the surfaces to (defaults to black)
/// @param {constant.color} [alpha] The alpha you want to clear the surfaces to (defaults to 1)
function cluck_mrt_clear(cluck_mrt, color = c_black, alpha = 1) {
    if (surface_exists(cluck_mrt.normal)) {
        surface_set_target(cluck_mrt.normal);
        draw_clear_alpha(color, alpha);
        surface_reset_target();
    }
    if (surface_exists(cluck_mrt.depth)) {
        surface_set_target(cluck_mrt.depth);
        draw_clear_alpha(color, alpha);
        surface_reset_target();
    }
}