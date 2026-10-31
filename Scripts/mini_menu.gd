extends CanvasLayer
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.apply_underwater_effect()

func _on_resume_button_pressed():
	GameManager.remove_underwater_effect()
	GameManager.resume_game()

func _on_exit_button_pressed():
	GameManager.resume_game()
	GameManager.game_started = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_quit_button_pressed():
	GameManager.resume_game()
	get_tree().quit()
	
