extends Camera2D
## Камера с простым тряским (screen shake).

@export var shake_intensity := 0.0
@export var shake_decay := 3.0

func _process(delta: float) -> void:
	if shake_intensity > 0.0:
		offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity),
		)
		shake_intensity -= shake_decay * delta
	else:
		offset = Vector2.ZERO

func shake(intensity: float) -> void:
	shake_intensity = intensity
