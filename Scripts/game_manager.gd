extends Node
## Глобальное состояние игры (автозагрузка GameManager).
## Хранит данные камер, текущую камеру, добытые HEX-коды и историю терминала,
## а также управляет переключением сцен.

signal level_completed(hex_code: String)
signal camera_changed(camera_number: int)

## Поля записи камеры в cameras_data.
enum CameraField { SCREENSHOT, CODE_ON_SCREEN, HEX_REWARD, PLATFORMER_SCENE }

const TERMINAL_SCENE_PATH := "res://Scenes/game.tscn"
const TOTAL_CAMERAS := 3

# === ДАННЫЕ КАМЕР ===
var cameras_data: Dictionary = {
	1: {
		CameraField.SCREENSHOT: "res://Assets/Sprites/ancap.png",
		CameraField.CODE_ON_SCREEN: "1337",
		CameraField.HEX_REWARD: "A1",
		CameraField.PLATFORMER_SCENE: "res://Scenes/lvlA1.tscn",
	},
	2: {
		CameraField.SCREENSHOT: "res://Assets/Sprites/cam2.png",
		CameraField.CODE_ON_SCREEN: "4242",
		CameraField.HEX_REWARD: "B7",
		CameraField.PLATFORMER_SCENE: "res://Scenes/LvlA2.tscn",
	},
	3: {
		CameraField.SCREENSHOT: "res://Assets/Sprites/cam3.png",
		CameraField.CODE_ON_SCREEN: "PUMP",
		CameraField.HEX_REWARD: "FF",
		CameraField.PLATFORMER_SCENE: "res://Scenes/LvlA3.tscn",
	},
}

# === СОСТОЯНИЕ ИГРЫ ===
var current_camera: int = 1
var collected_hex_code: String = ""
var game_started: bool = false
var phase: String = "screenshot"
var terminal_history: String = ""

var terminal_scene: PackedScene = preload("res://Scenes/game.tscn")

func start_game() -> void:
	# Запуск только один раз за игру.
	if game_started:
		return
	game_started = true
	current_camera = 1
	collected_hex_code = ""
	phase = "screenshot"
	terminal_history = ""
	load_terminal()

func remember(text: String) -> void:
	terminal_history += text

func load_terminal() -> void:
	# Если мы уже в терминале — не перезагружаем сами себя.
	var current := get_tree().current_scene
	if current and current.scene_file_path == TERMINAL_SCENE_PATH:
		return
	get_tree().change_scene_to_packed(terminal_scene)

func load_level(camera_num: int) -> void:
	phase = "hex"
	var scene_path := _get_field(camera_num, CameraField.PLATFORMER_SCENE)
	# Уровни 2 и 3 ещё не созданы — не роняем игру, остаёмся в терминале.
	if not ResourceLoader.exists(scene_path):
		push_warning("GameManager: сцена уровня '%s' не найдена (камера %d)." % [scene_path, camera_num])
		return
	get_tree().change_scene_to_file(scene_path)

func next_camera() -> void:
	current_camera += 1
	phase = "screenshot"
	if current_camera > TOTAL_CAMERAS:
		print("ПОБЕДА! Тыква спасена!")
	else:
		camera_changed.emit(current_camera)
		load_terminal()

func on_key_collected(hex_code: String) -> void:
	collected_hex_code = hex_code
	level_completed.emit(hex_code)
	await get_tree().create_timer(1.5).timeout
	load_terminal()

func get_screenshot_path(camera_num: int) -> String:
	return _get_field(camera_num, CameraField.SCREENSHOT)

func get_code_on_screen(camera_num: int) -> String:
	return _get_field(camera_num, CameraField.CODE_ON_SCREEN)

func get_hex_reward(camera_num: int) -> String:
	return _get_field(camera_num, CameraField.HEX_REWARD)

func _get_field(camera_num: int, field: CameraField) -> String:
	var data: Dictionary = cameras_data[camera_num]
	assert(data.has(field), "Камера %d не имеет поля %s" % [camera_num, field])
	return data[field]
