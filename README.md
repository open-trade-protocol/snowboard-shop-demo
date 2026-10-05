# 🏂 Snowboard Shop — OpenTrade Protocol Demo

Этот магазин **не хранит товары локально**, а получает их исключительно через API протокола OpenTrade.

## Концепция

Snowboard Shop — это фронтенд-демонстрация, которая:

1. **Не имеет собственной базы данных товаров**
2. **Загружает каталог в реальном времени** с узла PEP Node (`http://localhost:8000/api/v1/listings`)
3. **Отображает листинги** как карточки товаров
4. **Поддерживает фильтрацию** по категориям через параметры URL

## Запуск

```bash
# Через Docker Compose (рекомендуется)
cd ../infrastructure
docker compose up --build -d

# Фронтенд: http://localhost:8000
# API: http://localhost:8000/api/v1/listings
```

## Структура

```
snowboard-shop-demo/
├── html/
│   └── index.html    # Единственная страница приложения
├── Dockerfile
└── README.md
```

## Лицензия

Apache-2.0
