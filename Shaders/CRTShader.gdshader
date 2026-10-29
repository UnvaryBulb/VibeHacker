shader_type canvas_item;

uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float scanline_width : hint_range(1.0, 10.0) = 3.0;
uniform float curvature_amount : hint_range(0.0, 1.0) = 0.1;
uniform float chromatic_aberration : hint_range(0.0, 0.1) = 0.002;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.5;
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.05;
uniform float flicker_intensity : hint_range(0.0, 1.0) = 0.03;
uniform float brightness : hint_range(0.5, 1.5) = 1.1;
uniform float contrast : hint_range(0.5, 2.0) = 1.1;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    
    // === Кривизна экрана ===
    if (curvature_amount > 0.0) {
        vec2 center = uv - 0.5;
        float dist = length(center);
        uv -= center * (dist * dist) * curvature_amount;
    }
    
    // === Получаем цвет из текстуры ===
    vec4 tex_color = texture(TEXTURE, uv);
    
    // Хроматическая аберрация
    float r = texture(TEXTURE, uv + vec2(chromatic_aberration, 0.0)).r;
    float g = tex_color.g;
    float b = texture(TEXTURE, uv - vec2(chromatic_aberration, 0.0)).b;
    vec3 color = vec3(r, g, b);
    
    // Если текстура прозрачная/белая - используем COLOR ноды
    if (tex_color.a < 0.1 && length(color) > 2.9) {
        color = COLOR.rgb;
    }
    
    // === Сканирующие линии ===
    float scanline = sin(uv.y * 100.0 * scanline_width * 3.14159);
    scanline = 1.0 - abs(scanline) * scanline_intensity;
    color *= scanline;
    
    // === Виньетка ===
    vec2 dist_from_center = uv - 0.5;
    float vignette = 1.0 - (length(dist_from_center) * vignette_intensity);
    vignette = clamp(vignette, 0.0, 1.0);
    color *= vignette;
    
    // === Шум ===
    float noise = random(uv * 100.0) * noise_intensity;
    color += noise;
    
    // === Мерцание ===
    float flicker = 1.0 + (random(vec2(TIME * 10.0, 0.0)) - 0.5) * flicker_intensity;
    color *= flicker;
    
    // === Яркость и контраст ===
    color = (color - 0.5) * contrast + 0.5;
    color *= brightness;
    
    COLOR = vec4(color, 1.0);
}