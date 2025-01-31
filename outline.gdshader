// Fake stencil outline by Sithoid
// Viewport logic by Leafshade Interactive https://www.youtube.com/watch?v=yh1Kdr37RmI
// Outline logic by Mark Raynsford https://io7m.com/documents/outline-glsl/

// Put this on a ColorRect that covers the entire screen
// As a StencilMask, pass a texture from a Viewport that only receives a specific layer

shader_type canvas_item;

uniform float lineWeight : hint_range(0.5, 10.0) = 3.0; // How thick the outline is
uniform vec4 outlineColor : source_color = vec4(3.0, 0.8, 0.0, 0.8); // Can be > 1
uniform sampler2D stencilMask : source_color;

void fragment() {
	float dx = (SCREEN_PIXEL_SIZE.x) * lineWeight;
	float dy = (SCREEN_PIXEL_SIZE.y) * lineWeight;
	
	vec2 uvCenter   = vec2(SCREEN_UV.x - dx * 0.5, SCREEN_UV.y + dy * 0.5); // Shift by line size makes line expansion uniform
	vec2 uvRight    = vec2(uvCenter.x + dx, uvCenter.y);
	vec2 uvTop      = vec2(uvCenter.x,      uvCenter.y - dx);
	vec2 uvTopRight = vec2(uvCenter.x + dx, uvCenter.y - dx);
	
	float mCenter   = texture(stencilMask, uvCenter).a;
	float mTop      = texture(stencilMask, uvTop).a;
	float mRight    = texture(stencilMask, uvRight).a;
	float mTopRight = texture(stencilMask, uvTopRight).a;
	
	float dT  = abs(mCenter - mTop);
	float dR  = abs(mCenter - mRight);
	float dTR = abs(mCenter - mTopRight);
	
	float delta = 0.0;
	delta = max(delta, dT);
	delta = max(delta, dR);
	delta = max(delta, dTR);
	
	vec4 outline = vec4(outlineColor.r, outlineColor.g, outlineColor.b, sign(delta) * outlineColor.a);
	COLOR = outline;
}
