// Feather disable all
/// @desc Bind the Chickens render targets so they can be used. Call this before you do any drawing.
///
/// You should do this before calling draw_clear(...) on your main surface, assuming you don't want the contents to be carried over from whatever you drew on them last.
/// @param {struct} cluck_mrt The Chickens MRT struct you want to begin writing to
/// @param {id.Surface} [main_surface] The surface you're using as your main render target (optional, defaults to the application surface)
function cluck_mrt_set(cluck_mrt, main_surface = application_surface) {
    static validate = function(surface, w, h, format = surface_rgba8unorm) {
        if (surface_get_format(surface) != format) {
            surface_free(surface);
        } else if (surface_get_width(surface) != w) {
            surface_free(surface);
        } else if (surface_get_height(surface) != h) {
            surface_free(surface);
        }
    
        if (surface_exists(surface))
            return surface;
    
        return surface_create(w, h, format);
    };
    
    if (!CLUCK_IS_WEB) {
        var w = surface_get_width(main_surface);
        var h = surface_get_height(main_surface);
        cluck_mrt.normal = validate(cluck_mrt.normal, w, h);
        cluck_mrt.depth = validate(cluck_mrt.depth, w, h, surface_r32float);
        surface_set_target_ext(1, cluck_mrt.depth);
        surface_set_target_ext(2, cluck_mrt.normal);
    }
}