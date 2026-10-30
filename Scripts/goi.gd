extends CharacterBody2D
## Игрок (персонаж платформерных вставок).
## Классический platformer-контроллер: coyote time, jump buffering,
## variable jump height, бег на Shift, squash & stretch и звуки шагов.

# === НАСТРОЙКИ ДВИЖЕНИЯ ===
const WALK_SPEED := 200.0
const RUN_SPEED := 350.0
const JUMP_FORCE := -420.0
const GRAVITY := 1200.0
const ACCELERATION := 1500.0
const FRICTION := 2000.0
const AIR_ACCELERATION := 800.0

# === СОЧНЫЕ ФИЧИ ===
const COYOTE_TIME := 0.1
const JUMP_BUFFER := 0.1
const MIN_JUMP_VELOCITY := -150.0   # переменная высота прыжка
const LAND_THRESHOLD := 100.0       # минимальная скорость падения для звука приземления

# === ЗВУКИ ШАГОВ ===
const WALK_STEP_INTERVAL := 0.35
const RUN_STEP_INTERVAL := 0.18
const STEP_PITCH_RANGE := Vector2(0.9, 1.1)

# === ANIMATIONS ===
enum PlayerAnimation { IDLE, WALK, RUN }

## Имена анимаций в AnimatedSprite2D (порядок совпадает с enum).
const ANIMATION_NAMES: Array[StringName] = [&"idle", &"walk", &"run"]

const SPRITE_SCALE := Vector2(2, 2)
const STRETCH_UP := Vector2(1.8, 2.2)
const STRETCH_FALL := Vector2(2.1, 1.9)
const SQUASH_LAND := Vector2(2.6, 1.7)
const SCALE_LERP_SPEED := 10.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = get_viewport().get_camera_2d()
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var land_sound: AudioStreamPlayer2D = $LandSound
@onready var step_sound: AudioStreamPlayer2D = $StepSound

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _was_on_floor := true
var _step_timer := 0.0

func _ready() -> void:
	# В Godot 4 генератор случайных чисел инициализируется автоматически,
	# randomize() удалён из API.
	if not camera:
		push_warning("Player: Camera2D не найден во вьюпорте — тряска экрана будет пропущена.")

func _physics_process(delta: float) -> void:
	_update_jump_timers(delta)
	_apply_gravity_and_landing()
	_try_jump()
	_apply_horizontal_movement(delta)
	_play_step_sounds(delta)
	_update_animation()
	move_and_slide()

# === ТАЙМЕРЫ (coyote time + jump buffer) ===
func _update_jump_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = COYOTE_TIME
	else:
		_coyote_timer -= delta

	if Input.is_action_just_pressed("ui_up"):
		_jump_buffer_timer = JUMP_BUFFER
	else:
		_jump_buffer_timer -= delta

# === ГРАВИТАЦИЯ И ПРИЗЕМЛЕНИЕ ===
func _apply_gravity_and_landing() -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		_was_on_floor = false
	elif not _was_on_floor:
		_was_on_floor = true
		# 🎵 Звук приземления — только если реально упали
		if velocity.y > LAND_THRESHOLD:
			land_sound.play()
			if camera:
				camera.shake(2)

# === ПРЫЖОК ===
func _try_jump() -> void:
	if _jump_buffer_timer <= 0 or _coyote_timer <= 0:
		return
	velocity.y = JUMP_FORCE
	_jump_buffer_timer = 0
	_coyote_timer = 0
	_was_on_floor = false
	jump_sound.play()  # 🎵 Звук прыжка
	if camera:
		camera.shake(3)

# === ГОРИЗОНТАЛЬНОЕ ДВИЖЕНИЕ + Variable Jump Height ===
func _apply_horizontal_movement(delta: float) -> void:
	# Переменная высота прыжка: отпустил кнопку — гасим восходящую скорость.
	if not Input.is_action_pressed("ui_up") and velocity.y < MIN_JUMP_VELOCITY:
		velocity.y = MIN_JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	var is_running := Input.is_key_pressed(KEY_SHIFT)

	if direction != 0.0:
		var target_speed := RUN_SPEED if is_running else WALK_SPEED
		var accel := ACCELERATION if is_on_floor() else AIR_ACCELERATION
		velocity.x = move_toward(velocity.x, direction * target_speed, accel * delta)
		sprite.flip_h = direction < 0
	else:
		var fric := FRICTION if is_on_floor() else FRICTION * 0.5
		velocity.x = move_toward(velocity.x, 0.0, fric * delta)

# === ЗВУК ШАГОВ ===
func _play_step_sounds(delta: float) -> void:
	var moving := Input.get_axis("ui_left", "ui_right") != 0.0
	if not moving or not is_on_floor():
		_step_timer = 0.0  # Стоим — сбрасываем
		return

	_step_timer += delta
	var is_running := Input.is_key_pressed(KEY_SHIFT)
	var interval := RUN_STEP_INTERVAL if is_running else WALK_STEP_INTERVAL
	if _step_timer >= interval:
		step_sound.pitch_scale = randf_range(STEP_PITCH_RANGE.x, STEP_PITCH_RANGE.y)
		step_sound.play()
		_step_timer = 0.0

# === АНИМАЦИИ (squash & stretch) ===
func _update_animation() -> void:
	if not is_on_floor():
		var stretch := STRETCH_UP if velocity.y < 0 else STRETCH_FALL
		sprite.scale = sprite.scale.lerp(stretch, SCALE_LERP_SPEED * get_physics_process_delta_time())
		return

	sprite.scale = sprite.scale.lerp(SPRITE_SCALE, SCALE_LERP_SPEED * get_physics_process_delta_time())
	if not _was_on_floor:
		sprite.scale = SQUASH_LAND

	if Input.get_axis("ui_left", "ui_right") == 0.0:
		_play_animation(PlayerAnimation.IDLE)
	elif Input.is_key_pressed(KEY_SHIFT):
		_play_animation(PlayerAnimation.RUN)
	else:
		_play_animation(PlayerAnimation.WALK)


func _play_animation(animation: PlayerAnimation) -> void:
	var anim_name := ANIMATION_NAMES[animation]
	if sprite.animation != anim_name:
		sprite.play(anim_name)
