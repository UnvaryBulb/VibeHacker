<div align="center">

# 🖥️ SIBERIAN GAME JAM PROJECT

### *Терминал. Камеры. Пиксели.*

[![Godot Engine](https://img.shields.io/badge/Godot-4.7-478cbf?logo=godot-engine&logoColor=white)](https://godotengine.org/)
[![GDScript](https://img.shields.io/badge/GDScript-3573a9?logo=googlesheets&logoColor=white)](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Desktop-orange)](#)
[![Jam](https://img.shields.io/badge/SiberianGameJam-2026-red?style=flat-square)](#)

![CRT Vibes](https://img.shields.io/badge/-⣿⣿⣟⣻⡻⢟⣟⡻⢻⣻⡿⣿⣿-000000?style=for-the-badge)

</div>

---

## 📖 О проекте

**SiberianGameJamProject** — атмосферная головоломка с CRT-эстетикой, созданная за время Siberian Game Jam. Вы получаете доступ к странной системе наблюдения: переключайтесь между камерами, находите скрытые коды на экранах, вводите их в терминал и проникайте в пиксельные платформенные уровни через HEX-разломы реальности.

> `root@surveillance:~$ ./wake_up.sh`
> `[OK] Terminal online. [OK] Cameras: 3 detected. [WARN] Something is watching back.`

## ✨ Особенности

- 🕹️ **Гибридный геймплей** — терминал + наблюдение за камерами + мини-платформеры
- 🔐 **HEX-головоломки** — собирай коды с экранов камер и открывай новые уровни
- 📺 **CRT-шейдеры** — аутентичный ретро-эффект кинескопа поверх игры и терминала
- ⌨️ **Интерактивный терминал** — команды, всплывающие HEX-окна, живой отклик системы
- 🎮 **Ретро-стиль** — шрифт Press Start 2P, пиксельные спрайты, чиптюн-саундтрек (OST + SFX)
- 🌙 **Автосохранение состояния** через глобальный `GameManager`

## 🎮 Как играть

1. Запусти игру — ты окажешься перед **терминалом системы наблюдения**.
2. Переключайся между **камерами** и изучай скриншоты — на экранах спрятаны коды.
3. Вводи найденные коды в терминал, чтобы получать **HEX-награды**.
4. HEX-код открывает доступ к **пиксельному платформенному уровню** — пройди его!
5. Собирай ключи 🔑, исследуй объекты (GOI) и добирайся до финала.

### Управление

| Клавиша | Действие |
|---------|----------|
| `←` `→` `↑` `↓` / `WASD` | Движение |
| `Enter` | Подтверждение / ввод команды |
| Мышь | Интерактивные элементы, терминал, окна HEX |

## 🗂️ Структура проекта

```
📦 SiberianGameJamProject
├── 📂 Assets            # Спрайты, шрифты (Press Start 2P), OST и SFX
├── 📂 Scenes            # Сцены: меню, игра, терминал, уровни, попапы
│   ├── menu.tscn            # Главное меню
│   ├── terminal.tscn        # Интерактивный терминал
│   ├── game.tscn            # Игровой цикл
│   ├── lvlA1.tscn           # Платформенный уровень A1
│   ├── HexPopup.tscn        # HEX-награда
│   ├── GOI.tscn             # Объект взаимодействия (GOI)
│   └── key.tscn             # Collectible-ключ
├── 📂 Scripts           # GDScript-логика
│   ├── GameManager.gd       # Autoload: состояние игры и данные камер
│   ├── TerminalController.gd# Логика терминала и команд
│   ├── camera_2d.gd         # Умная камера следования
│   ├── hex_popup.gd         # Всплывающие HEX-окна
│   └── music_control.gd     # Управление музыкой и звуками
├── 📂 Shaders           # CRTShader & ScreenCRT — ретро-фильтры
├── project.godot        # Конфигурация Godot 4.7 (Forward Plus)
└── default_bus_layout.tres # Аудио-шины (музыка / SFX)
```

## 🛠️ Технологии

| Компонент | Инструмент |
|-----------|------------|
| Движок | **Godot 4.7** (Forward Plus) |
| Язык | **GDScript** |
| Графика | Пиксельные спрайты + **Custom GLSL CRT-шейдеры** |
| Шрифт | [Press Start 2P](https://fonts.google.com/specimen/Press+Start+2P) |
| Звук | Собственный OST и SFX-банк |
| Архитектура | Autoload `GameManager` + глобальные группы (`player`) |

## 🚀 Запуск

### Требования

- [Godot Engine 4.7+](https://godotengine.org/download) (стандартная версия, не .NET)

### Шаги

```bash
# 1. Клонируй репозиторий
git clone https://github.com/UnvaryBulb/SiberianGameJamProject.git
cd SiberianGameJamProject

# 2. Открой проект в Godot
godot --path . --editor   # или просто перетащи папку в лаунчер Godot

# 3. Нажми ▶ Play (F5) — загрузится главная сцена
```

Готовые сборки (если доступны) — смотри вкладку [Releases](../../releases).

## 👥 Команда

| Роль | Участник |
|------|----------|
| Разработка & Дизайн | [UnvaryBulb](https://github.com/UnvaryBulb) |
| Игра сделана на | **Siberian Game Jam 2026** |

## 📄 Лицензия

Проект распространяется под лицензией **MIT** — подробности в файле [LICENSE](LICENSE).

---

<div align="center">

`[SYSTEM]: Transmission ended.`

Сделано с ❤️ и статическим шумом · **Siberian Game Jam 2026**

</div>
