# SignKo Development Runbook

This guide contains the essential commands and troubleshooting steps for developing the SignKo app locally.

## How to Do a "Clean Boot"
If your app starts acting weird, lagging heavily, or throwing network errors, follow these steps to wipe the state and start fresh:

1. **Stop Everything**
   - Press `q` in your Flutter terminal (or hit Stop in your IDE).
   - Stop the backend by running: `docker compose down`
   - **Crucial:** Close your Edge/Chrome browser tab. (Flutter Web CanvasKit leaks RAM heavily if you just keep Hot Restarting without ever closing the tab).

2. **Start the Backend**
   ```bash
   docker compose up -d
   ```

3. **(Optional) Seed the Database**
   Since the database volume persists, you usually only need to run this once. If you wiped your volumes, run this to recreate the default `dev@signko.com` (password: `password`) user:
   ```bash
   docker compose exec backend python app/scripts/seed_user.py
   ```

4. **Launch the Flutter Frontend**
   Clean the build cache and launch the app:
   ```bash
   cd app
   flutter clean
   flutter run -d edge
   ```

## Known Quirks & Fixes

### 1. Flutter Web / Edge Memory Leaks
- **Issue:** Your RAM shoots up to 99% (e.g., 7.7GB).
- **Cause:** Hot Restarting the Flutter Web app repeatedly causes the browser to stack WebGL contexts and WASM heaps without garbage collecting them.
- **Fix:** Hard refresh the page (`Ctrl + F5`) or close the browser tab completely and reopen it.

### 2. Network Errors on Android Emulator
- **Issue:** `net::ERR_CONNECTION_REFUSED` when trying to log in.
- **Cause:** Android Emulators map `127.0.0.1` to the virtual phone itself, not your PC's localhost.
- **Fix:** We updated `ApiService` to automatically detect this and route Android Emulators to `10.0.2.2:8000`.

### 3. Double Password Eye / White Flashing
- **Issue:** A second black eye icon appears in the password field, and navigating between pages flashes bright white.
- **Cause:** Edge automatically injects its own password reveal icon over Flutter's. Flutter Web also takes a millisecond to paint the WebGL canvas on heavy transitions, exposing the native white `<body>` behind it.
- **Fix:** We injected CSS into `app/web/index.html` to hide the native Edge icon and set the `<body>` background color to Slate 900. 

### 4. Tab Switching Lag
- **Issue:** Switching tabs on the Dashboard causes the UI to freeze or stutter.
- **Cause:** Rebuilding heavy widgets (like `TranslationView`) from scratch triggers "Shader Compilation Jank" and TTS collisions on Web.
- **Fix:** We wrapped the Dashboard tabs in an `IndexedStack` (in `dashboard_view.dart`) so they stay alive in memory.
