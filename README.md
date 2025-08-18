# Complete E‑Commerce App — Monorepo Guide

A full‑stack e‑commerce system with:

- Flutter client app (customers)
- Flutter admin app (catalog/content management)
- Node.js/Express + MongoDB backend (REST API, uploads, search helpers)

This README helps a new contributor set up, run, and extend the project on Windows.

## Repository Structure

```
client_side/
  client_app/              # Flutter customer app (primary app)
  admin_app_complt_app/    # Flutter admin console
server_side/
  online_store_api/        # Node/Express API + MongoDB models
  node_js_startup_code/    # Scratch/starter Node examples
photos/                    # Sample images used in demos
```

## Tech Stack

- Flutter 3.x, Dart 3.x, Provider for state management
- Node.js 18+ (Express), MongoDB (Mongoose)
- File uploads via multer; static assets served from `public/`

---

## Quick Start (recommended order)

1. Start the Backend API (Node + MongoDB)

- Location: `server_side/online_store_api`
- Create `.env` (see the example below) and install dependencies.
- Start the server; confirm it serves JSON at `/api` routes and static images under `/public`.

2. Run the Flutter Client App

- Location: `client_side/client_app`
- Ensure the base API URL points to your server (emulator uses `10.0.2.2`).
- Launch on an Android emulator or a device.

3. Optional: Run the Admin App

- Location: `client_side/admin_app_complt_app`
- Same Flutter steps; log in and perform CRUD on categories/products/posters.

---

## Backend API — Setup and Run

Folder: `server_side/online_store_api`

1. Install

```powershell
cd server_side/online_store_api
npm install
```

2. Environment
   Create a `.env` file in `online_store_api` with contents like:

```
PORT=3000
MONGO_URI=mongodb://localhost:27017/online_store
# Set this so the API emits absolute image URLs your app can load
PUBLIC_BASE_URL=http://localhost:3000
# Optional: If you serve from a LAN IP, set this to http://<your-ip>:3000
# PUBLIC_BASE_URL=http://192.168.1.50:3000
```

3. Run

```powershell
npm run dev
```

- The API exposes REST endpoints under routes like `/api/products`, `/api/categories`, etc.
- Static images are served from `/public/products`, `/public/category`, `/public/posters`.
- Upload flows save files there and return absolute URLs based on `PUBLIC_BASE_URL` (or request host).

Notes

- You can use Docker (`docker-compose.yml`) if you prefer containerized MongoDB.
- If you access from Android emulator, your Flutter app should use `http://10.0.2.2:3000` as a base.

---

## Client App (Customer) — Setup and Run

Folder: `client_side/client_app`

1. Install Flutter deps

```powershell
cd client_side/client_app
flutter pub get
```

2. Configure API base URL

- The app resolves base URL per platform (Android emulator uses `10.0.2.2`).
- Ensure the server is reachable from the device/emulator.

3. Run on Android emulator/device

```powershell
flutter run
```

4. Build a release APK

```powershell
flutter build apk --release
```

- Output: `client_side/client_app/build/app/outputs/flutter-apk/app-release.apk`

Key Features

- Home: Poster carousel, category chips, Featured Products grid
- Product details: gallery, variant selection, add to cart
- Cart: quantity updates, order flow scaffold
- Search & filters: advanced search screen with category/brand filtering
- Profile, Services, Notifications screens

Responsive Grid

- The product grid is responsive by default and increases columns as the screen widens.
- Phone: typically 2 columns; tablets/laptops: 3–8+ columns.

Bottom Bar UX

- On Home, after you scroll past the “Featured Products” header:
  - Scroll down → bottom bar hides
  - Scroll up → bottom bar shows
- When hidden, it frees layout space so products shift up.

Troubleshooting

- Images not loading on Android emulator:
  - Use `10.0.2.2` as the host for the API, and ensure the server returns absolute URLs.
  - If serving over HTTP in dev, ensure Android network security allows cleartext or serve over HTTPS.
- Release build shrinker issues:
  - If R8 stripping breaks 3rd‑party SDKs, add keep rules or disable minify until rules are set.

---

## Admin App — Setup and Run (optional)

Folder: `client_side/admin_app_complt_app`

Steps

```powershell
cd client_side/admin_app_complt_app
flutter pub get
flutter run
```

Use Cases

- Manage categories, brands, products, variants, posters
- Review orders and coupons (where implemented)

---

## Project Anatomy (Flutter Client)

- `lib/main.dart` — app bootstrap, theme, providers
- `lib/services/http_services.dart` — REST calls
- `lib/core/data/data_provider.dart` — central data fetch/state
- `lib/models/*` — DTOs (product, category, user, order, poster, coupon...)
- `lib/screen/*` — organized feature screens
  - `home_screen.dart` — main shell with bottom nav + FAB
  - `product_list_screen/*` — home tab (poster, categories, product grid)
  - `product_details_screen/*` — product page + cart add
  - `product_cart_screen/*` — cart and provider
  - `product_by_category_screen/*` — filtering by category/brand
  - `login_screen/*` — auth (flutter_login)
  - `services/*`, `profile_screen/*`, `notifications_screen/*`
- `lib/widget/*` — reusable UI
  - `masonry_product_grid_view.dart` — responsive product grid
  - `premium_product_card.dart`, `enhanced_product_card*.dart`
  - `modern_filter_bottom_sheet.dart`, `shimmer_effect.dart`
- `lib/utility/*` — theming, colors, small helpers

---

## Project Anatomy (Node API)

- `index.js` — Express app entry
- `routes/*` — modular REST endpoints (products, categories, posters, orders, users, etc.)
- `model/*` — Mongoose schemas
- `public/*` — static files storage for uploaded images
- `uploadFile.js` — multer config for uploads
- `services/*` & `search/*` — optional search integrations and helpers

---

## Extending the System

- Add payment gateways: implement in `routes/payment.js`, create client calls, and record orders.
- Add push notifications: integrate FCM in the client and a server route to send messages.
- Improve search: wire Meilisearch or vector search via `services/` and `search/` modules.
- Analytics: add event logging on client actions (view, add-to-cart, purchase) and dashboards in admin app.

---

## Conventions & Tips

- Use Provider for state; keep network calls in services/providers.
- Keep models in `lib/models` matching server responses.
- For Android emulator, prefer `10.0.2.2` instead of `localhost`.
- Commit image uploads under `server_side/online_store_api/public/` only for demos; otherwise store externally (S3, GCS).

---

## License

Internal project. Add a license file if you intend to distribute.
