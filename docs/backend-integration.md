# Yaku mobile backend integration

The Android app uses the existing FastAPI service in
`C:\Users\LOQ\OneDrive\Desktop\Extention\yaku\backend`. It does not create a
second database and it does not invoke browser automation. The Chrome extension
remains responsible for running cancellation playbooks.

## API configuration

The API base URL is supplied at build/run time; no production URL is committed:

```powershell
flutter run --dart-define=YAKU_API_BASE_URL=https://api.example.com/api/v1/
```

Keep the trailing slash. For a FastAPI server on the development laptop, use the
laptop's reachable LAN address, not `localhost` from the phone:

```powershell
cd C:\Users\LOQ\OneDrive\Desktop\Extention\yaku\backend
$env:YAKU_CORS_ORIGINS='http://localhost:5173'
python -m uvicorn yaku_api.main:app --host 0.0.0.0 --port 8000
```

Then run Flutter with the laptop address:

```powershell
flutter run --dart-define=YAKU_API_BASE_URL=http://192.168.1.20:8000/api/v1/
```

Replace `192.168.1.20` with the laptop's LAN IPv4 address. The phone and laptop
must be on the same reachable network, and Windows Firewall must allow inbound TCP
8000 for the chosen network profile. The debug Android manifest permits cleartext
HTTP only for this local-development case; production traffic must use HTTPS.

## Existing endpoints reused

All paths below are under `/api/v1` and require `Authorization: Bearer <access>`
unless stated otherwise.

- `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh`, and
  `POST /auth/logout` — password auth and rotating token sessions.
- `GET /me` and `PATCH /me` — profile and the existing `theme` preference.
- `GET /subscriptions` — current-user-owned subscription list.
- `GET /subscriptions/summary` — per-currency monthly spend, upcoming charges,
  and trial countdowns.
- `POST /subscriptions` and `PATCH /subscriptions/{id}` — supported manual create
  and edit operations; the app currently exposes manual creation and refreshes data.
- `GET /cancellation-attempts` — real cancellation workflow history. The app does
  not claim a provider cancellation and points users to the Chrome extension.
- `GET /notification-rules` and related routes exist server-side, but the mobile
  settings screen does not pretend a local switch delivers notifications. Backend
  alert rules remain entitlement- and dashboard-managed.

No backend endpoint or migration was added for this milestone. Ownership remains
server-enforced through the existing bearer-token dependency.

## Security and failure behavior

Access and refresh tokens are stored with `flutter_secure_storage`, never ordinary
preferences. The reusable HTTP client has a 15-second timeout, parses the backend's
`{"error":{"code","message"}}` envelope, and reports network, auth, and malformed
response failures separately. A 401 attempts the backend's refresh flow; failure
clears local credentials. Search is local over the server response. Empty, loading,
retry, and pull-to-refresh states are provided on API-driven screens.

For production, set a real `YAKU_JWT_SECRET`, `YAKU_HASH_PEPPER`, encryption keys,
PostgreSQL URL, and HTTPS reverse proxy in the backend environment. Do not commit
`.env` files, tokens, or private keys.
