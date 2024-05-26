function Point(_x, _y) constructor {
	x = _x;
	y = _y;
}

function Point3D(_x, _y, _z) constructor {
	x = _x;
	y = _y;
	z = _z;
}

function Vec2() constructor
{
	#region Initialize Vector
		
		__IS_VEC_3 = false;
		
		#region Setup
		
			/// Set available parameters
			var paramArray = array_create(3,0);
			for ( var i=0; i<argument_count; i++ )
			{
				paramArray[@i] = argument[i];
			}
			if (argument_count == 3) {
				__IS_VEC_3 = true;
			}
			
		#endregion
		#region Position[0] Handling
		
			var arg = argument[0];
			if ( argument_count==1 )
			{
				if ( is_struct(arg) )
				{
					paramArray = [ arg.x, arg.y ];
				}
				else
				{
					paramArray = [ arg, arg ];
				}
			}
			
		#endregion
		#region Set values
		
			x=paramArray[0]; 
			y=paramArray[1];
			z = 0;
			if (__IS_VEC_3) {
				z=paramArray[2];
			}
			
		#endregion
		
	#endregion
	#region Math Functions
		
		#region Arithmetical functions
		
			static multiply=function(val)
			{
				///@func mul(value_or_vec)
				var v = new Vec2(val);
				return new Vec2(x * v.x, y * v.y, z * v.z);
			}
			static add=function(val)
			{
				///@func add(value_or_vec)
				var v = new Vec2(val);
				return new Vec2(x + v.x, y + v.y, z + v.z);
			}
			static subtract=function(val)
			{
				///@func sub(value_or_vec)
				var v = new Vec2(val);
				return new Vec2(x - v.x, y - v.y, z - v.z);
			}
			static divide=function(val)
			{
				///@func divide(value_or_vec)
				if (__IS_VEC_3) {
					return new Vec2(x / val, y / val,  z / val);
				}
				else {
					return new Vec2(x / val, y / val);
				}
			}
			static modulo=function(val)
			{
				///@func modulo(value_or_vec)
				var v = new Vec2(val);
				return new Vec2(x % v.x, y % v.y,  z % v.z);
			}
			
		#endregion
		#region Advanced functions
		
			static length_squared = function()
			{
				///@func length_squared()
				return (x*x)+(y*y)+(z*z);
			}
			static length = function()
			{
				///@func length()
				return sqrt(length_squared());
			}	
			static normalize = function()
			{
				///@func normalize()
				var mag = length();
				if ( mag == 0 ) {
					return 0;
				}
				return self.divide(mag);
			}
			static is_normalized = function()
			{
				///@func is_normalized()
				return ( length_squared() == 1 );
			}
			static inverse = function()
			{
				///@func inverse()
				return new Vec2(1/x, 1/y);
			}		
			static dot = function(val)
			{
				///@func dot(value_or_vec)
				var v = new Vec2(val);
				return dot_product(x,y,v.x,v.y);
			}
			static dot_normalized = function(val)
			{
				///@func dot_normalized(value_or_vec)
				var v = new Vec2(val);
				return dot_product_normalized(x,y,v.x,v.y);
			}			
			static distance_to = function(val)
			{
				///@func distance_to(value_or_vec)
				var v = new Vec2(val);
				var v2 = new Vec2(x,y);
				
				v.subtract(v2);
				return v.length();
			}
			static angle_to = function(val)
			{
				///@func angle_to(value_or_vec)
				var v = new Vec2(val);
				return point_direction(x,y,v.x,v.y);
			}
			static cross = function(vec)
			{
				///@func cross(vec)
				///@desciption create cross product of this vector and vec
				///@return vec2
				assert(typeof(vec) == "struct");
				var c = new Vec2(0, 0, 0);
				c.x = (y * vec.z) - (z * vec.y);
				c.y = (z * vec.x) - (x * vec.z);
				c.z = (x * vec.y) - (y * vec.x);
				return c;
			}
			static lerp_to = function(val,amt)
			{
				///@func lerp_to(value_or_vec, amount)
				var v = new Vec2(val);
				x=lerp(x,v.x,amt);
				y=lerp(y,v.y,amt);
				return self;
			}
			static reflect = function(val)
			{
				///@func reflect(normal);
				var v = new Vec2(val);
				v.normalize();
				
				var d = dot(v);
				v.multiply(2*d);
				v.subtract(new Vec2(x,y));
				return v;
			}	
			static clamp_to = function(v1, v2)
			{
				///@func clamp_to(min, max)
				x = clamp(x, v1, v2);
				y = clamp(y, v1, v2);
				return self;
			}
			
			static vec_abs = function()
			{
				return new Vec2(abs(x),abs(y));
			}
			static vec_floor = function()
			{
				return new Vec2(floor(x),floor(y));
			}
			static vec_ceil = function()
			{
				return new Vec2(ceil(x),ceil(y));	
			}
			static vec_sign = function()
			{
				return new Vec2(sign(x),sign(y));	
			}
			static vec_round = function()
			{
				return new Vec2(round(x),round(y));	
			}
			
		#endregion
	#endregion
	
	toString = function() {
		if (!__IS_VEC_3) {
			return $"({x}, {y})";
		}
		else {
			return $"({x}, {y}, {z})";
		}
	}
	
}