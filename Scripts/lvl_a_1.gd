extends Node2D

@onready var key = $key  # Ссылка на ключик в уровне

func _ready():
	if key:
		key.key_collected.connect(_on_key_collected)

const HexPopupScene: PackedScene = preload("res://Scenes/HexPopup.tscn")

func _on_key_collected(hex_code: String) -> void:
	# Показываем красивую расшифровку
	var popup := HexPopupScene.instantiate()
	add_child(popup)
	popup.show_code(hex_code)
	
	# Ждём пока игрок посмотрит и попап исчезнет
	await popup.finished
	popup.queue_free()
	
	# Только ТЕПЕРЬ возвращаемся в терминал
	GameManager.on_key_collected(hex_code)
