extends Control
## Терминал хакера: принимает запросы, печатает ответы «хакера» посимвольно
## и проверяет вводимые коды (код со скриншота камеры / добытый HEX).

enum State { CHAT, WAITING_CODE, WAITING_HEX, PLATFORMER, TRANSITION, FINALE }

const TYPING_SPEED := 0.03        # секунд на символ в «машинке» хакера
const SCROLL_DELAY := 1.0         # пауза перед сменой сцены
const SCREENSHOT_SIZE := "400x225"
const SESSION_SEPARATOR := "\n[color=cyan]════════ НОВАЯ СЕССИЯ ════════[/color]\n"
const TOP_BAR_FORMAT := "CAM %d | ДОБЫТО: %s"

@onready var logs: RichTextLabel = $VBoxContainer/logs
@onready var input_field: LineEdit = $VBoxContainer/HBoxContainer/enter
@onready var top_bar: Label = $top

var state: State = State.CHAT
var is_typing: bool = false
var current_task_code: String = ""

func _ready() -> void:
	# Ждём один кадр — сцена могла быть выгружена при смене уровня.
	await get_tree().process_frame
	if not is_inside_tree():
		return

	# Показываем добытый код в статус-баре.
	if GameManager.collected_hex_code != "":
		top_bar.text = TOP_BAR_FORMAT % [GameManager.current_camera, GameManager.collected_hex_code]

	# Восстанавливаем историю консоли.
	if GameManager.terminal_history != "":
		logs.clear()
		logs.append_text(GameManager.terminal_history)

	# Терминал смотрит на фазу и решает, какое задание запустить.
	if GameManager.phase == "hex":
		await _start_hex_mission()
	else:
		await _start_screenshot_mission(GameManager.current_camera)

## Пишет и на экран, и в историю терминала.
func push(text: String) -> void:
	logs.append_text(text)
	GameManager.remember(text)

# === ФАЗА 1: ищем код на скриншоте камеры ===
func _start_screenshot_mission(camera_num: int) -> void:
	_push_session_separator()
	await hacker_type("Подключаюсь к камере #%d..." % camera_num)
	if not is_inside_tree(): return
	await hacker_type("Скидываю скриншот. Найди код.")
	if not is_inside_tree(): return

	# Скриншот тоже попадает в историю.
	push("[img=%s]%s[/img]\n" % [SCREENSHOT_SIZE, GameManager.get_screenshot_path(camera_num)])

	await hacker_type("Введи код в терминал.")
	if not is_inside_tree(): return

	state = State.WAITING_CODE
	current_task_code = GameManager.get_code_on_screen(camera_num)
	_open_input()

# === ФАЗА 2: ждём HEX-код, добытый на уровне ===
func _start_hex_mission() -> void:
	_push_session_separator()
	await hacker_type("Ты вернулся! Взлом прошёл успешно?")
	if not is_inside_tree(): return
	await hacker_type("Система уровня сгенерировала код доступа.")
	if not is_inside_tree(): return
	await hacker_type("Введи HEX-код, который ты добыл.")
	if not is_inside_tree(): return

	state = State.WAITING_HEX
	current_task_code = GameManager.get_hex_reward(GameManager.current_camera)
	_open_input()

## Печатает сообщение от хакера посимвольно.
func hacker_type(text: String, speed: float = TYPING_SPEED) -> void:
	is_typing = true
	input_field.editable = false

	push("[color=yellow]> ХАКЕР:[/color] ")
	for character in text:
		if not is_inside_tree():
			return
		push(character)
		var tree := get_tree()
		if tree == null:
			return
		await tree.create_timer(speed).timeout

	if not is_inside_tree():
		return
	push("\n")
	is_typing = false

func _on_enter_text_submitted(new_text: String) -> void:
	if is_typing:
		input_field.text = ""
		return

	var input := new_text.to_upper().strip_edges()
	input_field.text = ""
	push("[color=green]> ТЫ:[/color] %s\n" % input)

	match state:
		State.WAITING_CODE:
			await _check_answer(input, func():
				await hacker_type("Код принят! Запускаю уровень...")
				if not is_inside_tree(): return
				state = State.PLATFORMER
				await get_tree().create_timer(SCROLL_DELAY).timeout
				if not is_inside_tree(): return
				GameManager.load_level(GameManager.current_camera))
		State.WAITING_HEX:
			await _check_answer(input, _on_hex_accepted)

## Общая проверка ответа: верный — выполняем action, неверный — подсказка хакера.
func _check_answer(input: String, action: Callable) -> void:
	if input == current_task_code:
		await action.call()
	else:
		var hint := "Неверный код. Посмотри внимательнее на скриншот." \
			if state == State.WAITING_CODE \
			else "Неверный HEX-код. Он был показан после подбора ключа."
		await hacker_type(hint)
		if not is_inside_tree(): return
		_open_input()

func _on_hex_accepted() -> void:
	if GameManager.current_camera == GameManager.TOTAL_CAMERAS:
		await _run_finale()
	else:
		await hacker_type("Код %s принят! Получаю доступ к следующей камере..." % current_task_code)
		if not is_inside_tree(): return
		state = State.TRANSITION
		await get_tree().create_timer(SCROLL_DELAY).timeout
		if not is_inside_tree(): return
		GameManager.next_camera()

## Финал: камера #3 показывает связанную тыкву — доказательство собрано.
func _run_finale() -> void:
	await hacker_type("Код принят! Открываю прямой поток камеры #%d..." % GameManager.TOTAL_CAMERAS)
	if not is_inside_tree(): return
	await hacker_type("Погоди. Это что... ТЫКВА?! Связанная?!")
	if not is_inside_tree(): return
	await hacker_type("Отправляю кадр в полицию. Доказательство принято!")
	if not is_inside_tree(): return
	await hacker_type("ТЫКВА СПАСЕНА! Отличная работа, нейросеть. 🎃")
	state = State.FINALE

func _open_input() -> void:
	input_field.editable = true
	input_field.grab_focus()

func _push_session_separator() -> void:
	if GameManager.terminal_history != "":
		push(SESSION_SEPARATOR)
