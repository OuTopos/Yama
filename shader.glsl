extern Image canvas_diffuse;
extern Image canvas_normal;
extern Image canvas_depth;
extern Image canvas_final;

extern Image depthmap;
extern Image normalmap;

extern float scale;
extern mat3 rotation;


uniform vec4 ambient_color;
uniform vec3 light_position[5];
uniform vec4 light_color[5];

vec3 falloff = vec3(0.0001, 0.0001, 0.0001);
float skew_ratio = 1.0;

void effects(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	if(screen_coords.x > 10 && screen_coords.x < 1000 && screen_coords.y > 10 && screen_coords.y < 720)
		{
	vec2 canvas_coords = vec2(screen_coords.x/love_ScreenSize.x, screen_coords.y/love_ScreenSize.y);
	vec4 canvas_diffuse_color = Texel(canvas_diffuse, canvas_coords);
	vec4 canvas_depth_color = Texel(canvas_depth, canvas_coords);
	vec4 canvas_normal_color = Texel(canvas_normal, canvas_coords);
	
	vec4 diffuse = Texel(texture, texture_coords);
	float depth = Texel(depthmap, texture_coords).r;
	float ao = Texel(depthmap, texture_coords).g;
	depth = depth * scale;

	vec3 normal = Texel(normalmap, texture_coords).rgb;
	normal = normal * 2 - 1;
	normal = normal * rotation;
	normal = normal / 2 + 0.5;

	if(canvas_depth_color.r >= depth)
	{
		love_Canvases[0] = diffuse;
		love_Canvases[1] = mix(canvas_normal_color, vec4(normal, 1.0), diffuse.a);
		love_Canvases[2] = vec4(depth, ao, 0.0, diffuse.a);

		// NOW CALCULATE THE FINAL RESULT
		// RGBA of the diffuse color.
		//vec4 diffuse_color = texture2D(texture, texture_coords);
		vec4 diffuse_color = diffuse;

		// RGB of the normal map.
		//vec3 normal_color = texture2D(normalmap, texture_coords).rgb;
		//normal_color.g = 1 - normal_color.g;
		vec3 normal_color = normal;

		// Normalize the normal vector.
		//vec3 N = normalize(normal_color * 2.0 - 1.0);
		vec3 N = normalize(mix(vec3(-1), vec3(1), normal_color)); 

		// Get the depth.
		//float depth = texture2D(depthmap, texture_coords).r * 255;
		depth = depth * 255;

		// Sum of the lights.
		vec3 sum = vec3(0.0);

		for(int i = 0; i < 5; i++)
		{
			// The delta position of light.
			vec3 light_direction = light_position[i] - vec3(screen_coords - vec2(0.0, depth * skew_ratio), depth);

			// Determine the distance (used for attenuation) BEFORE we normalize the light direction.
			float D = length(light_direction);

			// Normalize the light vectors.
			vec3 L = normalize(light_direction);

			// Pre-multiply light color with intensity.
			// Then perform "N dot L" to determine the diffuse term.
			vec3 diffuse = (light_color[i].rgb * light_color[i].a) * max(dot(N, L), 0.0);

			// Pre-multiply ambient color with intensity.
			vec3 ambient = ambient_color.rgb * ambient_color.a;

			// Calculate attenuation.
			float attenuation = 1.0 / (D/20);

			// Calculate and return the final color.
			vec3 intensity = ambient + diffuse * attenuation;
			vec3 final_color = diffuse_color.rgb * intensity;

			sum += final_color;
		}


		if(screen_coords.x < 10)
		{
			love_Canvases[3] = vec4(1, 1, 1, 1);
		}
		else
		{
			love_Canvases[3] =  vec4(sum, diffuse_color.a);
		}
		
	}
	else
	{
		love_Canvases[0] = canvas_diffuse_color;
		love_Canvases[1] = canvas_normal_color;
		love_Canvases[2] = canvas_depth_color;
		love_Canvases[3] = texture2D(canvas_final, canvas_coords);
	}
	}
	else
	{
		love_Canvases[0] = vec4(0, 0, 0, 1);
		love_Canvases[1] = vec4(0, 0, 0, 1);
		love_Canvases[2] = vec4(0, 0, 0, 1);
		love_Canvases[3] = vec4(0, 0, 0, 1);
	}
}