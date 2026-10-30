extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Сигнал, который мы будем ловить в GameManager или уровне
signal key_collected(hex_code: String)

var hex_code: String = "A1"  # Код, который выдаёт этот ключ (задаётся из уровня)
var collected: bool = false  # Чтобы не подобрать дважды
var time: float = 0.0        # Для покачивания
var base_position: Vector2  # ✅ НОВАЯ ПЕРЕМЕННАЯ
func _ready():
	# Подключаем сигнал подбора
	body_entered.connect(_on_body_entered)
	# ✅ ЗАПОМИНАЕМ ИСХОДНУЮ ПОЗИЦИЮ КЛЮЧА
	base_position = position 
	# Настраиваем частицы (не излучаем пока не подобрали)
	if particles:
		particles.emitting = false
		particles.one_shot = true  # Один выброс и стоп
	
	# Случайная фаза покачивания, чтобы ключи не двигались синхронно
	time = randf() * 10.0

func _process(delta):
	time += delta
	
	# ✅ ПРАВИЛЬНОЕ ПОКАЧИВАНИЕ: берем исходную позицию и прибавляем синус
	position.y = base_position.y + sin(time * 2.0) * 5.0
	
	# Лёгкое вращение (если нет анимации spin)
	sprite.rotation = sin(time * 1.5) * 0.2

func _on_body_entered(body: Node2D):
	# Проверяем что это игрок (по имени, группе или тегу)
	if body.name == "Player" or body.is_in_group("player"):
		if collected:
			return
		collected = true
		
		# === ЭФФЕКТЫ ПОДБОРА ===
		
		# 1. Звук
		if sound:
			sound.play()
		
		# 2. Частицы
		if particles:
			particles.emitting = true
		
		# 3. Скрываем спрайт (ключ "исчез")
		sprite.visible = false
		
		# 4. Отключаем коллизию (чтобы нельзя было подобрать снова)
		$CollisionShape2D.set_deferred("disabled", true)
		
		# 5. Отправляем сигнал с кодом
		key_collected.emit(hex_code)
		
		# 6. Удаляем ноду через небольшую задержку (чтобы частицы доиграли)
		await get_tree().create_timer(0.5).timeout
		queue_free()
