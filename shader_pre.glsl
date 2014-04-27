uniform sampler2D canvas_depth;
uniform sampler2D depthmap;
uniform sampler2D normalmap;
uniform float z = 0.0;
uniform float scale = 1.0;
//extern mat3 rotation;

void effects(vec4 color, sampler2D texture, vec2 texture_coords, vec2 screen_coords)
{
	vec2 canvas_coords = screen_coords / love_ScreenSize.xy;
	canvas_coords.y = 1 - canvas_coords.y;
	vec4 canvas_depth_color = Texel(canvas_depth, canvas_coords);
	
	float depth = Texel(depthmap, texture_coords).r * scale + color.r + z;

	if(canvas_depth_color.r < depth)
	{
		vec4 diffuse = Texel(texture, texture_coords);
		vec4 normal = Texel(normalmap, texture_coords);
		//normal = normal * 2 - 1;
		//normal = normal * rotation;
		//normal = normal / 2 + 0.5;

		love_Canvases[0] = diffuse;
		love_Canvases[1] = vec4(normal.rgb, diffuse.a);
		love_Canvases[2] = vec4(depth, 0.0, 0.0, diffuse.a);
	}
	else
	{
		discard;
	}
}