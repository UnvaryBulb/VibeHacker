extends Node

# === ДАННЫЕ КАМЕР ===
var cameras_data = {
	1: {
		"screenshot": "res://Assets/Sprites/cam1.png",
		"code_on_screen": "1337",
		"hex_reward": "D9",
		"platformer_scene": "res://Scenes/lvlA1.tscn",
		"rating_thresholds": {
			"S": {"time": 10.0, "deaths": 0},    # < 1 мин, 0 смертей
			"A": {"time": 15.0, "deaths": 2},   # < 2 мин, < 2 смертей
			"B": {"time": 30.0, "deaths": 5},   # < 3 мин, < 5 смертей
			"C": {"time": 9999.0, "deaths": 999} # остальное
		}
	},
	2: {
		"screenshot": "res://Assets/Sprites/cam2.png",
		"code_on_screen": "8015",
		"hex_reward": "B7",
		"platformer_scene": "res://Scenes/lvlA2.tscn",
		"rating_thresholds": {
			"S": {"time": 18.0, "deaths": 0},    # < 1.5 мин, 0 смертей
			"A": {"time": 30.0, "deaths": 3},   # < 3 мин, < 3 смертей
			"B": {"time": 90.0, "deaths": 7},   # < 5 мин, < 7 смертей
			"C": {"time": 9999.0, "deaths": 999}
		}
	},
	3: {
		"screenshot": "res://Assets/Sprites/cam3.png",
		"code_on_screen": "6924",
		"hex_reward": "FF",
		"platformer_scene": "res://Scenes/lvlA3.tscn",
		"rating_thresholds": {
			"S": {"time": 30.0, "deaths": 0},   # < 2 мин, 0 смертей
			"A": {"time": 40.0, "deaths": 4},   # < 4 мин, < 4 смертей
			"B": {"time": 90.0, "deaths": 10},  # < 7 мин, < 10 смертей
			"C": {"time": 9999.0, "deaths": 999}
		}
	}
}
# === НАСТРОЙКИ ГРОМКОСТИ (пользовательские) ===
var user_music_volume: float = 0.0  # в dB, по умолчанию 0
var user_sfx_volume: float = 0.0
var user_master_volume: float = 0.0
# === СОСТОЯНИЕ ИГРЫ ===
var current_camera: int = 1
var collected_hex_code: String = ""
var is_in_terminal: bool = true
var game_started: bool = false
var phase: String = "screenshot"
var terminal_history: String = ""

# === СТАТИСТИКА ===
var total_deaths: int = 0      # все смерти за игру
var level_deaths: int = 0      # смерти только на текущем уровне
var attempt_time: float = 0.0  # время текущей попытки
var is_level_active: bool = false

# === ЛУЧШИЕ РЕЗУЛЬТАТЫ ПО УРОВНЯМ ===
var level_best_times: Dictionary = {}  # {1: 45.2, 2: 120.5, 3: 180.0}
var level_best_deaths: Dictionary = {} # {1: 0, 2: 1, 3: 2}
var level_best_ratings: Dictionary = {} # {1: "S", 2: "A", 3: "B"}

func add_death():
	total_deaths += 1
	level_deaths += 1
	attempt_time = 0.0

func reset_level_stats():
	level_deaths = 0
	attempt_time = 0.0
	is_level_active = true

func start_attempt_timer():
	attempt_time = 0.0
	is_level_active = true

func stop_attempt_timer():
	is_level_active = false

func format_time(seconds: float) -> String:
	var mins := int(seconds / 60)
	var secs := int(seconds) % 60
	var ms := int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [mins, secs, ms]
# === ОЦЕНКА ДЛЯ КОНКРЕТНОГО УРОВНЯ ===
func calculate_rating(camera_num: int, time: float, deaths: int) -> String:
	var data = cameras_data[camera_num]
	if not data.has("rating_thresholds"):
		return "C"
	
	var thresholds = data["rating_thresholds"]
	
	# Проверяем от лучшего к худшему
	if time <= thresholds["S"]["time"] and deaths <= thresholds["S"]["deaths"]:
		return "S"
	elif time <= thresholds["A"]["time"] and deaths <= thresholds["A"]["deaths"]:
		return "A"
	elif time <= thresholds["B"]["time"] and deaths <= thresholds["B"]["deaths"]:
		return "B"
	else:
		return "C"


func _process(delta):
	if is_level_active:
		attempt_time += delta
# ✅ Защита от двойной смены сцены
var _changing_scene: bool = false

var terminal_scene: PackedScene = preload("res://Scenes/game.tscn")

signal level_completed(hex_code: String)
signal camera_changed(camera_number: int)
func set_music_volume(db: float):
	user_music_volume = db
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)

func set_sfx_volume(db: float):
	user_sfx_volume = db
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)

func set_master_volume(db: float):
	user_master_volume = db
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func restore_user_volumes():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), user_music_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), user_sfx_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), user_master_volume)
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
	# Страховка: терминал никогда не стартует замороженным
	get_tree().paused = false
	cutscene = false
	var current = get_tree().current_scene
	if current and current.scene_file_path == "res://Scenes/game.tscn":
		return
	_change_scene_packed(terminal_scene)

func load_level(camera_num: int):
	get_tree().paused = false
	cutscene = false
	phase = "hex"
	reset_level_stats()  # ✅ сбрасываем смерти и таймер для нового уровня
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
		# ✅ Никакой перезагрузки: живой терминал поймает сигнал сам
		camera_changed.emit(current_camera)

