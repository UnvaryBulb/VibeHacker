extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

signal key_collected(hex_code: String)

@export var hex_code: String = "A1"  # задаётся в Inspector для каждого уровня
var collected: bool = false
var time: float = 0.0
var base_position: Vector2

func _ready():
	body_entered.connect(_on_body_entered)
	
	# ✅ Запоминаем исходную позицию ИНАЧЕ ключ улетит в (0, ~0)
	base_position = position
	time = randf() * 10.0
	
	if particles:
		particles.emitting = false
		particles.one_shot = true

func _process(delta):
	time += delta
	
	# === СИНУСНОЕ ПОКАЧИВАНИЕ ===
	position.y = base_position.y + sin(time * 2.0) * 5.0
	
	# Лёгкое покачивание-наклон (сочность!)
	sprite.rotation = sin(time * 1.5) * 0.12
	
	# "Дыхание" свечения — пульсация яркости
	sprite.modulate = Color(1, 1, 1, 0.85 + sin(time * 3.0) * 0.15)

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
