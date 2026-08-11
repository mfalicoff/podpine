# Podpine

Podpine is an offline-first Flutter client for a self-hosted [Pinepods](https://www.pinepods.online/) server. Pinepods is the source of truth; Podpine keeps a local SQLite snapshot so the library, queue, and playback state remain useful when the server is unavailable.

## Current slice

- iOS, Android, and web Flutter projects
- Pinepods server and API-key onboarding
- API-key verification and user discovery
- Subscription, episode, and queue pulls from Pinepods
- SQLite-backed offline library with a durable mutation outbox
- Played/unplayed and queue mutations with retry on the next refresh
- Pinepods-backed discovery with Podcast Index and iTunes providers
- Rich, cached podcast and episode detail views before and after subscription
- Optimistic subscribe/unsubscribe with offline retry
- Responsive Home, Library, Queue, and Search views
- Persistent new-episode Inbox with triage actions and configurable swipes
- Persistent mini-player and full player with background audio
- Lock-screen, notification, Bluetooth, and headset media controls
- Seek, skip intervals, playback speed, and periodic position persistence
- Secure credential storage
- Demo library for development and product review

The player integrates `just_audio` through `audio_service`, including queue-aware previous/next controls, server-backed queue reordering, and active-episode artwork and metadata. Production downloads, automatic-download rules, and background refresh scheduling remain follow-up work. See [Architecture](docs/ARCHITECTURE.md) and [Background audio](docs/BACKGROUND_AUDIO.md).

## Run it

Requirements:

- Flutter 3.44 or newer
- Android Studio and an Android SDK for Android builds
- Full Xcode plus CocoaPods for iOS builds

```sh
flutter pub get
dart run build_runner build
flutter run
```

For the web:

```sh
flutter run -d chrome
```

The checked-in `web/sqlite3.wasm` and `web/drift_worker.js` files provide Drift's browser database runtime.

## Connect Pinepods

Create an API key in the Pinepods web application's settings, then enter the server origin (for example, `https://podcasts.example.com`) and that key in Podpine. The client verifies `/api/pinepods_check`, validates the key, resolves the associated user, and downloads the first local snapshot.

Self-hosted servers used from the web build must allow the web app's origin through their CORS configuration. Native iOS and Android builds are not subject to browser CORS.

## Verify

```sh
flutter analyze
flutter test
flutter build web --release
```

The generated Drift bindings in `lib/core/database/app_database.g.dart` are committed so a fresh checkout can analyze immediately. Regenerate them after changing a table definition.
