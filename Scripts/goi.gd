extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera = get_viewport().get_camera_2d()
var walk_speed = 200
var run_speed = 350
var jump_force = -400
var gravity = 980
var was_on_floor = true

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
		# Растягиваем в воздухе
		if velocity.y < 0:
			sprite.scale = Vector2(1.8, 2.2)
		else:
			sprite.scale = Vector2(2.1, 1.9)
		
		was_on_floor = false  # ✅ ВАЖНО: запоминаем что мы в воздухе
	else:
		# Возвращаем нормальный размер
		sprite.scale = sprite.scale.lerp(Vector2(2, 2), 10 * delta)
		
		# Эффект приземления
		if not was_on_floor:
			sprite.scale = Vector2(2.6, 1.7)
			camera.shake(2)
		was_on_floor = true
		
		# ✅ ПРЫЖОК (я его забыл в прошлом коде!)
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = jump_force
			was_on_floor = false  # Сразу помечаем что мы в воздухе
			sprite.scale = Vector2(1.8, 2.2)  # Растягиваем при прыжке
		
		# Движение
		var direction = Input.get_axis("ui_left", "ui_right")
		var is_running = Input.is_key_pressed(KEY_SHIFT)
		var current_speed = run_speed if is_running else walk_speed
		
		if direction != 0:
			velocity.x = direction * current_speed
			sprite.flip_h = direction < 0
			
			if is_running:
				if sprite.animation != "run":
					sprite.play("run")
			else:
				if sprite.animation != "walk":
					sprite.play("walk")
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			if sprite.animation != "idle":
				sprite.play("idle")
	
	move_and_slide()
