extends HSlider
## Ползунок громкости эффектов (шина "SFX") с сохранением в настройки.

const SETTINGS_PATH := "user://settings.cfg"
const SETTINGS_SECTION := "audio"
const SETTINGS_KEY := "sfx_volume"

var _bus_index: int = -1

func _ready() -> void:
	_bus_index = AudioServer.get_bus_index("SFX")
	value_changed.connect(_on_volume_changed)
	_load_settings()

func _on_volume_changed(value: float) -> void:
	# Ползунок даёт 0.0..1.0, Godot требует децибелы: linear_to_db.
	AudioServer.set_bus_volume_db(_bus_index, linear_to_db(value))
	_save_settings()

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)  # ок, если файла ещё нет
	config.set_value(SETTINGS_SECTION, SETTINGS_KEY, value)
	config.save(SETTINGS_PATH)

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		value = config.get_value(SETTINGS_SECTION, SETTINGS_KEY, 1.0)
