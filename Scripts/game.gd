extends Node2D
## Корневой узел сцены терминала: запускает игру через GameManager.

func _ready() -> void:
	GameManager.start_game()
