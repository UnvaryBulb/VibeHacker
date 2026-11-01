extends StaticBody2D

@export var action_name: String = "door1"
@export var open_offset: Vector2 = Vector2.UP * 64.0
@export var move_time: float = 0.5
@export var required_count: int = 0  # 0 = нужны ВСЕ переключатели

var base_pos: Vector2
var open := false
var switch_states: Dictionary = {}  # переключатель -> активен ли

@onready var sound: AudioStreamPlayer2D = get_node_or_null("Sound")
@onready var indicator: Label = get_node_or_null("Indicator")

func _ready():
	base_pos = position
	# Ждём кадр, чтобы все рычаги/кнопки успели войти в группу "switches"
	await get_tree().process_frame
	_scan_switches()
	_update_indicator()

func _scan_switches():
	for node in get_tree().get_nodes_in_group("switches"):
		if node.get("action_name") == action_name and node.has_signal("pressed_state"):
			switch_states[node] = false
			node.pressed_state.connect(_on_switch_changed.bind(node))

func _on_switch_changed(pressed: bool, switch: Node):
	switch_states[switch] = pressed
	# Щелчок каждого переключателя
	if sound:
		sound.pitch_scale = randf_range(0.9, 1.1)
		sound.play()
	_update_indicator()
	_evaluate()

func _needed() -> int:
	if required_count > 0:
		return mini(required_count, switch_states.size())
	return switch_states.size()

func _active_count() -> int:
	var n := 0
	for key in switch_states:
		if switch_states[key]:
			n += 1
	return n

func _evaluate():
	if switch_states.is_empty():
		return
	var active := _active_count()
	if active >= _needed() and not open:
		_open()
	elif active < _needed() and open:
		_close()

func _update_indicator():
	if indicator:
		indicator.text = "%d/%d" % [_active_count(), _needed()]
		if _active_count() >= _needed():
			indicator.modulate = Color(0.4, 1.0, 0.5)  # зелёный
		else:
			indicator.modulate = Color(1.0, 0.85, 0.2)  # жёлтый

func _open():
	open = true
	$CollisionShape2D.set_deferred("disabled", true)
	var t := create_tween()
	t.tween_property(self, "position", base_pos + open_offset, move_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close():
	open = false
	$CollisionShape2D.set_deferred("disabled", false)
	var t := create_tween()
	t.tween_property(self, "position", base_pos, move_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
