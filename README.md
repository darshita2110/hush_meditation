# 🪷 Hush — Meditation App

> A minimal Flutter meditation app. Pick a soundscape, breathe, reflect.

---

## Stack

| | |
|---|---|
| Framework | Flutter 3.x + Dart |
| State | Riverpod (StateNotifier) |
| Storage | Hive |
| Navigation | go_router |
| Audio | just_audio |

---

## Features

- **Explore** — Browse 6 ambient soundscapes with tag + search filtering
- **Player** — Full-screen session with live seek bar, breathing animation, play/pause
- **Journal** — Post-session mood + reflection entry
- **History** — All past sessions with expandable journal entries
- **Dark mode** — Full dark theme throughout

---

## Project Structure

```
lib/
├── config/
│   ├── theme/        app_colors, text_styles, app_theme
│   └── routes/       app_router (go_router)
├── data/
│   ├── models/       ambience, reflection, session
│   └── repositories/ ambience, player
├── features/
│   ├── ambience/     list, detail, card, controller
│   ├── player/       session screen, mini player, controller
│   ├── journal/      reflection screen
│   └── history/      history screen
└── main.dart

assets/
├── data/ambiences.json
├── images/   ← add your .jpg files here
└── audios/   ← add your .mp3 files here
```

---

## Getting Started

### 1. Add assets

Place these files before building (free CC0 audio at [pixabay.com/music](https://pixabay.com/music)):

```
assets/images/  forest.jpg  ocean.jpg  rain.jpg  stream.jpg  garden.jpg  thunder.jpg
assets/audios/  forest.mp3  ocean.mp3  rain.mp3  stream.mp3  garden.mp3  thunder.mp3
```

### 2. Install & run

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### 3. Release APK

```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

---

## Android Requirements

- Android Studio with JBR-21
- AGP `8.3.0` · Gradle `8.4` · Java `17`
- `android/gradle.properties` → `-Xmx3g` heap

---

## Rename from ArvyaX

If you cloned this from the original ArvyaX assignment, run the rename script:

```bash
dart scripts/rename.dart
```

Then update `pubspec.yaml` → `name: hush` and `android/app/src/main/AndroidManifest.xml` → `android:label="Hush"`.

---

## License

MIT