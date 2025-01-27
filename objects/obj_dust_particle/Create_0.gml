color = c_white;
extend_rate = 0.05;
fade_rate = 0.01;
z = 0;

matrix = matrix_build(0,0,0,0,0,0,0,0,0);
identity_matrix = matrix_build_identity();

image_index = irandom(image_number);
image_angle = irandom(360);
image_xscale = 0.5;
image_yscale = 0.5;
depth = 50;
alarm[0] = 1;