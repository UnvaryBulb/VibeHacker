extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

signal key_collected(hex_code: String)

@export var hex_code: String = "A1"  # Задаётся в Inspector
var collected: bool = false
var time: float = 0.0
var base_position: Vector2

func _ready():
	body_entered.connect(_on_body_entered)
	base_position = position
	
	if particles:
		particles.emitting = false
		particles.one_shot = true
	
	time = randf() * 10.0

func _process(delta):
	time += delta
	position.y = base_position.y + sin(time * 2.0) * 5.0

func _on_body_entered(body: Node2D):
	if body.name == "Player" or body.is_in_group("player"):
		if collected:
			return
		collected = true
		
		if sound:
			sound.play()
		if particles:
			particles.emitting = true
			
		sprite.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		
		key_collected.emit(hex_code)
		
		await get_tree().create_timer(0.5).timeout
		queue_free()
