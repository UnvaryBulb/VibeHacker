extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera = get_viewport().get_camera_2d()

# === НАСТРОЙКИ ДВИЖЕНИЯ ===
var walk_speed = 200
var run_speed = 350
var jump_force = -420
var gravity = 1200  # Чуть выше для более "прыгучего" ощущения
var acceleration = 1500  # Плавный разгон
var friction = 2000      # Плавное торможение
var air_acceleration = 800  # Медленнее разгон в воздухе

# === СОЧНЫЕ ФИЧИ ===
var coyote_time = 0.1      # Секунды после схода с платформы
var jump_buffer = 0.1      # Секунды буфера прыжка
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var was_on_floor = true

func _physics_process(delta):
	# === ТАЙМЕРЫ ===
	if is_on_floor():
		coyote_timer = coyote_time  # Сбрасываем койот-тайм на земле
	else:
		coyote_timer -= delta       # Отсчёт в воздухе
	
	if Input.is_action_just_pressed("ui_up"):
		jump_buffer_timer = jump_buffer  # Запоминаем нажатие прыжка
	else:
		jump_buffer_timer -= delta
	
	# === ГРАВИТАЦИЯ ===
	if not is_on_floor():
		velocity.y += gravity * delta
		was_on_floor = false
	else:
		was_on_floor = true
	
	# === ПРЫЖОК (с койот-таймом и буфером!) ===
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_force
		jump_buffer_timer = 0
		coyote_timer = 0
		was_on_floor = false
		camera.shake(3)
	
	# === Variable Jump Height ===
	# Если отпустили прыжок в воздухе — обрезаем скорость
	if not Input.is_action_pressed("ui_up") and velocity.y < -150:
		velocity.y = -150
	
	# === ГОРИЗОНТАЛЬНОЕ ДВИЖЕНИЕ ===
	var direction = Input.get_axis("ui_left", "ui_right")
	var is_running = Input.is_key_pressed(KEY_SHIFT)
	var target_speed = run_speed if is_running else walk_speed
	
	if direction != 0:
		# Плавный разгон
		var accel = acceleration if is_on_floor() else air_acceleration
		velocity.x = move_toward(velocity.x, direction * target_speed, accel * delta)
		sprite.flip_h = direction < 0
	else:
		# Плавное торможение
		var fric = friction if is_on_floor() else friction * 0.5
		velocity.x = move_toward(velocity.x, 0, fric * delta)
	
	# === АНИМАЦИИ ===
	if not is_on_floor():
		if velocity.y < 0:
			sprite.scale = sprite.scale.lerp(Vector2(1.5, 2.5), 10 * delta)
		else:
			sprite.scale = sprite.scale.lerp(Vector2(2.4, 1.6), 10 * delta)
	else:
		sprite.scale = sprite.scale.lerp(Vector2(2, 2), 10 * delta)
		
		if not was_on_floor:
			sprite.scale = Vector2(2.9, 1.4)
			camera.shake(2)
		
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
