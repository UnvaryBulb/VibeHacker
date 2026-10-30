extends Area2D
## Ключ-награда на платформерном уровне.
## Парит на месте, при сборе играет звук, сыплет частицами и шлёт HEX-код.

signal key_collected(hex_code: String)

const BOB_AMPLITUDE := 5.0
const BOB_SPEED := 2.0
const DESPAWN_DELAY := 0.5

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var hex_code: String = "A1"  # Задаётся в Inspector

var _collected := false
var _time := 0.0
var _base_position: Vector2

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_base_position = position

	if particles:
		particles.emitting = false
		particles.one_shot = true

	_time = randf() * 10.0  # случайная фаза покачивания

func _process(delta: float) -> void:
	_time += delta
	position.y = _base_position.y + sin(_time * BOB_SPEED) * BOB_AMPLITUDE

func _on_body_entered(body: Node2D) -> void:
	if _collected:
		return
	if body.name != "Player" and not body.is_in_group("player"):
		return

	_collected = true
	if sound:
		sound.play()
	if particles:
		particles.emitting = true

	sprite.visible = false
	$CollisionShape2D.set_deferred("disabled", true)

	key_collected.emit(hex_code)

	await get_tree().create_timer(DESPAWN_DELAY).timeout
	queue_free()
