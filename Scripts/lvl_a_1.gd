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
	
	# ✅ ПРИГЛУШАЕМ МУЗЫКУ СРАЗУ
	var music_bus := AudioServer.get_bus_index("Music")
	var original_vol := AudioServer.get_bus_volume_db(music_bus)
	AudioServer.set_bus_volume_db(music_bus, original_vol - 40.0)
	
	var popup := HexPopupScene.instantiate()
	add_child(popup)
	popup.show_code(hex_code)
	
	await popup.finished
	popup.queue_free()
	
	# === Уходим в терминал ===
	AudioServer.set_bus_volume_db(music_bus, original_vol)  # ✅ восстанавливаем
	GameManager.on_key_collected(hex_code)
