extends Area2D

signal pressed_state(is_pressed: bool)

@export var action_name: String = "door1"
@export var pressed_texture: Texture2D = null  # ⬅ перетащи сюда текстуру нажатой кнопки

var pressers: Array[Node2D] = []
var is_pressed: bool = false
var default_texture: Texture2D = null

@onready var sprite = _find_sprite()
@onready var sound: AudioStreamPlayer2D = get_node_or_null("Sound")

func _find_sprite():
	for child in get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			return child
	return null

func _ready():
	add_to_group("switches")
	if sprite is Sprite2D:
		default_texture = sprite.texture  # запоминаем исходную текстуру
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player") or body.is_in_group("pushable"):
		if not pressers.has(body):
			pressers.append(body)
		_update()

func _on_body_exited(body: Node2D):
	pressers.erase(body)
	_update()

func _update():
	var now := pressers.size() > 0
	if now == is_pressed:
		return
	is_pressed = now
	
	# ✅ СМЕНА СПРАЙТА
	if sprite:
		if sprite is Sprite2D and pressed_texture != null:
			# Обычный спрайт: меняем текстуру
			sprite.texture = pressed_texture if is_pressed else default_texture
		elif sprite is AnimatedSprite2D:
			# Анимированный: переключаем анимации, если они есть
			if is_pressed and sprite.sprite_frames.has_animation("pressed"):
				sprite.play("pressed")
			elif sprite.sprite_frames.has_animation("idle"):
				sprite.play("idle")
		else:
			# Фолбэк, если текстуру не задал: утапливание на 3px
			sprite.position.y = 3.0 if is_pressed else 0.0
	
	if sound:
		sound.pitch_scale = randf_range(0.9, 1.1)
		sound.play()
	pressed_state.emit(is_pressed)
