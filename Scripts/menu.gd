extends Node2D
@onready var button_focusSFX = $SFXbutton_focus
@onready var button_pressSFX = $SFXbutton_press

const WAVE_SHADER := preload("res://Shaders/Main menu/hover_wave.gdshader")

var wave_tweens := {}

func _ready() -> void:
	for btn in [$play, $quit]:
		var mat := ShaderMaterial.new()
		mat.shader = WAVE_SHADER
		btn.material = mat
	var music := get_node_or_null("MusicPlayer") as AudioStreamPlayer
	if music != null and music.stream is AudioStreamOggVorbis:
		(music.stream as AudioStreamOggVorbis).loop = true


func _play_wave(btn: Button) -> void:  # Анимация кнопок
	if wave_tweens.has(btn) and wave_tweens[btn].is_running():
		return
	var mat := btn.material as ShaderMaterial
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_method(func(v: float): mat.set_shader_parameter("progress", v), 0.0, 1.0, 0.5)
	wave_tweens[btn] = tw

func _on_play_pressed() -> void:
	
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_quit_pressed() -> void:
	
	get_tree().quit()


func _on_play_mouse_entered() -> void:
	button_focusSFX.play(1.0)
	_play_wave($play)

func _on_quit_mouse_entered() -> void:
	button_focusSFX.play(1.0)
	_play_wave($quit)

func _on_quit_button_down() -> void:
	button_pressSFX.play(1.0)


func _on_play_button_down() -> void:
	button_pressSFX.play(1.0)
