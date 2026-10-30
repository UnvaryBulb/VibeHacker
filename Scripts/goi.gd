extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera = get_viewport().get_camera_2d()

var walk_speed = 200
var run_speed = 350
var jump_force = -400
var gravity = 980
var was_on_floor = true

func _physics_process(delta):
	# === 1. ГРАВИТАЦИЯ (только в воздухе) ===
	if not is_on_floor():
		velocity.y += gravity * delta
		was_on_floor = false
	
	# === 2. ГОРИЗОНТАЛЬНОЕ ДВИЖЕНИЕ (всегда, и в воздухе тоже!) ===
	var direction = Input.get_axis("ui_left", "ui_right")
	var is_running = Input.is_key_pressed(KEY_SHIFT)
	var current_speed = run_speed if is_running else walk_speed
	
	if direction != 0:
		velocity.x = direction * current_speed
		sprite.flip_h = direction < 0
	else:
		# В воздухе не тормозим резко — оставляем инерцию
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, current_speed)
	
	# === 3. ПРЫЖОК (только с земли) ===
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force
		was_on_floor = false
	
	# === 4. АНИМАЦИИ И SQUASH/STRETCH ===
	if not is_on_floor():
		# В воздухе — растяжение
		if velocity.y < 0:
			sprite.scale = sprite.scale.lerp(Vector2(0.8, 3.2), 10 * delta)
		else:
			sprite.scale = sprite.scale.lerp(Vector2(3.1, 0.9), 10 * delta)
	else:
		# На земле — возвращаем нормальный размер
		sprite.scale = sprite.scale.lerp(Vector2(2, 2), 10 * delta)
		
		# Эффект приземления
		if not was_on_floor:
			sprite.scale = Vector2(3.6, 0.7)
			camera.shake(2)
		
		was_on_floor = true
		
		# Анимации только на земле
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
