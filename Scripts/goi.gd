extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera = get_viewport().get_camera_2d()
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var land_sound: AudioStreamPlayer2D = $LandSound
@onready var step_sound: AudioStreamPlayer2D = $StepSound

# === НАСТРОЙКИ ДВИЖЕНИЯ ===
var walk_speed = 200
var run_speed = 350
var jump_force = -420
var gravity = 1200
var acceleration = 1500
var friction = 2000
var air_acceleration = 800

# === СОЧНЫЕ ФИЧИ ===
var coyote_time = 0.1
var jump_buffer = 0.1
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var was_on_floor = true

# === ЗВУКИ ===
var step_timer: float = 0.0
var walk_step_interval: float = 0.35  # Интервал шагов при ходьбе (сек)
var run_step_interval: float = 0.18   # Интервал шагов при беге (сек)
func _ready():
	randomize()  # Инициализируем генератор случайных чисел
func _physics_process(delta):
	# === ТАЙМЕРЫ ===
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
	
	if Input.is_action_just_pressed("ui_up"):
		jump_buffer_timer = jump_buffer
	else:
		jump_buffer_timer -= delta
	
	# === ГРАВИТАЦИЯ ===
	if not is_on_floor():
		velocity.y += gravity * delta
		was_on_floor = false
	else:
		# 🎵 ЗВУК ПРИЗЕМЛЕНИЯ (только если реально упали)
		if not was_on_floor and velocity.y > 100:
			land_sound.play()
			camera.shake(2)
		was_on_floor = true
	
	# === ПРЫЖОК ===
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_force
		jump_buffer_timer = 0
		coyote_timer = 0
		was_on_floor = false
		jump_sound.play()  # 🎵 ЗВУК ПРЫЖКА
		camera.shake(3)
	
	# === Variable Jump Height ===
	if not Input.is_action_pressed("ui_up") and velocity.y < -150:
		velocity.y = -150
	
	# === ГОРИЗОНТАЛЬНОЕ ДВИЖЕНИЕ ===
	var direction = Input.get_axis("ui_left", "ui_right")
	var is_running = Input.is_key_pressed(KEY_SHIFT)
	var target_speed = run_speed if is_running else walk_speed
	
	if direction != 0:
		var accel = acceleration if is_on_floor() else air_acceleration
		velocity.x = move_toward(velocity.x, direction * target_speed, accel * delta)
		sprite.flip_h = direction < 0
	else:
		var fric = friction if is_on_floor() else friction * 0.5
		velocity.x = move_toward(velocity.x, 0, fric * delta)
	
	# === ЗВУК ШАГОВ ===
	if direction != 0 and is_on_floor():
		step_timer += delta
		var interval = run_step_interval if is_running else walk_step_interval
		
		if step_timer >= interval:
			step_sound.pitch_scale = randf_range(0.9, 1.1)  # Случайный питч ±10%
			step_sound.play()
			step_timer = 0.0  # Сбрасываем таймер
	else:
		step_timer = 0.0  # Стоим — сбрасываем
	
	# === АНИМАЦИИ ===
	if not is_on_floor():
		if velocity.y < 0:
			sprite.scale = sprite.scale.lerp(Vector2(1.8, 2.2), 10 * delta)
		else:
			sprite.scale = sprite.scale.lerp(Vector2(2.1, 1.9), 10 * delta)
	else:
		sprite.scale = sprite.scale.lerp(Vector2(2, 2), 10 * delta)
		
		if not was_on_floor:
			sprite.scale = Vector2(2.6, 1.7)
		
		if direction != 0:
			if is_running:
				if sprite.animation != "run":
					sprite.play("run")
			else:
				if sprite.animation != "walk":
					sprite.play("walk")
		else:
			if sprite.animation != "idle":
				sprite.play("idle")
	
	move_and_slide()
