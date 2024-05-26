/// @description post creation "script

switch(vehicle_type) {
	case VEHICLE_TYPE.CAR:
		vehicle_detail_index = spr_car_detail;
		image_xscale = 8;
		image_yscale = 30;
		break;
	case VEHICLE_TYPE.BIKE:
		vehicle_detail_index = spr_bike_3d_detail_2;
		image_xscale = 8;
		image_yscale = 6;
		break;
}
z = on_road_index.z;
image_blend = vehicle_color;