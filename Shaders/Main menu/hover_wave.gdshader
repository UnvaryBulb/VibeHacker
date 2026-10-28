// ЭТО АНИМАЦИЯ КНОПОК В ГЛАВ. МЕНЮ
shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float width : hint_range(0.05, 1.0) = 0.3;
uniform float slant : hint_range(0.0, 1.0) = 0.4;
uniform float steps = 5.0;
uniform vec3 wave_color : source_color = vec3(1.0);

void fragment() {
	float pos = UV.x + UV.y * slant;
	float front = mix(-width, 1.0 + slant + width, progress);
	float band = 1.0 - smoothstep(0.0, width, abs(pos - front));
	band = round(band * steps) / steps;
	COLOR.rgb = mix(COLOR.rgb, wave_color, band);
}