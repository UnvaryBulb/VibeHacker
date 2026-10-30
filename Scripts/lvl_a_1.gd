extends Node2D
## Уровень A1: связывает сбор ключа с возвратом в терминал
## (через красивую расшифровку HEX-кода).

const HexPopupScene := preload("res://Scenes/HexPopup.tscn")

@onready var key: Area2D = $key  # Ссылка на ключик в уровне

func _ready() -> void:
	if key:
		key.key_collected.connect(_on_key_collected)

func _on_key_collected(hex_code: String) -> void:
	# Показываем красивую расшифровку.
	var popup := HexPopupScene.instantiate() as CanvasLayer
	add_child(popup)
	popup.show_code(hex_code)

	# Ждём, пока игрок посмотрит и попап исчезнет.
	await popup.finished
	popup.queue_free()

	# Только ТЕПЕРЬ возвращаемся в терминал.
	GameManager.on_key_collected(hex_code)
