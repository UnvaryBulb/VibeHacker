extends Node

# === ДАННЫЕ КАМЕР ===
var cameras_data = {
	1: {
		"screenshot": "res://Assets/Sprites/ancap.png",
		"code_on_screen": "1337",
		"hex_reward": "A1",
		"platformer_scene": "res://Scenes/lvlA1.tscn"
	},
	2: {
		"screenshot": "res://Assets/Sprites/cam2.png",
		"code_on_screen": "4242",
		"hex_reward": "B7",
		"platformer_scene": "res://Scenes/LvlA2.tscn"
	},
	3: {
		"screenshot": "res://Assets/Sprites/cam3.png",
		"code_on_screen": "PUMP",
		"hex_reward": "FF",
		"platformer_scene": "res://Scenes/LvlA3.tscn"
	}
}

# === СОСТОЯНИЕ ИГРЫ ===
var current_camera: int = 1
var collected_hex_code: String = ""
var is_in_terminal: bool = true
var game_started: bool = false
var phase: String = "screenshot"
var terminal_history: String = ""

# ✅ Защита от двойной смены сцены
var _changing_scene: bool = false

var terminal_scene: PackedScene = preload("res://Scenes/game.tscn")

signal level_completed(hex_code: String)
signal camera_changed(camera_number: int)

func start_game():
	# ✅ Только один раз за игру
	if game_started:
		return
	game_started = true
	current_camera = 1
	phase = "screenshot"
	terminal_history = ""
	load_terminal()

func remember(text: String):
	terminal_history += text

func load_terminal():
	# ✅ Уже в терминале — не перезагружаем сами себя
	var current = get_tree().current_scene
	if current and current.scene_file_path == "res://Scenes/game.tscn":
		return
	_change_scene_packed(terminal_scene)

func load_level(camera_num: int):
	phase = "hex"
	var data = cameras_data[camera_num]
	_change_scene_file(data["platformer_scene"])

func _change_scene_packed(scene: PackedScene):
	# ✅ Если смена уже идёт — игнорируем повторный вызов
	if _changing_scene:
		return
	_changing_scene = true
	get_tree().change_scene_to_packed(scene)
	await get_tree().process_frame
	_changing_scene = false

func _change_scene_file(path: String):
	if _changing_scene:
		return
	_changing_scene = true
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	_changing_scene = false

func get_camera_data(camera_num: int) -> Dictionary:
	return cameras_data[camera_num]

func next_camera():
	current_camera += 1
	phase = "screenshot"
	if current_camera > 3:
		print("ПОБЕДА! Тыква спасена!")
	else:
		camera_changed.emit(current_camera)
		load_terminal()

func on_key_collected(hex_code: String):
	collected_hex_code = hex_code
	level_completed.emit(hex_code)
	await get_tree().create_timer(1.5).timeout
	load_terminal()
