function draw_bar_color_border(xx, yy, value, max_value, width, height, border, color1, color2, color3, color4, bkg_color, vertical=false) {
	/// @function			draw_bar_color_border(xx, yy, value, max_value, width, height, border, color1, color2, color3, color4, bkg_color, vertical);
	/// @param				xx
	/// @param				yy
	/// @param				value
	/// @param				max_value
	/// @param				width
	/// @param				height
	/// @param				border
	/// @param				color1
	/// @param				color2
	/// @param				color3
	/// @param				color4
	/// @param				bkg_color
	/// @param				vertical
	draw_rectangle_color(
		xx - border, 
		yy + border, 
		xx + width + border, 
		yy - height - border, 
		bkg_color, 
		bkg_color, 
		bkg_color, 
		bkg_color, 
		false
	);
	draw_bar_color_border_no_bkg(
		xx, 
		yy, 
		value, 
		max_value, 
		width, 
		height, 
		border, 
		color1, 
		color2, 
		color3, 
		color4, 
		vertical
	);
}

function draw_bar_color_border_no_bkg(xx, yy, value, max_value, width, height, border, color1, color2, color3, color4, vertical=false) {
	/// @function			draw_bar_color_border_no_bkg(xx, yy, value, max_value, width, height, border, color1, color2, color3, color4, vertical);
	/// @param				xx
	/// @param				yy
	/// @param				value
	/// @param				max_value
	/// @param				width
	/// @param				height
	/// @param				border
	/// @param				color1
	/// @param				color2
	/// @param				color3
	/// @param				color4
	/// @param				vertical
	if (vertical) {
		draw_rectangle_color(
			xx, 
			yy, 
			xx + width, 
			yy - ((value/max_value)*(height)), 
			color1, 
			color2, 
			color3, 
			color4, 
			false
		);
	}
	else {
		draw_rectangle_color(
			xx, 
			yy, 
			xx + ((value/max_value)*width), 
			yy - height, 
			color1, 
			color2, 
			color3, 
			color4, 
			false
			);
	}
}