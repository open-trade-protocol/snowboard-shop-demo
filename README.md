# 🏂 Snowboard Shop — OpenTrade Protocol Demo

Live demo: **[demo-shop.opentradeprotocol.com](https://demo-shop.opentradeprotocol.com)**

This shop **does not store products locally** — it fetches them in real-time from the PEP Node API.

## Concept

Snowboard Shop is a frontend demonstration that:

1. **Has no local product database**
2. **Fetches catalog in real-time** from PEP Node API (`http://localhost:8000/v1/api/v1/listings`)
3. **Displays listings** as product cards with images
4. **Supports filtering** by category, price, and search
5. **Responsive design** — works on desktop, tablet, and mobile

## Features

- **Category filters**: Snowboards, Bindings, Boots
- **Price range filter**: from/to (in RUB)
- **Search by title**: instant filtering
- **Sorting**: by price (asc/desc), by name
- **Product cards**: image, name, description, price, condition, seller
- **Checkout modal**: with product info and escrow notification
- **Responsive design**: 4 columns (desktop) → 3 → 2 → 1 (mobile)
- **API status indicator**: real-time connection status
- **Fallback**: offline mode when API is unavailable

## Images

Product images are sourced from Unsplash with brand-specific mapping:

| Brand | Image Source |
|-------|-------------|
| Burton | `burton-snowboard` |
| Nitro | `nitro-snowboard` |
| Capita | `capita-snowboard` |
| Arbor | `arbor-snowboard` |
| Jones | `jones-snowboard` |
| Vans | `vans-snowboard-boots` |
| ThirtyTwo | `thirtytwo-snowboard` |
| Ride | `ride-snowboard` |
| Rome | `rome-snowboard-bindings` |
| DC | `dc-shoes-snowboard` |

## Quick Start

### Via Docker Compose (Recommended)

```bash
cd ../infrastructure
docker compose up --build -d
```

Open **http://localhost:8080** in your browser.

### Direct

```bash
# Start PEP Node first
cd ../pep-node
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &

# Seed test data
cd ../infrastructure
python3 scripts/seed-snowboards.py --base-url http://localhost:8000

# Serve the demo
cd ../snowboard-shop-demo
python3 -m http.server 8080 --directory html
```

Open **http://localhost:8080** in your browser.

## API Integration

### Fetch Listings

```bash
# Get all listings
curl http://localhost:8000/v1/api/v1/listings

# Filter by category
curl "http://localhost:8000/v1/api/v1/listings?category=snowboards"

# Create listing
curl -X POST http://localhost:8000/v1/api/v1/listings \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Burton Custom X 162",
    "description": "Professional freestyle snowboard",
    "price": 45000,
    "currency": "RUB",
    "category": "snowboards",
    "condition": "new",
    "seller_node_id": "node-test-01"
  }'
```

### Search

```bash
# Full-text search
curl -X POST "http://localhost:8000/v1/api/v1/search?query=Burton&category=all"
```

## Project Structure

```
snowboard-shop-demo/
├── html/
│   └── index.html    # Single page (HTML + CSS + JS)
├── Dockerfile
└── README.md
```

## Technology Stack

- **HTML5** — Semantic markup
- **Tailwind CSS** (CDN) — Utility-first styling
- **Vanilla JavaScript** — No framework dependencies
- **Fetch API** — PEP Node communication
- **CSS Grid/Flexbox** — Responsive layout

## Development

### Adding New Products

Products are fetched from the PEP Node API. To add new products:

```bash
# Via seed script
cd ../infrastructure
python3 scripts/seed-snowboards.py --base-url http://localhost:8000

# Via API directly
curl -X POST http://localhost:8000/v1/api/v1/listings \
  -H "Content-Type: application/json" \
  -d '{"title":"New Product","price":10000,"currency":"RUB","category":"snowboards","condition":"new","seller_node_id":"node-test-01"}'
```

### Customizing Images

Edit the `PRODUCT_IMAGES` mapping in [`html/index.html`](html/index.html) to add your own brand-to-image mappings.

## Deployment

See the [Deployment Guide](https://opentradeprotocol.com/docs/node-operator/deployment/) for production setup.

## Verification

```bash
# Check API
curl http://localhost:8000/health

# Seed data
python3 ../infrastructure/scripts/seed-snowboards.py --base-url http://localhost:8000

# Verify system
bash ../infrastructure/scripts/verify-system.sh
```

## License

Apache-2.0
