extends CharacterBody2D

# === ЯЩИК: детерминированный, без капризов RigidBody ===
var gravity: float = 1200.0
var push_speed: float = 0.0        # скорость, которую "передал" игрок
var slide_friction: float = 1200.0  # как быстро доскальзывает по инерции
var push_multiplier: float = 1   # доля скорости игрока (0.5 = тяжёлый, 0.9 = лёгкий)
var home_position: Vector2

func _ready():
	home_position = global_position

func reset():
	global_position = home_position
	velocity = Vector2.ZERO
	push_speed = 0.0
func _physics_process(delta):
	# Гравитация
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Горизонталь: едем на переданной скорости, иначе доскальзываем
	velocity.x = push_speed
	push_speed = move_toward(push_speed, 0.0, slide_friction * delta)
	
	move_and_slide()

# Игрок вызывает это каждый кадр контакта
func push(player_speed: float):
	push_speed = player_speed * push_multiplier
