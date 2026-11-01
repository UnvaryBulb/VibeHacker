extends CanvasLayer

signal finished

@onready var bg: ColorRect = $UI/BG
@onready var box: VBoxContainer = $UI/Center/Box
@onready var code_label: Label = $UI/Center/Box/Code
@onready var transition: AudioStreamPlayer2D = $transition
const GLITCH_CHARS = "0123456789ABCDEF#@%&*"

func _ready():
	bg.color = Color(0, 0, 0, 0)
	box.modulate.a = 0.0

func show_code(hex: String) -> void:
	# === 1. Плавно затемняем экран ===
	var t: Tween = create_tween()
	t.set_parallel(true)
	t.tween_property(bg, "color:a", 0.85, 0.3)
	t.tween_property(box, "modulate:a", 1.0, 0.3)
	await t.finished
	transition.play()
	# === 2. Глитч-"расшифровка": мельтешат случайные символы ===
	for i in range(14):
		code_label.text = _rand_string(hex.length())
		await get_tree().create_timer(0.045).timeout
	code_label.text = hex  # ✅ Настоящий код!

	# === 3. "Поп" масштаб — код выпрыгивает ===
	box.pivot_offset = box.size / 2.0
	box.scale = Vector2(1.3, 1.3)
	var t2: Tween = create_tween()
	t2.tween_property(box, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await t2.finished

	# === 4. Держим, чтобы игрок запомнил ===
	await get_tree().create_timer(2.2).timeout

	# === 5. Плавно исчезаем ===
	var t3: Tween = create_tween()
	t3.set_parallel(true)
	t3.tween_property(bg, "color:a", 0.0, 0.4)
	t3.tween_property(box, "modulate:a", 0.0, 0.4)
	await t3.finished

	finished.emit()

func _rand_string(length: int) -> String:
	var s := ""
	for i in range(length):
		s += GLITCH_CHARS[randi() % GLITCH_CHARS.length()]
	return s
