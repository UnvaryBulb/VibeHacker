extends Node

# Состояние игры
var current_camera: int = 1          # Какая камера сейчас взламываем (1, 2, 3)
var current_screenshot_code: String = ""  # Код на скриншоте (вводит игрок)
var collected_hex_code: String = ""  # Код, который игрок получил за уровень
var is_in_terminal: bool = true      # Где сейчас игрок

# Словарь с данными по каждой камере
var cameras_data = {
	1: {
		"screenshot": "res://Assets/Sprites/cam1.png",
		"code_on_screen": "1337",
		"hex_reward": "A1",
		"platformer_scene": "res://Scenes/Level1.tscn"
	},
	2: {
		"screenshot": "res://Assets/Sprites/cam2.png",
		"code_on_screen": "4242",
		"hex_reward": "B7",
		"platformer_scene": "res://Scenes/Level2.tscn"
	},
	3: {
		"screenshot": "res://Assets/Sprites/cam3.png",  # Тыква!
		"code_on_screen": "PUMP",
		"hex_reward": "FF",
		"platformer_scene": "res://Scenes/Level3.tscn"
	}
}
