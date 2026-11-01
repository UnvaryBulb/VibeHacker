extends Node2D

@onready var key = $key  # Ссылка на ключик в уровне

func _ready():
	if key:
		key.key_collected.connect(_on_key_collected)

const HexPopupScene: PackedScene = preload("res://Scenes/HexPopup.tscn")

func _on_key_collected(hex_code: String) -> void:
	# === СТОП-КАДР: мир замирает, живёт только попап ===
	GameManager.cutscene = true
	get_tree().paused = true
	
	var popup := HexPopupScene.instantiate()
	add_child(popup)
	popup.show_code(hex_code)
	
	await popup.finished
	popup.queue_free()
	
	# === Уходим в терминал, всё ещё на паузе ===
	GameManager.on_key_collected(hex_code)
