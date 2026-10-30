extends Camera2D

@export var shake_intensity = 0
@export var shake_decay = 3

func _process(delta):
	if shake_intensity > 0:
		offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		shake_intensity -= shake_decay * delta
	else:
		offset = Vector2.ZERO

func shake(intensity: float):
	shake_intensity = intensity
