extends CanvasLayer
## Поп-ап расшифровки HEX-кода: глитч-анимация со случайными символами,
## «выпрыгивающий» код и пауза, чтобы игрок успел его запомнить.

signal finished

const GLITCH_CHARS := "0123456789ABCDEF#@%&*"
const GLITCH_FRAMES := 14
const GLITCH_FRAME_DELAY := 0.045
const REVEAL_HOLD_TIME := 2.2
const FADE_IN_TIME := 0.3
const FADE_OUT_TIME := 0.4
const POP_SCALE := Vector2(1.3, 1.3)

@onready var bg: ColorRect = $UI/BG
@onready var box: VBoxContainer = $UI/Center/Box
@onready var code_label: Label = $UI/Center/Code

func _ready() -> void:
	bg.color = Color(0, 0, 0, 0)
	box.modulate.a = 0.0

func show_code(hex: String) -> void:
	# 1. Плавно затемняем экран.
	var fade_in := create_tween().set_parallel(true)
	fade_in.tween_property(bg, "color:a", 0.85, FADE_IN_TIME)
	fade_in.tween_property(box, "modulate:a", 1.0, FADE_IN_TIME)
	await fade_in.finished

	# 2. Глитч-«расшифровка»: мельтешат случайные символы.
	for i in range(GLITCH_FRAMES):
		code_label.text = _rand_string(hex.length())
		await get_tree().create_timer(GLITCH_FRAME_DELAY).timeout
	code_label.text = hex  # ✅ Настоящий код!

	# 3. «Поп» масштаб — код выпрыгивает.
	box.pivot_offset = box.size / 2.0
	box.scale = POP_SCALE
	var pop := create_tween()
	pop.tween_property(box, "scale", Vector2.ONE, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await pop.finished

	# 4. Держим, чтобы игрок запомнил.
	await get_tree().create_timer(REVEAL_HOLD_TIME).timeout

	# 5. Плавно исчезаем.
	var fade_out := create_tween().set_parallel(true)
	fade_out.tween_property(bg, "color:a", 0.0, FADE_OUT_TIME)
	fade_out.tween_property(box, "modulate:a", 0.0, FADE_OUT_TIME)
	await fade_out.finished

	finished.emit()

func _rand_string(length: int) -> String:
	var s := ""
	for i in range(length):
		s += GLITCH_CHARS[randi() % GLITCH_CHARS.length()]
	return s
