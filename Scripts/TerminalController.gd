extends Control

@onready var logs: RichTextLabel = $VBoxContainer/logs
@onready var input_field: LineEdit = $VBoxContainer/HBoxContainer/enter

var state: String = "chat"
var current_task_code: String = ""
var is_typing: bool = false  # ← НОВЫЙ ФЛАГ

func _ready():
	start_first_mission()

func start_first_mission():
	
	await hacker_type("Связь установлена. Я получил доступ к камере #1.")
	await hacker_type("Скидываю скриншот. Найди на нём 4-значный код.")
	
	logs.append_text('[img=400x225]res://Assets/Sprites/ancap.png[/img]\n')

	
	await hacker_type("Введи код в терминал.")
	
	state = "waiting_code"
	current_task_code = "1337"
	input_field.editable = true   # ← Разблокируем ввод
	input_field.grab_focus()

func hacker_type(text: String, speed: float = 0.03):
	is_typing = true
	input_field.editable = false  # ← БЛОКИРУЕМ ПОЛЕ ВВОДА
	
	logs.append_text("[color=yellow]> ХАЦКЕР:[/color] ")
	for char in text:
		logs.append_text(char)

		await get_tree().create_timer(speed).timeout
	logs.append_text("\n")
	
	is_typing = false
	# Поле НЕ разблокируем здесь — разблокирует тот, кто вызывает функцию
	# (например, после последнего сообщения хакера)

func _on_enter_text_submitted(new_text: String):
	# Защита от отправки во время печати (на всякий случай)
	if is_typing:
		input_field.text = ""
		return
	
	var input = new_text.to_upper().strip_edges()
	input_field.text = ""
	
	logs.append_text("[color=green]> ТЫ:[/color] " + input + "\n")

	
	if state == "waiting_code":
		if input == current_task_code:
			await hacker_type("Код принят! Взламываю уровень...")
			state = "platformer"
		else:
			await hacker_type("Неверный код. Посмотри внимательнее на скриншот.")
			input_field.editable = true  # ← Разблокируем, чтобы игрок мог попробовать снова
			input_field.grab_focus()
	
	
