shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// === БАЗОВЫЕ ЭФФЕКТЫ ===
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.25;
uniform float scanline_width : hint_range(1.0, 10.0) = 3.0;
uniform float curvature_amount : hint_range(0.0, 1.0) = 0.12;
uniform float chromatic_aberration : hint_range(0.0, 0.02) = 0.0025;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.5;
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.04;
uniform float flicker_intensity : hint_range(0.0, 1.0) = 0.02;
uniform float brightness : hint_range(0.5, 1.5) = 1.08;
uniform float contrast : hint_range(0.5, 2.0) = 1.08;
uniform float saturation : hint_range(0.0, 2.0) = 1.15;

// === ДОП. ЭФФЕКТЫ ===
uniform float mask_intensity : hint_range(0.0, 1.0) = 0.12;
uniform float mask_size : hint_range(1.0, 8.0) = 3.0;
uniform float rolling_band_intensity : hint_range(0.0, 1.0) = 0.06;
uniform float rolling_band_speed : hint_range(0.0, 0.5) = 0.06;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float glitch_frequency : hint_range(0.0, 1.0) = 0.08;
uniform float interlace_intensity : hint_range(0.0, 1.0) = 0.08;
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.25;
uniform float corner_radius : hint_range(0.0, 0.5) = 0.1;
uniform float glare_intensity : hint_range(0.0, 0.2) = 0.03;

float random(vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Маска трубки со скруглёнными углами
float tube_mask(vec2 uv, float radius) {
	vec2 p = abs(uv - 0.5) * 2.0;
	float power = mix(10.0, 3.0, clamp(radius * 2.0, 0.0, 1.0));
	float d = pow(p.x, power) + pow(p.y, power);
	return 1.0 - smoothstep(0.85, 1.0, d);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 centered = uv - 0.5;
	float dist = length(centered);

	// === Кривизна экрана ===
	if (curvature_amount > 0.0) {
		uv -= centered * (dist * dist) * curvature_amount;
	}

	// ✅ ВМЕСТО return: флаг "в пределах экрана" + clamp для сэмплинга
	float in_bounds = 1.0;
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		in_bounds = 0.0;
	}
	uv = clamp(uv, vec2(0.001), vec2(0.999));

	// === Глитч: случайная полоса смещается ===
	float t_slice = floor(TIME * 4.0);
	float g_rand = random(vec2(t_slice, 3.7));
	if (g_rand < glitch_frequency) {
		float band_y = random(vec2(t_slice, 1.3));
		float band_h = 0.02 + random(vec2(t_slice, 5.1)) * 0.06;
		if (uv.y > band_y && uv.y < band_y + band_h) {
			uv.x += (random(vec2(uv.y * 137.0, t_slice)) - 0.5) * 0.06 * glitch_intensity;
			uv.y += (random(vec2(uv.y * 91.0, t_slice)) - 0.5) * 0.004 * glitch_intensity;
		}
	}
	uv = clamp(uv, vec2(0.001), vec2(0.999));

	// === Хроматическая аберрация (сильнее к краям) ===
	float ca = chromatic_aberration * (0.4 + dist * 2.5);
	float r = texture(screen_texture, uv + centered * ca).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - centered * ca).b;
	vec3 color = vec3(r, g, b);

	// === Фосфорное свечение ===
	if (glow_intensity > 0.0) {
		vec2 off = vec2(0.0035, 0.0035);
		vec3 glow = texture(screen_texture, uv + vec2(off.x, 0.0)).rgb;
		glow += texture(screen_texture, uv - vec2(off.x, 0.0)).rgb;
		glow += texture(screen_texture, uv + vec2(0.0, off.y)).rgb;
		glow += texture(screen_texture, uv - vec2(0.0, off.y)).rgb;
		color += glow * 0.25 * glow_intensity;
	}

	// === Сканирующие линии ===
	float res_y = 1.0 / SCREEN_PIXEL_SIZE.y;
	float scanline = sin(uv.y * res_y * 3.14159 / max(scanline_width, 1.0));
	color *= 1.0 - abs(scanline) * scanline_intensity;

	// === Чересстрочность ===
	if (interlace_intensity > 0.0) {
		float field = mod(floor(TIME * 60.0), 2.0);
		float row = floor(uv.y * res_y);
		color *= 1.0 - mod(row + field, 2.0) * interlace_intensity * 0.5;
	}

	// === RGB-маска люминофора ===
	if (mask_intensity > 0.0) {
		float col = mod(floor(uv.x / SCREEN_PIXEL_SIZE.x / mask_size), 3.0);
		vec3 mask;
		if (col < 1.0)      mask = vec3(1.0, 0.7, 0.7);
		else if (col < 2.0) mask = vec3(0.7, 1.0, 0.7);
		else                mask = vec3(0.7, 0.7, 1.0);
		color *= mix(vec3(1.0), mask, mask_intensity);
	}

	// === Бегущая полоса развёртки ===
	if (rolling_band_intensity > 0.0) {
		float band_pos = mod(TIME * rolling_band_speed, 1.3) - 0.15;
		float band = exp(-pow((uv.y - band_pos) * 10.0, 2.0));
		color += band * rolling_band_intensity;
	}

	// === Виньетка ===
	float vig = 1.0 - dot(centered, centered) * vignette_intensity * 2.0;
	color *= clamp(vig, 0.0, 1.0);

	// === Шум ===
	color += (random(uv * vec2(1234.5, 5678.9) + fract(TIME)) - 0.5) * noise_intensity;

	// === Мерцание ===
	color *= 1.0 + (random(vec2(floor(TIME * 60.0), 0.5)) - 0.5) * flicker_intensity;

	// === Насыщенность / контраст / яркость ===
	float lum = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(vec3(lum), color, saturation);
	color = (color - 0.5) * contrast + 0.5;
	color *= brightness;

	// === Блик стекла ===
	float glare = smoothstep(0.9, 0.1, length(SCREEN_UV - vec2(0.28, 0.22)));
	color += glare * glare_intensity;

	// === Маска трубки + чёрный за пределами экрана ===
	color *= tube_mask(SCREEN_UV, corner_radius);
	color *= in_bounds;

	COLOR = vec4(color, 1.0);
}