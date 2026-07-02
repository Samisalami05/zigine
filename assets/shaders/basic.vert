#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aUv;

out vec3 pos;
out vec2 uv;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

void main() {
	vec4 world = model * vec4(aPos, 1.0f);
    gl_Position = proj * view * world;

	pos = aPos.xyz;
	uv = aUv;
}
