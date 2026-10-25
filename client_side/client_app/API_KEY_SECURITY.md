# API Key Security

## Status

Two Google API keys (an old Google Maps key and a Gemini key) and a MongoDB
Atlas connection string were committed to this repository in the past. They
have been scrubbed from the entire git history, and the exposed credentials are
revoked: the two Google keys are deleted in Google Cloud and the Atlas user's
password is rotated. Do not try to reuse anything from old forks or clones.

No key is printed in this repository's documentation, and none should be.

## How keys are provided now

### Gemini (`GEMINI_API_KEY`)

`lib/services/gemini_ai_service.dart` reads the key at runtime, in this order:

1. `.env` in `client_side/client_app/` (loaded by `flutter_dotenv`; `.env` is
   git-ignored). Copy `.env.example` to `.env` and fill it in:

   ```env
   GEMINI_API_KEY=your_gemini_key_here
   ```

2. A build-time define:

   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your_gemini_key_here
   ```

If neither is set, the Gemini service throws a clear error instead of using a
baked-in key.

### Google Maps (Android)

The Maps SDK for Android reads its key from the `com.google.android.geo.API_KEY`
meta-data in `android/app/src/main/AndroidManifest.xml`. A Maps key always ships
inside the app binary, so it is protected by restrictions rather than by being
hidden. The current key must be restricted in Google Cloud Console
(APIs & Services > Credentials):

- **Application restriction:** Android apps, package `com.example.client_app`
  plus the SHA-1 fingerprint of each signing certificate (debug and release).
- **API restriction:** only Maps SDK for Android (and Geocoding / Places if the
  app uses them).

### Server (MongoDB and others)

The API in `server_side/online_store_api` reads `MONGO_URL`, `JWT_SECRET` and
the rest from environment variables (see `.env.example` there). Set them in the
hosting dashboard (Render) or a local, git-ignored `.env`.

## Preventing a repeat

- Keep real values only in `.env` files (git-ignored) or hosting secrets.
- Enable GitHub secret scanning and push protection
  (Settings > Code security).
- Optional pre-commit hook (`.git/hooks/pre-commit`, make it executable):

  ```bash
  #!/bin/sh
  if git diff --cached | grep -E "AIza[0-9A-Za-z_-]{35}|mongodb\+srv://[^:]+:[^@]+@"; then
      echo "Possible secret in commit. Use environment variables instead."
      exit 1
  fi
  ```

If a key leaks again: revoke it first, then remove it from the code.
