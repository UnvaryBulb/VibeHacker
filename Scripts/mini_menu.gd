extends CanvasLayer

@onready var menu = $"."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resume_button_pressed() -> void:
	menu.visible = false


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _on_button_pressed() -> void:
	get_tree().quit()
