extends Node2D
## Главное меню: wave-анимация кнопок (шейдер hover_wave) и звук фокуса/нажатия.

const WAVE_SHADER := preload("res://Shaders/Main menu/hover_wave.gdshader")

## Имена кнопок с wave-анимацией.
const WAVE_BUTTON_NAMES := ["play", "quit"]

var _wave_tweens: Dictionary = {}

@onready var button_focus_sfx: AudioStreamPlayer = $SFXbutton_focus
@onready var button_press_sfx: AudioStreamPlayer = $SFXbutton_press

func _ready() -> void:
	for name in WAVE_BUTTON_NAMES:
		var btn := get_node(name) as Button
		var mat := ShaderMaterial.new()
		mat.shader = WAVE_SHADER
		btn.material = mat

	# Зацикливаем музыку меню, если она ещё не в цикле.
	var music := get_node_or_null("MusicPlayer") as AudioStreamPlayer
	if music != null and music.stream is AudioStreamOggVorbis:
		(music.stream as AudioStreamOggVorbis).loop = true

func _on_play_pressed() -> void:
	$play.disabled = true  # защита от двойного клика
	GameManager.start_game()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_mouse_entered() -> void:
	button_focus_sfx.play()
	_play_wave($play)

func _on_quit_mouse_entered() -> void:
	button_focus_sfx.play()
	_play_wave($quit)

func _on_play_button_down() -> void:
	button_press_sfx.play()

func _on_quit_button_down() -> void:
	button_press_sfx.play()

## Прогоняет параметр `progress` шейдера от 0 до 1 (волна по кнопке).
func _play_wave(btn: Button) -> void:
	if _wave_tweens.has(btn) and (_wave_tweens[btn] as Tween).is_running():
		return
	var mat := btn.material as ShaderMaterial
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_method(func(v: float) -> void: mat.set_shader_parameter("progress", v), 0.0, 1.0, 0.5)
	_wave_tweens[btn] = tw
