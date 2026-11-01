extends Control

@onready var logs: RichTextLabel = $VBoxContainer/logs
@onready var input_field: LineEdit = $VBoxContainer/HBoxContainer/enter
@onready var type_sound: AudioStreamPlayer2D = $TypeSound  # ✅ НОВАЯ ССЫЛКА
var state: String = "chat"
var current_task_code: String = ""
var is_typing: bool = false

@onready var top_bar = $top  # если top — Label

func _ready():
	await get_tree().process_frame
	if not is_inside_tree():
		return
	# ✅ Звук печатания игрока
	if input_field:
		input_field.text_changed.connect(_on_input_text_changed)
	# ✅ Подключаемся к смене камер (без перезагрузки сцены)
	if GameManager and not GameManager.camera_changed.is_connected(_on_camera_changed):
		GameManager.camera_changed.connect(_on_camera_changed)
	
	# ✅ Эффект "включения монитора" при загрузке сцены терминала
	crt_power_on()
	
	if GameManager.collected_hex_code != "":
		top_bar.text = "CAM %d | ДОБЫТО: %s" % [GameManager.current_camera, GameManager.collected_hex_code]
	
	if GameManager.terminal_history != "":
		logs.clear()
		logs.append_text(GameManager.terminal_history)
		
	
	if GameManager.phase == "hex":
		await start_hex_mission()
	else:
		await start_mission(GameManager.current_camera)

# === НОВАЯ СЕССИЯ БЕЗ ПЕРЕЗАГРУЗКИ ===
func _on_camera_changed(camera_num: int):
	# Обновляем статус-бар
	top_bar.text = "CAM %d | ДОБЫТО: %s" % [GameManager.current_camera, GameManager.collected_hex_code]
	# Лёгкий глитч-всплеск маскирует переход — выглядит как помехи в эфире
	crt_spike()
	# И сразу новая миссия в этой же сцене
	await start_mission(camera_num)

# === ЭФФЕКТ "ВКЛЮЧЕНИЯ МОНИТОРА" ===
func crt_power_on():
	var crt = get_tree().get_first_node_in_group("crt")
	if crt == null or crt.material == null:
		return
	var mat = crt.material
	mat.set_shader_parameter("brightness", 0.0)
	var t := create_tween()
	t.tween_method(func(v: float): mat.set_shader_parameter("brightness", v), 0.0, 1.08, 0.5)

# ✅ Пишет и на экран, и в историю
func push(text: String):
	logs.append_text(text)
	GameManager.remember(text)

# === ФАЗА 1: ищем код на скриншоте ===
func start_mission(camera_num: int):
	var data = GameManager.get_camera_data(camera_num)
	
	# Разделитель, если история уже есть
	if GameManager.terminal_history != "":
		push("\n[color=cyan]════════ НОВАЯ СЕССИЯ ════════[/color]\n")
	
	await hacker_type("Подключаюсь к камере #" + str(camera_num) + "...")
	if not is_inside_tree(): return
	await hacker_type("Скидываю скриншот. Найди код.")
	if not is_inside_tree(): return
	
	# Скриншот тоже попадает в историю!
	push('[img=400x225]' + data["screenshot"] + '[/img]\n')
	
	await hacker_type("Введи код в терминал.")
	if not is_inside_tree(): return
	
	state = "waiting_code"
	current_task_code = data["code_on_screen"]
	input_field.editable = true
	input_field.grab_focus()

# === ФАЗА 2: ждём hex-код из уровня ===
func start_hex_mission():
	var data = GameManager.get_camera_data(GameManager.current_camera)
	
	if GameManager.terminal_history != "":
		push("\n[color=cyan]════════ НОВАЯ СЕССИЯ ════════[/color]\n")
	
	await hacker_type("Ты вернулся! Взлом прошёл успешно?")
	if not is_inside_tree(): return
	await hacker_type("Система уровня сгенерировала код доступа.")
	if not is_inside_tree(): return
	await hacker_type("Введи HASH-код, который ты добыл.")
	if not is_inside_tree(): return
	
	state = "waiting_hex"
	current_task_code = data["hex_reward"]
	input_field.editable = true
	input_field.grab_focus()

func hacker_type(text: String, speed: float = 0.03):
	is_typing = true
	input_field.editable = false
	
	push("[color=yellow]> ХАКЕР:[/color] ")
	var char_count := 0
	for character in text:
		if not is_inside_tree():
			return
		push(character)
		# ✅ ЗВУК ПЕЧАТАНИЯ (каждый символ)
		if type_sound and character != " ":
			char_count += 1
			# Проигрываем каждый символ, но с рандомным питчем для естественности
			type_sound.pitch_scale = randf_range(0.85, 1.15)
			type_sound.play()
		var tree = get_tree()
		if tree == null:
			return
		await get_tree().create_timer(speed, false).timeout
	
	if not is_inside_tree():
		return
	push("\n")
	is_typing = false

