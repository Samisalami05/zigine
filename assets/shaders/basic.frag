#version 330 core

in vec3 pos;
in vec2 uv;

out vec4 FragColor;

uniform sampler2D tex;

void main() {
	FragColor = texture(tex, uv);
	//FragColor = vec4(uv.x, uv.y, 0.0f, 1.0f);
}
