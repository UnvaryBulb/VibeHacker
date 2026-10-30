extends CanvasLayer
## Мини-меню паузы: продолжить, выйти в меню или закрыть игру.

@onready var menu: CanvasLayer = $"."

func _on_resume_button_pressed() -> void:
	menu.visible = false

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_button_pressed() -> void:
	get_tree().quit()
