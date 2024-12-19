// Feather disable all
/// @desc Call this to set the shader and relevant render inputs.
///
/// There's currently just one post-processing outline shader, shd_cluck_post_outlines, used in Cartoon Chickens. I might add more later if I get bored.
///
/// Does not work on HTML5, due to the lack of support for multiple render targets.
/// @param {asset.GMShader} shader The shader you want to use for post-processing
/// @param {struct} cluck_mrt The Chickens MRT struct you want to begin writing to
function cluck_apply_post(shader, cluck_mrt) {
    if (!CLUCK_IS_WEB) {
        shader_set(shader);
        if (CLUCK_HAS_TOON_INSTALLED && shader_get_uniform(shader, "outlineColor") != -1) {
            shader_set_uniform_f(shader_get_uniform(shader, "outlineColor"), 0, 0, 0, 1);
            shader_set_uniform_f(shader_get_uniform(shader, "outlineFadeDistance"), global.__cluck_toon_outline_fade_near, global.__cluck_toon_outline_fade_far);
            shader_set_uniform_f(shader_get_uniform(shader, "outlineStrength"), global.__cluck_toon_outline_strength);
            shader_set_uniform_f(shader_get_uniform(shader, "outlineSensitivity"), global.__cluck_toon_outline_sensitivity);
            shader_set_uniform_f(shader_get_uniform(shader, "screenSize"), surface_get_width(cluck_mrt.depth), surface_get_height(cluck_mrt.normal));
            texture_set_stage(shader_get_sampler_index(shader, "texDepth"), surface_get_texture(cluck_mrt.depth));
            texture_set_stage(shader_get_sampler_index(shader, "texNormal"), surface_get_texture(cluck_mrt.normal));
        }
    }
}