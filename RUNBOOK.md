# SignKo Development Runbook

This guide contains the essential commands and troubleshooting steps for developing the SignKo app locally.

## How to Do a "Clean Boot"

If your app starts acting weird, lagging heavily, or throwing network errors, follow these steps to wipe the state and start fresh:

1. **Stop Everything**
   - Press `q` in your Flutter terminal (or hit Stop in your IDE).
   - Stop the backend by running: `.\stop_all.ps1`
   - **Crucial:** Close your Edge/Chrome browser tab. (Flutter Web CanvasKit leaks RAM heavily if you just keep Hot Restarting without ever closing the tab).

2. **Start the Environment**
   Run the automated start script to boot the Docker backend, clean the Flutter cache, and launch the app:

   ```bash
   .\start_all.ps1
   ```

3. **(Optional) Seed the Database**
   Since the database volume persists, you usually only need to run this once. If you wiped your volumes, run this to recreate the default user and dictionary:

   ```bash
   .\seed_db.ps1
   ```

## Git Workflow & Updating Local Repository

### Branch Strategy

- **`main`**: Production and release-ready code. Never commit directly to `main`.
- **`dev`**: Primary active integration branch. All developers base their work and feature branches here.
- **`feat/*` or `fix/*`**: Temporary feature and bugfix branches cut from `dev`.

### 1. Daily Sync (Updating Your Local `dev`)

Before starting any new work or creating a new branch, always synchronize your local machine with remote changes:

```bash
# 1. Switch to dev branch
git checkout dev

# 2. Pull the latest commits from GitHub
git pull origin dev
```

If you have uncommitted local changes that you want to preserve while pulling:

```bash
# Temporarily stash your local changes
git stash

# Pull the latest remote updates
git pull origin dev

# Re-apply your changes on top of latest code
git stash pop
```

### 2. Feature Development Workflow

```bash
# 1. Ensure dev is up-to-date
git checkout dev
git pull origin dev

# 2. Create your feature branch
git checkout -b feat/your-feature-name

# 3. Make changes and commit using Conventional Commits
git add .
git commit -m "feat: implement feature description"

# 4. Push your branch to GitHub
git push -u origin feat/your-feature-name
```

### 3. Syncing Your Active Feature Branch with Remote `dev`

If `dev` was updated by team members while you were working on your feature branch:

```bash
# Fetch latest remote references
git fetch origin

# Merge latest dev changes into your feature branch
git merge origin/dev
```

### 4. Merging into `dev` and Releasing to `main`

```bash
# 1. Merge feature branch to dev
git checkout dev
git pull origin dev
git merge feat/your-feature-name
git push origin dev

# 2. Release dev to main (when ready for a verified stable release)
git checkout main
git pull origin main
git merge dev
git push origin main
git checkout dev
```

### 5. Common Git Issues & Quick Fixes

#### Issue: Flutter Generated Files Block `git checkout` or `git pull`

Flutter builds often modify platform registrant files (e.g. `app/windows/flutter/generated_plugin_registrant.cc`, `generated_plugins.cmake`).
**Fix:** Discard modifications in generated folders before pulling:

```bash
git restore app/windows/flutter/ app/linux/flutter/ app/macos/Flutter/
```

#### Issue: After Pulling, Code Crashes or Fails to Build

When dependencies or database schemas are updated:

```powershell
# 1. If Flutter packages changed
cd app
flutter pub get
cd ..

# 2. If Backend models, endpoints, or requirements changed
docker compose restart backend

# 3. If Dictionary mappings or database seeds were updated
.\seed_db.ps1
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
