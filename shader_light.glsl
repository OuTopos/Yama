uniform sampler2D normalmap;
uniform sampler2D depthmap;
uniform vec2 offset = vec2(0.0, 0.0);

uniform mat4 screen_to_world;


//uniform vec4 ambient_color;
uniform vec3 light_position[5];
uniform vec4 light_color[5];
uniform float skew_ratio = 1.0; // 45 degrees camera angle

vec3 falloff = vec3(0.0001, 0.0001, 0.0001);


uniform sampler2D ambientmap;
uniform float hour = 0.5;

// FOG
uniform sampler2D fogmap;
uniform float fogz = 0.2;
uniform float fogheight = 0.3;

float getfog(vec3 position)
{
	float fog_thickness = min(fogz + fogheight - position.z, fogheight);
	if(fog_thickness > 0.0)
	{
		float fog_color = texture2D(fogmap, position.xy).g * (fog_thickness / fogheight);

		return fog_color;
	}
	else
	{
		// Above the fog
		return vec4(0, 0, 0, 0);
	}
}

vec4 effect(vec4 color, sampler2D texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 world_coords = vec4(screen_coords, 0, 1) * screen_to_world;

	// RGBA of the diffuse color.
	vec4 diffuse_color = texture2D(texture, texture_coords);

	// RGB of the normal map.
	vec3 normal_color = texture2D(normalmap, texture_coords).rgb;
	normal_color.g = 1 - normal_color.g;

	vec4 ambient_color = texture2D(ambientmap, vec2(hour, 0.0));

	// Normalize the normal vector.
	//vec3 N = normalize(normal_color * 2.0 - 1.0);
	vec3 N = normalize(mix(vec3(-1), vec3(1), normal_color)); 

	// Get the depth.
	float depth = texture2D(depthmap, texture_coords).r;

	float fogv = getfog(vec3(texture_coords, depth));

	depth *= 256;

	// Sum of the lights.
	vec3 sum = vec3(0.0);

	for(int i = 0; i < 5; i++)
	{
		// The delta position of light.
		vec3 light_direction = light_position[i] - vec3(world_coords.xy - vec2(0.0, depth * skew_ratio), depth);

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

	//return vec4(sum, diffuse_color.a);
	return vec4(mix(sum.rgb, vec3(0.14, 0.13, 0.25), fogv), diffuse_color.a);
}