// Feather disable all
/// @desc Function Use this function to set one of the Luminous Chickens shaders.
///
/// Rather than setting the shader(s) directly using GameMaker's shader_set function, it is generally easier to use this function to both set the shader and automatically apply all of the relevant shader uniforms in a single function call. Setting the shaders directly will do nothing and will result in everything drawing black, since the uniforms will not have been set.
/// @param {asset.GMShader} shader The Luminous Chicken shader you wish to enable
function cluck_apply(shader) {
    var fog_color = global.__cluck_fog_color;
    var ambient_color = global.__cluck_light_ambient;
    
    static light_active_data_primary = array_create(CLUCK_MAX_LIGHTS * 4);
    static light_active_data_secondary = array_create(CLUCK_MAX_LIGHTS * 4);
    static light_active_data_tertiary = array_create(CLUCK_MAX_LIGHTS * 4);
    
    array_map_ext(light_active_data_primary, function() { return CLUCK_LIGHT_NONE; });
    
    var light_count = 0;
    for (var i = 0, n = array_length(global.__cluck_light_data); i < n; i += __cluck_light_data_size) {
        if (global.__cluck_light_data[i + 3] != CLUCK_LIGHT_NONE) {
            array_copy(light_active_data_primary,    light_count * 4, global.__cluck_light_data, i + 0, 4);
            array_copy(light_active_data_secondary,  light_count * 4, global.__cluck_light_data, i + 4, 4);
            array_copy(light_active_data_tertiary, light_count++ * 4, global.__cluck_light_data, i + 8, 4);
        }
    }
    
    shader_set(shader);
    shader_set_uniform_f(shader_get_uniform(shader, "alphaRef"), min(gpu_get_alphatestenable() * gpu_get_alphatestref() / 255, 0.999));
    
    shader_set_uniform_i(shader_get_uniform(shader, "lightCount"), light_count);
    shader_set_uniform_f_array(shader_get_uniform(shader, "lightDataPrimary"), light_active_data_primary);
    shader_set_uniform_f_array(shader_get_uniform(shader, "lightDataSecondary"), light_active_data_secondary);
    shader_set_uniform_f_array(shader_get_uniform(shader, "lightDataTertiary"), light_active_data_tertiary);
    
    shader_set_uniform_f(shader_get_uniform(shader, "lightAmbientColor"), colour_get_red(ambient_color) / 0xff, colour_get_green(ambient_color) / 0xff, colour_get_blue(ambient_color) / 0xff);
    
    shader_set_uniform_f(shader_get_uniform(shader, "fogStrength"), global.__cluck_fog_enabled ? global.__cluck_fog_strength : 0);
    shader_set_uniform_f(shader_get_uniform(shader, "fogStart"), global.__cluck_fog_start);
    shader_set_uniform_f(shader_get_uniform(shader, "fogEnd"), global.__cluck_fog_end);
    shader_set_uniform_f(shader_get_uniform(shader, "fogColor"), colour_get_red(fog_color) / 0xff, colour_get_green(fog_color) / 0xff, colour_get_blue(fog_color) / 0xff);
    
    shader_set_uniform_f(shader_get_uniform(shader, "fogUseGradient"), global.__cluck_fog_use_gradient && sprite_exists(global.__cluck_fog_gradient));
    var sampler;
    if (sprite_exists(global.__cluck_fog_gradient)) {
        sampler = shader_get_sampler_index(shader, "fogGradient");
        texture_set_stage(sampler, sprite_get_texture(global.__cluck_fog_gradient, global.__cluck_fog_gradient_index));
        gpu_set_texfilter_ext(sampler, global.__cluck_fog_gradient_texfilter);
    }
    
    shader_set_uniform_f(shader_get_uniform(shader, "cameraPosition"), global.__cluck_camera_x, global.__cluck_camera_y, global.__cluck_camera_z);
    shader_set_uniform_f(shader_get_uniform(shader, "specularStrength"), global.__cluck_specular_strength);
    shader_set_uniform_f(shader_get_uniform(shader, "specularExponent"), global.__cluck_specular_exponent);
    
    if (CLUCK_HAS_TOON_INSTALLED && shader_get_uniform(shader, "toonSimple") != -1) {
        shader_set_uniform_f(shader_get_uniform(shader, "toonSimple"), global.__cluck_toon_simple_mode);
        shader_set_uniform_f(shader_get_uniform(shader, "toonTime"), global.__cluck_toon_ramp_index);
        sampler = shader_get_sampler_index(shader, "toonTex");
        texture_set_stage(sampler, sprite_get_texture(global.__cluck_toon_ramp, 0));
        gpu_set_texfilter_ext(sampler, global.__cluck_toon_texfilter);
    }
}