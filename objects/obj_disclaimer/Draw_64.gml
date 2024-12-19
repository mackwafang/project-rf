draw_set_font(fnt_game);

var port_width = view_wport[0];
var port_height = view_hport[0];

draw_set_font(fnt_disclaimer);

draw_set_valign(fa_middle);
draw_set_halign(fa_center);
draw_set_alpha(alpha);
draw_text_ext(port_width / 2, port_height * 0.6, disclaimer_string, 32, port_width * 0.8);
draw_set_alpha(1);