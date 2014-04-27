//uniform sampler2D normalmap;
uniform sampler2D depthmap;
uniform sampler2D fogmap;

uniform float skew_ratio = 1.0; // 45 degrees camera angle
uniform float fogz = 0.3;
uniform float fogheight = 0.2;

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
	// RGBA of the diffuse color.
	vec4 diffuse_color = texture2D(texture, texture_coords);

	// Get the depth.
	float depth = texture2D(depthmap, texture_coords).r;

	float fogpower = getfog(vec3(texture_coords, depth));
	return diffuse_color + vec4(fogpower, fogpower, fogpower, 0);

}