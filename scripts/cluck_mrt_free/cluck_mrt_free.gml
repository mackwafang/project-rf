// Feather disable all
/// @desc because some gamers get touchy if they see your game leaking memory.
/// @param {struct} cluck_mrt The Chickens MRT struct you want to get rid of
function cluck_mrt_free(cluck_mrt) {
    if (surface_exists(cluck_mrt.depth)) surface_free(cluck_mrt.depth);
    if (surface_exists(cluck_mrt.normal)) surface_free(cluck_mrt.normal);
};