# 🏂 Snowboard Shop — OpenTrade Protocol Demo

Этот магазин **не хранит товары локально**, а получает их исключительно через API протокола OpenTrade.

## Концепция

Snowboard Shop — это фронтенд-демонстрация, которая:

1. **Не имеет собственной базы данных товаров**
2. **Загружает каталог в реальном времени** с узла PEP Node (`http://localhost:8000/api/v1/listings`)
3. **Отображает листинги** как карточки товаров с изображениями
4. **Поддерживает фильтрацию** по категориям, цене и поиску
5. **Адаптивный дизайн** — работает на десктопе, планшете и мобильном

## Возможности

- **Фильтры по категориям**: Сноуборды, Биндинги, Ботинки
- **Фильтр по цене**: от и до (в RUB)
- **Поиск по названию**: мгновенная фильтрация
- **Сортировка**: по цене (возр./убыв.), по названию
- **Карточки товаров**: изображение, название, описание, цена, состояние, продавец
- **Модальное окно оформления**: с информацией о товаре и escrow-уведомлением
- **Адаптивный дизайн**: 4 колонки (десктоп) → 3 → 2 → 1 (мобильный)
- **Статус API**: индикатор подключения в реальном времени
- **Fallback**: офлайн-режим при недоступности API

## Запуск

### Через Docker Compose (рекомендуется)

```bash
cd ../infrastructure
docker compose up --build -d
```

### Напрямую

```bash
# Запустите PEP Node сначала
cd ../pep-node
python3 -m app.main

# Откройте html/index.html в браузере
# Или используйте любой HTTP-сервер:
python3 -m http.server 8080 --directory html
```

## Фронтенд

- **URL**: http://localhost (или порт вашего веб-сервера)
- **API**: http://localhost:8000/api/v1/listings
- **Swagger Docs**: http://localhost:8000/docs

## Структура

```
snowboard-shop-demo/
├── html/
│   └── index.html    # Единственная страница (HTML + CSS + JS)
├── Dockerfile
└── README.md
```

## Требования к PEP Node

Для корректной работы необходимо:

1. Запустить PEP Node с seed-данными:
   ```bash
   cd ../pep-node
   python3 -m app.main
   cd ../infrastructure
   python3 scripts/seed-snowboards.py
   ```

2. Или загрузить данные через API:
   ```bash
   curl -X POST http://localhost:8000/api/v1/listings \
     -H "Content-Type: application/json" \
     -d '{"title":"Burton Custom X","description":"Фристайл","price":45000,"currency":"RUB","category":"snowboards","condition":"new","seller_node_id":"node-test-01"}'
   ```

## Лицензия

Apache-2.0