func _on_enter_text_submitted(new_text: String):
	if is_typing:
		input_field.text = ""
		return
	
	var input = new_text.to_upper().strip_edges()
	input_field.text = ""
	push("[color=green]> ТЫ:[/color] " + input + "\n")
	
	if state == "waiting_code":
		if input == current_task_code:
			await hacker_type("Код принят! Запускаю уровень...")
			if not is_inside_tree(): return
			state = "platformer"
			await get_tree().create_timer(1.0).timeout
			if not is_inside_tree(): return
			GameManager.load_level(GameManager.current_camera)
		else:
		
			wrong_code_feedback()  # ✅ вот здесь
			await hacker_type("Неверный код. Посмотри внимательнее на скриншот.")
			if not is_inside_tree(): return
			input_field.editable = true
			input_field.grab_focus()
			
			if not is_inside_tree(): return
			input_field.editable = true
			input_field.grab_focus()
	
	elif state == "waiting_hex":
		if input == current_task_code:
			await on_hex_accepted()
		else:
			wrong_code_feedback()  # ✅ и здесь
			await hacker_type("Неверный HASH-код. Он был показан после подбора ключа.")
		
			if not is_inside_tree(): return
			input_field.editable = true
			input_field.grab_focus()

func on_hex_accepted():
	var cam = GameManager.current_camera
	if cam == 3:
		await hacker_type("Код принят! Открываю прямой поток камеры #3...")
		if not is_inside_tree(): return
		await hacker_type("Погоди. Это что... ТЫКВА?! Похищенная?!")
		if not is_inside_tree(): return
		
		# ✅ ПОКАЗЫВАЕМ ТЫКВУ (если есть картинка)
		var data = GameManager.get_camera_data(3)
		if data.has("finale_image"):
			push('[img=500x300]' + data["finale_image"] + '[/img]\n')
		
		await hacker_type("Отправляю кадр в полицию. Доказательство принято!")
		if not is_inside_tree(): return
		await hacker_type("ТЫКВА СПАСЕНА! Отличная работа, нейросеть. 🎃")
		if not is_inside_tree(): return
		
		# ✅ ФИНАЛЬНЫЙ ЭКРАН
		state = "finale"
		input_field.editable = false
		await show_finale_screen()
	else:
		await hacker_type("Код " + current_task_code + " принят! Получаю доступ к следующей камере...")
		if not is_inside_tree(): return
		state = "transition"
		await get_tree().create_timer(1.0).timeout
		if not is_inside_tree(): return
		GameManager.next_camera()

# === ФИНАЛЬНЫЙ ЭКРАН ===
func show_finale_screen():
	# Ждём секунду, чтобы игрок осознал
	await get_tree().create_timer(1.5, false).timeout
	if not is_inside_tree(): return
	
	# Показываем финальное сообщение
	push("\n[color=cyan]════════ КОНЕЦ ИГРЫ ════════[/color]\n")
	push("[color=yellow]Спасибо за игру! Ты спас тыкву! 🎃[/color]\n")
	push("[color=green]Введите любой символ в терминал для возврата в главное меню[/color]\n")

	
	# Ждём нажатия Enter
	input_field.editable = true
	input_field.grab_focus()
	input_field.text_changed.connect(_on_finale_input)

func _on_finale_input(new_text: String):
	if new_text.length() > 0:
		input_field.text_changed.disconnect(_on_finale_input)
		input_field.editable = false
		# Затемнение и переход
		await fade_to_menu()

func fade_to_menu():
	# Затемнение
	var fade := ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade)
	
	var t := create_tween()
	t.tween_property(fade, "color:a", 1.0, 1.0)
	await t.finished
	
	# Переход в главное меню
	GameManager.game_started = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
# === НАКАЗАНИЕ ЗА НЕВЕРНЫЙ КОД ===
func wrong_code_feedback():
	GameManager.music_glitch()
	shake_terminal()
	crt_spike()
	red_flash()
func crt_spike():
	var crt = get_tree().get_first_node_in_group("crt")
	if crt == null or crt.material == null:
		return
	var mat = crt.material
	mat.set_shader_parameter("glitch_intensity", 1.0)
	mat.set_shader_parameter("noise_intensity", 0.25)
	await get_tree().create_timer(0.4, false).timeout
	mat.set_shader_parameter("glitch_intensity", 0.5)
	mat.set_shader_parameter("noise_intensity", 0.05)
func shake_terminal():
	var original := position
	for i in range(6):
		position = original + Vector2(randf_range(-6.0, 6.0), randf_range(-4.0, 4.0))
		await get_tree().create_timer(0.04, false).timeout
	position = original

func red_flash():
	var flash := ColorRect.new()
	flash.color = Color(0.938, 0.246, 0.325, 0.25)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	await get_tree().create_timer(0.15, false).timeout
	flash.queue_free()
func _on_input_text_changed(new_text: String):
	# Проигрываем звук клавиши, если текст не пустой (иначе это backspace)
	if type_sound and new_text.length() > 0:
		type_sound.pitch_scale = randf_range(0.85, 1.15)
		type_sound.play()
