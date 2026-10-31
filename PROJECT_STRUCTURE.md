# 📚 Структура проекта VibeHacker

Каждая ключевая директория содержит свой `README.md` с подробным описанием.

| Директория | Назначение | Подробнее |
|---|---|---|
| [`Assets/`](Assets/README.md) | Все медиаресурсы: музыка (OST), звуки (SFX), спрайты, шрифт Press Start 2P | [Assets/README.md](Assets/README.md) |
| [`Scenes/`](Scenes/README.md) | Сцены Godot (`.tscn`): меню, терминал, уровни, попады, пауза | [Scenes/README.md](Scenes/README.md) |
| [`Scripts/`](Scripts/README.md) | Код игры на GDScript (`.gd`): GameManager, терминал, геймплей, UI | [Scripts/README.md](Scripts/README.md) |
| [`Shaders/`](Shaders/README.md) | GLSL-шейдеры (`.gdshader`): CRT-эффекты и анимации меню | [Shaders/README.md](Shaders/README.md) |

## Корневые файлы

| Файл | Назначение |
|---|---|
| `project.godot` | Конфигурация проекта Godot (autoload-скрипты, действия ввода, стартовая сцена) |
| `default_bus_layout.tres` | Аудиошины **Music** и **SFX** |
| `icon.svg` | Иконка проекта |
| `README.md` | Главный readme проекта |
| `LICENSE` | Лицензия MIT |
