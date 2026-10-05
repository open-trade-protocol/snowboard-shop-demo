# Snowboard Shop Demo — Agent Instructions

## Архитектура
- Простой статический фронтенд в `html/`
- Docker-контейнер с Nginx
- Подключается к PEP Node через `http://localhost:8000/api/v1/listings`

## Правила
- Используйте только ванильный HTML/CSS/JS (без фреймворков)
- Изображения — через Unsplash placeholder URL
- Дизайн должен быть адаптивным (mobile-first)
- Все данные о товарах — только через API протокола (не храните в localStorage)

## Файлы
- `html/index.html` — главная страница магазина
- `Dockerfile` — конфиг Nginx
