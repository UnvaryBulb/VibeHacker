<div align="center">

# 🖥️ VibeHacker

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

**VibeHacker** — атмосферная головоломка с CRT-эстетикой, созданная за время Siberian Game Jam. Ты — **нейросеть**, а не хакер. Тебе поступают запросы от хакера: взламывай камеры системы наблюдения и собирай доказательства того, что **тыковку держат в плену**.

> `root@surveillance:~$ ./wake_up.sh`
> `[OK] Terminal online. [OK] Cameras: 3 detected. [WARN] Something is watching back.`

## ✨ Особенности

- 🧠 **Ты — нейросеть** — никаких переключений камер вручную: хакер присылает тебе запросы на взлом конкретных камер
- 🔍 **Сбор улик** — находи на экранах камер доказательства плена тыковки
- 🔐 **HEX-головоломки** — собирай коды с экранов камер и открывай новые уровни
- 📺 **CRT-шейдеры** — аутентичный ретро-эффект кинескопа поверх игры и терминала
- ⌨️ **Интерактивный терминал** — команды, всплывающие HEX-окна, живой отклик системы
- 🎮 **Ретро-стиль** — шрифт Press Start 2P, пиксельные спрайты, чиптюн-саундтрек (OST + SFX)
- 🌙 **Автосохранение состояния** через глобальный `GameManager`

## 🎮 Как играть

1. Запусти игру — ты окажешься перед **терминалом**, принимающим запросы от хакера.
2. Получай **запросы на взлом камер** — система сама направит тебя к нужной камере.
3. Изучай кадры с камер и находи **скрытые коды** и улики на экранах.
4. Вводи найденные коды в терминал, чтобы получать **HEX-награды**.
5. HEX-код открывает доступ к **пиксельному платформенному уровню** — пройди его, собирай ключи 🔑, исследуй объекты (GOI) и раскрой правду о тыковке!

### Управление

| Клавиша | Действие |
|---------|----------|
| `←` `→` `↑` `↓` / `WASD` | Движение |
| `Enter` | Подтверждение / ввод команды |
| Мышь | Интерактивные элементы, терминал, окна HEX |

## 🛠️ Технологии

| Компонент | Инструмент |
|-----------|------------|
| Движок | **Godot 4.7** (Forward Plus) |
| Язык | **GDScript** |
| Графика | Пиксельные спрайты + **Custom GLSL CRT-шейдеры** |
| Шрифт | [Press Start 2P](https://fonts.google.com/specimen/Press+Start+2P) |
| Звук | Собственный OST и SFX-банк |
| Архитектура | Autoload `GameManager` + глобальные группы (`player`) |

## 📁 Структура проекта

Подробные README находятся в каждой директории:

| Директория | Что внутри |
|---|---|
| [`Assets/`](Assets/README.md) | Музыка (OST), звуки (SFX), спрайты, шрифт |
| [`Scenes/`](Scenes/README.md) | Сцены Godot: меню, терминал, уровни, попапы |
| [`Scripts/`](Scripts/README.md) | Код игры на GDScript |
| [`Shaders/`](Shaders/README.md) | CRT-шейдеры и эффекты меню |

Обзор структуры — в [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md).

## 👥 Команда — Unvarlings

| Участник | Роль |
|----------|------|
| [UnvaryBulb](https://github.com/UnvaryBulb) | Главный программист и геймдизайнер |
| Matisson | Композитор и саунддизайнер |
| pytro I | Художник-спрайтер |

Игра сделана на **Siberian Game Jam 2026**.

## 📄 Лицензия

Проект распространяется под лицензией **MIT** — подробности в файле [LICENSE](LICENSE).

---

<div align="center">

`[SYSTEM]: Transmission ended.`

Сделано с ❤️ и статическим шумом · **Unvarlings** · **Siberian Game Jam 2026**

</div>
