<h1 align="center">QuickGo</h1>

<p align="center">
  A full-stack e-commerce system — a Flutter customer storefront and worker/admin apps on a Node.js/Express + MongoDB REST API.
</p>

<p align="center">
  <a href="https://github.com/shaurya-8055/QUICKGO/actions/workflows/ci.yml"><img src="https://github.com/shaurya-8055/QUICKGO/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://shaurya-8055.github.io/QUICKGO/"><img src="https://img.shields.io/badge/demo-live-brightgreen" alt="Live demo"></a>
  <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Node.js-339933?logo=node.js&logoColor=white" alt="Node.js">
  <img src="https://img.shields.io/badge/MongoDB-47A248?logo=mongodb&logoColor=white" alt="MongoDB">
</p>

<p align="center">
  <b>Live web demo:</b> <a href="https://shaurya-8055.github.io/QUICKGO/">shaurya-8055.github.io/QUICKGO</a>
  · <a href="https://shaurya-8055.github.io/QUICKGO/emulator.html">phone-frame view</a>
</p>

---

## What's inside

| Component | Path | What it does |
|---|---|---|
| **Customer storefront** | `client_side/client_app` | Poster carousel, category chips, responsive product grid, product details, cart, search & filters, profile and notifications |
| **Worker app** | `client_side/worker_app` | Service-provider ("WorkerPro") app |
| **Admin console** | `client_side/admin_app_complt_app` | Manage categories, brands, products, variants, posters, orders and coupons |
| **REST API** | `server_side/online_store_api` | Express + Mongoose API: products, categories, posters, orders, users and file uploads |

## Tech stack

- **Apps** — Flutter 3.x / Dart 3.x, Provider for state
- **API** — Node.js + Express, MongoDB via Mongoose
- **Uploads** — Multer; static images served from `public/`

## Repository structure

```
client_side/
  client_app/              # Flutter customer app (primary app)
  worker_app/              # Flutter service-provider app
  admin_app_complt_app/    # Flutter admin console
server_side/
  online_store_api/        # Node/Express API + MongoDB models
  node_js_startup_code/    # Scratch/starter Node examples
photos/                    # Sample images used in demos
```

---

## Quick start

Run in this order: API → customer app → (optional) worker/admin apps.

### 1. Backend API

```bash
cd server_side/online_store_api
npm install
```

Create `.env` in `server_side/online_store_api`:

```env
PORT=3000
MONGO_URI=mongodb://localhost:27017/online_store
# Absolute image URLs the apps can load
PUBLIC_BASE_URL=http://localhost:3000
# On a LAN, use e.g. http://192.168.1.50:3000
```

```bash
npm run dev
```

- REST routes live under `/api/products`, `/api/categories`, etc.
- Static images are served from `/public/products`, `/public/category`, `/public/posters`.
- Uploads save there and return absolute URLs based on `PUBLIC_BASE_URL`.
- A `docker-compose.yml` is available if you prefer containerised MongoDB.
- Android emulators reach the host at `http://10.0.2.2:3000`.

### 2. Customer app

```bash
cd client_side/client_app
flutter pub get
flutter run
```

- The app resolves the API base URL per platform (Android emulator → `10.0.2.2`).
- Release build: `flutter build apk --release` → `client_side/client_app/build/app/outputs/flutter-apk/app-release.apk`.

**Customer features**

- Home: poster carousel, category chips, featured-product grid
- Product details: gallery, variant selection, add to cart
- Cart: quantity updates and order-flow scaffold
- Search & filters: category/brand filtering
- Profile, services and notifications screens
- Responsive product grid (2 columns on phones, 3–8+ on tablets/laptops)

### 3. Worker and admin apps (optional)

```bash
cd client_side/worker_app            # or admin_app_complt_app
flutter pub get
flutter run
```

---

## Project anatomy

**Flutter client (`client_side/client_app/lib`)**

- `main.dart` — bootstrap, theme, providers
- `services/http_services.dart` — REST calls
- `core/data/data_provider.dart` — central data fetch/state
- `models/*` — DTOs (product, category, user, order, poster, coupon…)
- `screen/*` — feature screens (home, product list/details, cart, category, login, profile, notifications)
- `widget/*` — reusable UI (responsive masonry grid, product cards, filter sheet, shimmer)
- `utility/*` — theming and helpers

**Node API (`server_side/online_store_api`)**

- `index.js` — Express entry
- `routes/*` — modular REST endpoints
- `model/*` — Mongoose schemas
- `public/*` — uploaded/static images
- `uploadFile.js` — Multer config
- `services/*`, `search/*` — search integrations and helpers

---

## Continuous integration

`.github/workflows/ci.yml` runs on every push and pull request:

- resolves dependencies for all three Flutter apps, analyzes and web-builds the customer app
- installs the API dependencies and syntax-checks the Express entry point

## Troubleshooting

- **Images not loading on Android emulator** — use `10.0.2.2` as the API host and make sure it returns absolute URLs. Allow cleartext traffic or serve over HTTPS in dev.
- **R8/minify breaks a third-party SDK** — add keep rules or disable minify in `build.gradle` until rules are set.
- **`npm ci` fails** — the committed lockfile is out of sync; use `npm install` (or commit a refreshed lockfile).

## Conventions

- Keep state in Provider and network calls in services/providers.
- Keep models in `lib/models` aligned with API responses.
- Commit uploaded images under `public/` only for demos; store production media externally (S3, GCS).

## License

MIT. See [LICENSE](LICENSE).
