event_inherited();
render_scale = {
	x: 0.1,
	y: 0.1,
	z: 0.1
}
display_sprite_index = spr_ad_128_64;
display_image_index = irandom(sprite_get_number(display_sprite_index));
billboard_index = irandom(1);

image_xscale = 8;
image_yscale = 8;
height = 128;
render_pillar = true;

function init_vertex_buffer() {
	var ad_tex = sprite_get_texture(display_sprite_index, display_image_index)
	var ad_uv = sprite_get_uvs(display_sprite_index, display_image_index);
	
	var pillar_tex = [
		sprite_get_texture(spr_billboard_pillar, 0),
		sprite_get_texture(spr_billboard_pillar, 1),
	];
	var pillar_base_uv = sprite_get_uvs(spr_billboard_pillar, 0);
	var pillar_column_uv = sprite_get_uvs(spr_billboard_pillar, 1);
	var billboard_tex = sprite_get_texture(spr_billboard, billboard_index);
	var billboard_uv = sprite_get_uvs(spr_billboard, billboard_index);
	
	var ad_tw = texture_get_texel_width(ad_tex);
	var ad_th = texture_get_texel_height(ad_tex);
	var ad_w = abs(ad_uv[2] - ad_uv[0]) / ad_tw * 2;
	var ad_h = (abs(ad_uv[3] - ad_uv[1]) / ad_th * 2);
	
	var pillar_base_tw = texture_get_texel_width(pillar_tex[0]);
	var pillar_base_th = texture_get_texel_height(pillar_tex[0]);
	var pillar_base_w = abs(pillar_base_uv[2] - pillar_base_uv[0]) / pillar_base_tw;
	var pillar_base_h = abs(pillar_base_uv[3] - pillar_base_uv[1]) / pillar_base_th;
	
	var billboard_tw = texture_get_texel_width(billboard_tex);
	var billboard_th = texture_get_texel_height(billboard_tex);
	var billboard_w = abs(billboard_uv[2] - billboard_uv[0]) / billboard_tw * 2;
	var billboard_h = abs(billboard_uv[3] - billboard_uv[1]) / billboard_th * 2;
	
	//var tw = texture_get_texel_width(tex);
	//var th = texture_get_texel_height(tex);
	//var w = abs(uv[2] - uv[0]) / tw;//sprite_get_w(spr_tree);
	//var h = abs(uv[3] - uv[1]) / th;//sprite_get_h(spr_tree);
	
	var x0 = x + lengthdir_x(pillar_base_w, direction+90);
	var y0 = y + lengthdir_y(pillar_base_w, direction+90);
	var x1 = x + lengthdir_x(pillar_base_w, direction-90);
	var y1 = y + lengthdir_y(pillar_base_w, direction-90);
	
	var billboard_x0 = x + lengthdir_x(billboard_w, direction+90);
	var billboard_y0 = y + lengthdir_y(billboard_w, direction+90);
	var billboard_x1 = x + lengthdir_x(billboard_w, direction-90);
	var billboard_y1 = y + lengthdir_y(billboard_w, direction-90);
	
	var tex_spacing = 0;
	var dist = point_distance(x, y, x - tex_spacing + lengthdir_x(ad_w, direction+90), y + lengthdir_y(ad_w, direction+90));
	var dir = point_direction(x, y, x - tex_spacing + lengthdir_x(ad_w, direction+90), y + lengthdir_y(ad_w, direction+90));
	var dir2 = point_direction(x, y, x - tex_spacing + lengthdir_x(ad_w, direction-90), y + lengthdir_y(ad_w, direction-90));
	var ad_x0 = x + lengthdir_x(dist, dir);
	var ad_y0 = y + lengthdir_y(dist, dir);
	var ad_x1 = x + lengthdir_x(dist, dir2);
	var ad_y1 = y + lengthdir_y(dist, dir2);
	
	var ad_height_adjust = 26;
	var billboard_height_adjust = (billboard_index == 1 ? 18 : 0);
	
	image_angle = direction;
	if (render_pillar) {
		// pillar base
		vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z+32	, pillar_base_uv[0], pillar_base_uv[1]);
		vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z		, pillar_base_uv[0], pillar_base_uv[3]);
		vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z+32	, pillar_base_uv[2], pillar_base_uv[1]);
	
		vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z+32	, pillar_base_uv[2], pillar_base_uv[1]);
		vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z		, pillar_base_uv[0], pillar_base_uv[3]);
		vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z		, pillar_base_uv[2], pillar_base_uv[3]);

		// generating pillars
		vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z+height+billboard_height_adjust	, pillar_column_uv[0], pillar_column_uv[1]);
		vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z+32								, pillar_column_uv[0], pillar_column_uv[3]);
		vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z+height+billboard_height_adjust	, pillar_column_uv[2], pillar_column_uv[1]);
	
		vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z+height+billboard_height_adjust	, pillar_column_uv[2], pillar_column_uv[1]);
		vertex_position_3d_uv(global.prop_vertex_buffer, x0, y0, z+32								, pillar_column_uv[0], pillar_column_uv[3]);
		vertex_position_3d_uv(global.prop_vertex_buffer, x1, y1, z+32								, pillar_column_uv[2], pillar_column_uv[3]);
	}
	
	// draw board
	vertex_position_3d_uv(global.prop_vertex_buffer, billboard_x0, billboard_y0, z+height+billboard_h	, billboard_uv[0], billboard_uv[1]);
	vertex_position_3d_uv(global.prop_vertex_buffer, billboard_x0, billboard_y0, z+height				, billboard_uv[0], billboard_uv[3]);
	vertex_position_3d_uv(global.prop_vertex_buffer, billboard_x1, billboard_y1, z+height+billboard_h	, billboard_uv[2], billboard_uv[1]);
	
	vertex_position_3d_uv(global.prop_vertex_buffer, billboard_x1, billboard_y1, z+height+billboard_h	, billboard_uv[2], billboard_uv[1]);
	vertex_position_3d_uv(global.prop_vertex_buffer, billboard_x0, billboard_y0, z+height				, billboard_uv[0], billboard_uv[3]);
	vertex_position_3d_uv(global.prop_vertex_buffer, billboard_x1, billboard_y1, z+height				, billboard_uv[2], billboard_uv[3]);
	
	// draw ad
	vertex_position_3d_uv(global.prop_vertex_buffer, ad_x0, ad_y0, z+height+ad_height_adjust+ad_h		, ad_uv[0], ad_uv[1]);
	vertex_position_3d_uv(global.prop_vertex_buffer, ad_x0, ad_y0, z+height+ad_height_adjust			, ad_uv[0], ad_uv[3]);
	vertex_position_3d_uv(global.prop_vertex_buffer, ad_x1, ad_y1, z+height+ad_height_adjust+ad_h		, ad_uv[2], ad_uv[1]);
	
	vertex_position_3d_uv(global.prop_vertex_buffer, ad_x1, ad_y1, z+height+ad_height_adjust+ad_h		, ad_uv[2], ad_uv[1]);
	vertex_position_3d_uv(global.prop_vertex_buffer, ad_x0, ad_y0, z+height+ad_height_adjust			, ad_uv[0], ad_uv[3]);
	vertex_position_3d_uv(global.prop_vertex_buffer, ad_x1, ad_y1, z+height+ad_height_adjust			, ad_uv[2], ad_uv[3]);
}