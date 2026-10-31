extends Camera2D

# === ТРЯСКА ===
var shake_intensity = 0
var shake_decay = 5

# === СЛЕЖЕНИЕ ЗА МЫШКОЙ ===
var mouse_follow_strength = 25.0   # максимальное смещение в пикселях
var mouse_follow_speed = 4.0       # скорость догона (lerp)
var mouse_offset = Vector2.ZERO

func _process(delta):
	# === 1. Смещение за мышкой ===
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
		# Едва уловимый наклон — мир "кренится" за курсором
	rotation = mouse_offset.x * 0.0004
	# Позиция мыши относительно центра экрана, в диапазоне -1..1
	var from_center = (mouse_pos - viewport_size / 2.0) / (viewport_size / 2.0)
	from_center = from_center.clampf(-1.0, 1.0)
	
	# Целевое смещение в пикселях
	var target_offset = from_center * mouse_follow_strength
	
	# Плавно догоняем (без рывков)
	mouse_offset = mouse_offset.lerp(target_offset, mouse_follow_speed * delta)
	
	# === 2. Тряска ===
	var shake_offset = Vector2.ZERO
	if shake_intensity > 0:
		shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		shake_intensity -= shake_decay * delta
	
	# === 3. Суммируем оба эффекта в offset ===
	offset = mouse_offset + shake_offset

func shake(intensity: float):
	shake_intensity = intensity
