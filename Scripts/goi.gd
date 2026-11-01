extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera = get_viewport().get_camera_2d()
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var land_sound: AudioStreamPlayer2D = $LandSound
@onready var step_sound: AudioStreamPlayer2D = $StepSound
@onready var dust: GPUParticles2D = $Dust

# === НАСТРОЙКИ ДВИЖЕНИЯ ===
var walk_speed = 200
var run_speed = 350
var jump_force = -420
var gravity = 1200
var acceleration = 1500
var friction = 2000
var air_acceleration = 800

# === ДУГА ПРЫЖКА (асимметрия = ощущениe) ===
var apex_gravity_mult = 0.55  # на вершине прыжка — "зависание"
var fall_gravity_mult = 1.2   # вниз падаем резче — прыжок снаппи

# === СОЧНЫЕ ФИЧИ ===
var coyote_time = 0.1
var jump_buffer = 0.1
var coyote_timer = 0.0
var jump_buffer_timer = 0.0

# === ЗВУКИ ===
var step_timer: float = 0.0
var walk_step_interval: float = 0.35
var run_step_interval: float = 0.18

# === ПРИЗЕМЛЕНИЕ ===
var min_land_speed: float = 150.0
var dead := false
var spawn_point: Vector2

func _ready():
	# Точка респауна: маркер SpawnPoint в уровне или стартовая позиция
	spawn_point = global_position
	var marker = get_tree().current_scene.get_node_or_null("SpawnPoint")
	if marker:
		spawn_point = marker.global_position
func _physics_process(delta):
	if dead:
		return
	# === ТАЙМЕРЫ ===
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
	
	if Input.is_action_just_pressed("ui_up"):
		jump_buffer_timer = jump_buffer
	else:
		jump_buffer_timer -= delta
	
	# === ГРАВИТАЦИЯ С АСИММЕТРИЕЙ ===
	if not is_on_floor():
		var g = gravity
		if abs(velocity.y) < 80.0:
			g *= apex_gravity_mult    # вершина: зависаем
		elif velocity.y > 0.0:
			g *= fall_gravity_mult    # падение: резче
		velocity.y += g * delta
	
	# === ПРЫЖОК ===
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_force
		jump_buffer_timer = 0
		coyote_timer = 0
		jump_sound.play()
		sprite.scale = Vector2(1.6, 2.4)  # резкий стретч на отрыве
		
	
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
			step_sound.pitch_scale = randf_range(0.9, 1.1)
			step_sound.play()
			step_timer = 0.0
	else:
		step_timer = 0.0
	
		# === ЗАПОМИНАЕМ СОСТОЯНИЕ ДО СТОЛКНОВЕНИЯ ===
	var was_in_air := not is_on_floor()
	var fall_speed := velocity.y
	var push_speed := velocity.x   # ✅ скорость ДО того, как move_and_slide её обнулит
	
	move_and_slide()
	
		# === ТОЛКАНИЕ ЯЩИКА ===
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var body := col.get_collider()
		if body != null and body.is_in_group("pushable") and body.has_method("push"):
			# Только контакт сбоку, чтобы не увозить ящик стоя на нём
			if abs(col.get_normal().x) > 0.7:
				body.push(push_speed)
	# === ПРИЗЕМЛЕНИЕ ===
	if was_in_air and is_on_floor() and fall_speed >= min_land_speed:
		# ✅ ЗВУК ВЕРНУЛСЯ + питч от силы удара
		land_sound.play()
		land_sound.pitch_scale = randf_range(0.85, 1.05) + fall_speed / 4000.0
		camera.shake(clampf(fall_speed / 120.0, 0.0, 3.0))
		var squash := clampf(fall_speed / 900.0, 0.0, 0.7)
		sprite.scale = Vector2(2.0 + squash, 2.0 - squash)
		spawn_dust(int(clampf(fall_speed / 60.0, 4.0, 16.0)))
		# ✅ HITSTOP при сильном ударе — ощущение веса
		if fall_speed > 550.0:
			hitstop()
	
	# === НАКЛОН ТЕЛА ПРИ БЕГЕ ===
	var target_rot := 0.0
	if direction != 0 and is_on_floor():
		target_rot = -0.05 if sprite.flip_h else 0.05
	if not is_on_floor():
		target_rot = 0.0
	sprite.rotation = lerp(sprite.rotation, target_rot, 15.0 * delta)
	
	# === АНИМАЦИИ И SQUASH/STRETCH ===
	if not is_on_floor():
		if velocity.y < 0:
			sprite.scale = sprite.scale.lerp(Vector2(1.8, 2.2), 10 * delta)
		else:
			sprite.scale = sprite.scale.lerp(Vector2(2.1, 1.9), 10 * delta)
	else:
		sprite.scale = sprite.scale.lerp(Vector2(2, 2), 10 * delta)
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

# === ПЫЛЬ ===
func spawn_dust(amount: int):
	if dust == null:
		return
	dust.amount = amount
	dust.restart()

# === МИКРО-ЗАМОРОЗКА ПРИ УДАРЕ ===
func hitstop():
	Engine.time_scale = 0.12
	# 4-й параметр true = таймер игнорирует time_scale (реальное время)
	await get_tree().create_timer(0.07, true, false, true).timeout
	Engine.time_scale = 1.0

func die():
	if dead:
		return
	dead = true
	velocity = Vector2.ZERO
	
	# === ЭФФЕКТЫ СМЕРТИ ===
	camera.shake(6.0)
	spawn_dust(14)                      # взрыв пыли в точке смерти
	sprite.modulate = Color(1.0, 0.3, 0.3)
	# if has_node("DeathSound"): $DeathSound.play()
	
	# === БЛЭКАУТ (маскирует телепорт) ===
	var fade := _make_fade()
	var t := create_tween()
	t.tween_property(fade, "color:a", 1.0, 0.25)
	await t.finished
	
	# === РЕСПАУН ПОД ЧЕРНОТОЙ ===
	_respawn()
	
	var t2 := create_tween()
	t2.tween_property(fade, "color:a", 0.0, 0.35)
	await t2.finished
	fade.get_parent().queue_free()  # убираем CanvasLayer с блэкаутом

func _make_fade() -> ColorRect:
	var layer := CanvasLayer.new()
	layer.layer = 30  # поверх всего, включая CRT
	var rect := ColorRect.new()
	rect.color = Color(0, 0, 0, 0)
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)
	add_child(layer)
	return rect

func _respawn():
	global_position = spawn_point
	velocity = Vector2.ZERO
	dead = false
	# Возвращаем вид персонажа
	sprite.modulate = Color.WHITE
	sprite.scale = Vector2(2, 2)
	sprite.rotation = 0.0
	# Сбрасываем таймеры, чтобы не выстрелили случайные шаги/прыжки
	step_timer = 0.0
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	# Ящики возвращаются домой (иначе застрянут в ямах = софблок)
	for crate in get_tree().get_nodes_in_group("pushable"):
		if crate.has_method("reset"):
			crate.reset()
		# Рычаги возвращаются в исходное (двери закроются по сигналу)
	for switch in get_tree().get_nodes_in_group("switches"):
		if switch.has_method("reset"):
			switch.reset()
