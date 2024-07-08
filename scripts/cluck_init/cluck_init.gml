// Feather disable all
global.__cluck_light_ambient = c_white;
global.__cluck_light_data = array_create(CLUCK_MAX_LIGHTS * __cluck_light_data_size);

global.__cluck_fog_enabled = false;
global.__cluck_fog_strength = 1;
global.__cluck_fog_color = c_black;
global.__cluck_fog_start = 256;
global.__cluck_fog_end = 1024;
global.__cluck_fog_use_gradient = false;
global.__cluck_fog_gradient = spr_cluck_fog_gradient;
global.__cluck_fog_gradient_index = 0;
global.__cluck_fog_gradient_texfilter = false;

global.__cluck_camera_x = 0;
global.__cluck_camera_y = 0;
global.__cluck_camera_z = 0;
global.__cluck_specular_strength = 1;
global.__cluck_specular_exponent = 32;

#macro CLUCK_MAX_LIGHTS ((os_type == os_windows) ? 64 : 32)
#macro CLUCK_LIGHT_NONE 0
#macro CLUCK_LIGHT_DIRECTIONAL 1
#macro CLUCK_LIGHT_POINT 2
#macro CLUCK_LIGHT_SPOT 3
#macro __cluck_light_data_size 12

#macro CLUCK_IS_WINDOWS ((os_type == os_windows || os_type == os_gdk || os_type == os_xboxseriesxs) && !CLUCK_IS_WEB)
#macro CLUCK_IS_WEB (os_browser != browser_not_a_browser)
#macro CLUCK_HAS_TOON_INSTALLED variable_global_exists("__cluck_toon_ramp")