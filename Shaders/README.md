# ✨ Shaders — GLSL-шейдеры Godot (`.gdshader`)

Визуальные эффекты игры в стиле CRT/ретро. Подключаются как `ShaderMaterial` в сценах или прелоадятся в скриптах. Файлы `.uid` — идентификаторы Godot, не трогать.

| Шейдер | Назначение |
|---|---|
| `CRTShader.gdshader` | CRT-эффект для конкретного элемента (сканлайны, искривление, хроматические аберрации, виньетка, шум) |
| `ScreenCRT.gdshader` | Полноэкранный CRT-фильтр поверх всего экрана (читает `hint_screen_texture`) — сканлайны, curvature и т.д. |
| [`Main menu/`](Main%20menu/) | Шейдеры интерфейса главного меню |

Используется в: `Scenes/menu.tscn`, `Scenes/terminal.tscn`, `Scenes/game.tscn`; `hover_wave` подключается динамически в `Scripts/menu.gd`.
