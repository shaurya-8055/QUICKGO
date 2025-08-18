# admin_app_complt_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Service Requests – Admin Backend Handoff

Base URL: `MAIN_URL` from `lib/utility/constants.dart` (default `http://localhost:3000`).

- POST `/service-requests`

  - Body: `{ userID?, category, customerName, phone, address, description?, preferredDate, preferredTime, status: 'pending' }`
  - Response: `{ success: boolean, message: string, data?: { id, ...payload } }`

- GET `/service-requests?status=pending|approved|in-progress|completed|cancelled`

  - Returns list (pagination recommended)

- PATCH `/service-requests/:id`

  - Body: `{ status: 'approved'|'in-progress'|'completed'|'cancelled', assigneeId?, notes? }`
  - Response: `{ success, message }`

- DELETE `/service-requests/:id` (optional)
  - Response: `{ success, message }`

Schema (minimal):

```
id, userID?, category, customerName, phone, address, description?,
preferredDate (datetime), preferredTime (string),
status (pending|approved|in-progress|completed|cancelled),
assigneeId?, notes?, createdAt, updatedAt
```

Client wiring in this repo:

### Extended backend handoff (technicians, filters, rate limiting)

Collections:
- service_requests: id, userID, category, customerName, phone, address, description, preferredDate, preferredTime, status, assigneeId, assigneeName, assigneePhone, createdAt, updatedAt
- technicians: id, name, phone, skills[], active

Endpoints:
- POST /service-requests → validate, create with status 'pending'; return { success, message, data }
- GET /service-requests?userID=&status=&from=&to=&page=&limit= → filtered, paginated list
- PATCH /service-requests/:id → update status/assignee fields; optional push/email/SMS on status change
- DELETE /service-requests/:id → cleanup (optional)
- Technicians: GET /technicians (skills filter), POST/PATCH for CRUD

Notes:
- Rate limit per IP+phone (e.g., 1/min) and dedupe identical payload in 10s to avoid spam/duplicates.
- On successful booking, this app also adds a local in-app notification (OneSignal integration can be added on backend status updates).

- Provider: `lib/screens/service_requests/provider/service_provider.dart`
  - `createServiceRequest(...)` → `Future<(bool, String)>`
- Registered in `lib/main.dart` via `ChangeNotifierProvider`
- Access via `context.serviceProvider`
