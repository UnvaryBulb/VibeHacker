extends Area2D

func _ready():
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# Убиваем только игрока, ящик неуязвим
	if body.is_in_group("player") and body.has_method("die"):
		body.die()
