#version 330 core

layout (location = 0) in vec3 aPos;

out vec3 pos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

void main() {
	vec4 world = model * vec4(aPos, 1.0f);
    gl_Position = proj * view * world;

	pos = aPos.xyz;
}