func on_key_collected(hex_code: String):
	collected_hex_code = hex_code
	level_completed.emit(hex_code)
	stop_attempt_timer()  # ✅ останавливаем таймер успешной попытки
	
	# Музыка уже восстановлена в скрипте уровня
	get_tree().paused = false
	cutscene = false
	load_terminal()
	# === ПАУЗА (ESC = переключатель) ===
var pause_menu_scene: PackedScene = preload("res://Scenes/mini_menu.tscn")
var pause_menu: Node = null
# ✅ game_started НЕ объявляем — она уже есть выше в файле
# === ЛОВИМ ESC ===
func _input(event: InputEvent):
	# ESC не открывает паузу поверх катсцены (стоп-кадр с попапом)
	if event.is_action_pressed("ui_cancel") and game_started and not cutscene:
		toggle_pause()
		get_viewport().set_input_as_handled()
func _init() -> void:
	# GameManager ловит ESC даже когда игра на паузе
	process_mode = Node.PROCESS_MODE_ALWAYS
var cutscene: bool = false  # ✅ идёт катсцена — ESC не работаем
	# GameManager ловит ESC даже когда игра на паузе

func toggle_pause():
	if pause_menu != null:
		resume_game()
		GameManager.remove_underwater_effect()
	else:
		open_pause_menu()

func open_pause_menu():
	if pause_menu != null:
		return
	pause_menu = pause_menu_scene.instantiate()
	get_tree().root.add_child(pause_menu)
	get_tree().paused = true

func resume_game():
	get_tree().paused = false
	GameManager.remove_underwater_effect()  # ✅ Снимаем эффект при любом выходе из паузы
	if pause_menu != null:
		pause_menu.queue_free()
		pause_menu = null
# === АУДИО-ЭФФЕКТЫ ===

# === ГЛИТЧ ПРИ НЕВЕРНОМ КОДЕ (v2: звук не пропадает) ===
func music_glitch(duration: float = 0.7):
	var bus := AudioServer.get_bus_index("Music")
	if bus < 0:
		return
	
	# Ищем заранее положенные эффекты на шине Music
	var dist: AudioEffectDistortion = null
	var pitch: AudioEffectPitchShift = null
	var dist_idx := -1
	var pitch_idx := -1
	for i in range(AudioServer.get_bus_effect_count(bus)):
		var e := AudioServer.get_bus_effect(bus, i)
		if e is AudioEffectDistortion:
			dist = e
			dist_idx = i
		elif e is AudioEffectPitchShift:
			pitch = e
			pitch_idx = i
	
	var original_vol := AudioServer.get_bus_volume_db(bus)
	
	# 1. Включаем биткраш — музыка начинает хрустеть
	if dist_idx >= 0:
		AudioServer.set_bus_effect_enabled(bus, dist_idx, true)
	
	# 2. Питч-качели → "пластинка останавливается рукой"
	if pitch != null:
		if pitch_idx >= 0:
			AudioServer.set_bus_effect_enabled(bus, pitch_idx, true)
		var t := create_tween()
		t.tween_property(pitch, "pitch_scale", 0.7, 0.07)
		t.tween_property(pitch, "pitch_scale", 1.25, 0.07)
		t.tween_property(pitch, "pitch_scale", 0.5, 0.1)
		t.tween_property(pitch, "pitch_scale", 0.35, 0.25)
	
	# 3. Громкость ВОЛНИТ (-6 dB), но НЕ исчезает
	for i in range(8):
		AudioServer.set_bus_volume_db(bus, original_vol - 6.0 if i % 2 == 0 else original_vol)
		await get_tree().create_timer(0.045, false).timeout
	
	# 4. Держим грязь до конца длительности
	await get_tree().create_timer(maxf(duration - 0.36, 0.1), false).timeout
	
	# 5. Плавно возвращаем питч и выключаем эффекты
	if pitch != null:
		var t2 := create_tween()
		t2.tween_property(pitch, "pitch_scale", 1.0, 0.12)
		await t2.finished
		if pitch_idx >= 0:
			AudioServer.set_bus_effect_enabled(bus, pitch_idx, false)
	if dist_idx >= 0:
		AudioServer.set_bus_effect_enabled(bus, dist_idx, false)
	AudioServer.set_bus_volume_db(bus, original_vol)
# === ЭФФЕКТ "ПОД ВОДОЙ" НА ПАУЗЕ ===
var _underwater_idx: int = -1  # ✅ ТЕПЕРЬ ПЕРЕМЕННАЯ ОБЪЯВЛЕНА

func apply_underwater_effect() -> void:
	if _underwater_idx >= 0:
		return  # уже применён, не дублируем
	var master_bus := AudioServer.get_bus_index("Master")
	var lpf := AudioEffectLowPassFilter.new()
	lpf.cutoff_hz = 500.0
	lpf.resource_name = "UnderwaterLPF"
	AudioServer.add_bus_effect(master_bus, lpf)
	_underwater_idx = AudioServer.get_bus_effect_count(master_bus) - 1

func remove_underwater_effect() -> void:
	if _underwater_idx < 0:
		return  # нечего убирать
	AudioServer.remove_bus_effect(AudioServer.get_bus_index("Master"), _underwater_idx)
	_underwater_idx = -1

# Приглушаем звуки в момент подбора ключа (bullet-time)
func muffle_sounds():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), -6.0)
	await get_tree().create_timer(1.5, false).timeout
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), 0.0)
