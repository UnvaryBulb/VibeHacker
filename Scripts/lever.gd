extends Area2D

signal pressed_state(is_pressed: bool)

@export var action_name: String = "door1"

var pulled := false

@onready var sprite = _find_sprite()
@onready var lamp: Node2D = get_node_or_null("Lamp")
@onready var sound: AudioStreamPlayer2D = get_node_or_null("Sound")

# Сам находим спрайт среди детей (Sprite2D или AnimatedSprite2D)
func _find_sprite():
	for child in get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			return child
	return null

func _ready():
	add_to_group("switches")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if pulled:
		return  # один раз — и навсегда
	if body.is_in_group("player"):
		pulled = true
		
		# ✅ ПЕРЕВОРОТ СПРАЙТА ПО ВЕРТИКАЛИ
		if sprite:
			sprite.flip_v = true
		
		if lamp:
			lamp.modulate = Color(0.4, 1.0, 0.5)
		if sound:
			sound.play()
		pressed_state.emit(true)
func reset():
	if not pulled:
		return  # не дёрнут — нечего сбрасывать
	pulled = false
	if sprite:
		sprite.flip_v = false      # спрайт обратно
	if lamp:
		lamp.modulate = Color.WHITE  # лампа гаснет
	if sound:
		sound.play()                 # обратный щелчок
	pressed_state.emit(false)        # ✅ дверь получит false и закроется САМА
