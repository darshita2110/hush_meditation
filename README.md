# 🪷 Hush — Meditation App

> A minimal Flutter meditation app with clean architecture. Pick a soundscape, breathe, reflect, and journal your experience.

---

## Stack

| | |
|---|---|
| Framework | Flutter 3.x + Dart |
| State | Riverpod (StateNotifier) |
| Storage | Hive (local persistence) |
| Navigation | go_router (declarative routing) |
| Audio | just_audio (platform audio) |

---

## Features

- **Explore** — Browse 6 ambient soundscapes with tag + search filtering
- **Player** — Full-screen session with live seek bar, breathing animation, play/pause
- **Journal** — Post-session mood + reflection entry
- **History** — All past sessions with expandable journal entries
- **Dark mode** — Full dark theme throughout
- **Session Persistence** — Resume paused sessions on app restart

---

## How to Run the Project

### 1. Prerequisites

- Flutter 3.10.0+ installed
- Android Studio with JBR-21
- AGP `8.3.0` · Gradle `8.4` · Java `17`
- `android/gradle.properties` set to `-Xmx3g` heap

### 2. Add Assets

Place meditation audio and images before building (free CC0 audio at [pixabay.com/music](https://pixabay.com/music)):

```bash
assets/
├── images/
│   ├── forest.jpg
│   ├── ocean.jpg
│   ├── rain.jpg
│   ├── stream.jpg
│   ├── garden.jpg
│   └── thunder.jpg
└── audios/
    ├── forest.mp3
    ├── ocean.mp3
    ├── rain.mp3
    ├── stream.mp3
    ├── garden.mp3
    └── thunder.mp3
```

### 3. Install & Run

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Generate code (Hive adapters, Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Run on connected device/emulator
flutter run
```

### 4. Build Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Architecture Explanation

### Folder Structure

```
lib/
├── config/
│   ├── theme/
│   │   ├── app_colors.dart       ← Color palette + gradients
│   │   ├── text_styles.dart      ← Typography system
│   │   └── app_theme.dart        ← Light/dark themes
│   └── routes/
│       └── app_router.dart       ← go_router navigation setup
│
├── data/
│   ├── models/
│   │   ├── ambience_model.dart   ← Soundscape data (title, audio path, duration)
│   │   ├── reflection_model.dart ← Journal entry (mood, text, timestamp)
│   │   └── session_model.dart    ← Session state (elapsed time, paused/playing)
│   └── repositories/
│       ├── ambience_repository.dart  ← Load ambiences from JSON
│       ├── player_repository.dart    ← Session persistence (Hive)
│       └── journal_repository.dart   ← Reflection CRUD (Hive)
│
├── features/
│   ├── ambience/
│   │   ├── screens/
│   │   │   ├── ambience_list_screen.dart   ← Discover page
│   │   │   └── ambience_detail_screen.dart ← Soundscape info
│   │   ├── widgets/
│   │   │   └── ambience_card.dart          ← Grid card with image
│   │   └── controllers/
│   │       └── ambience_controller.dart    ← Riverpod providers
│   │
│   ├── player/
│   │   ├── screens/
│   │   │   └── session_player_screen.dart  ← Full-screen player
│   │   ├── widgets/
│   │   │   └─��� mini_player.dart            ← Collapsed player bar
│   │   └── controllers/
│   │       └── player_controller.dart      ← Audio + state logic
│   │
│   ├── journal/
│   │   └── screens/
│   │       └── reflection_screen.dart      ← Post-session journal
│   │
│   └── history/
│       └── screens/
│           └── journal_history_screen.dart ← Past reflections
│
└── main.dart                               ← App entry point
```

### State Management Approach

We use **Riverpod with StateNotifier** for predictable, testable state:

#### Why Riverpod?
- ✅ **Compile-time safety** — No typos in provider names
- ✅ **Dependency injection** — Providers pass dependencies automatically
- ✅ **Reactive updates** — UI rebuilds only when watched state changes
- ✅ **Testability** — Mock providers easily in tests

#### Example: Player Controller

```dart
// Define state
class PlayerState {
  final String? ambienceId;
  final bool isPlaying;
  final int elapsedSeconds;
  // ...
}

// Create notifier
class PlayerNotifier extends StateNotifier<PlayerState> {
  PlayerNotifier(this._repo) : super(const PlayerState.idle());
  
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _audioPlayer.pause();
      state = PlayerState.paused(...);
    } else {
      await _audioPlayer.play();
      state = PlayerState.playing(...);
    }
  }
}

// Expose as provider
final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier(ref.watch(playerRepositoryProvider));
});
```

#### Watch State in UI

```dart
class SessionPlayerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuilds when playerProvider changes
    final playerState = ref.watch(playerProvider);
    
    return FloatingActionButton(
      onPressed: () => ref.read(playerProvider.notifier).togglePlayPause(),
      child: Icon(playerState.isPlaying ? Icons.pause : Icons.play_arrow),
    );
  }
}
```

---

### Data Flow: Repository → Controller → UI

```
┌──────────────────────┐
│   Hive Local DB      │  ← Persistence layer (session, reflections)
└──────────┬───────────┘
           │
┌──────────▼──────────────────┐
│   Repository Layer          │  ← Abstract data sources
│ (player, ambience, journal) │     Hides storage details
└──────────┬──────────────────┘
           │
┌──────────▼──────────────────┐
│   StateNotifier Controller   │  ← Business logic
│ (playerNotifier, etc)       │     Orchestrates repos + audio
└──────────┬──────────────────┘
           │
┌──────────▼──────────────────┐
│   Consumer Widgets (UI)      │  ← Reactive view layer
│ Watches providers & rebuilds │
└─────────────────────────────┘
```

#### Concrete Example: Playing Audio

1. **UI triggers action:**
   ```dart
   ref.read(playerProvider.notifier).togglePlayPause()
   ```

2. **Controller handles it:**
   ```dart
   // PlayerNotifier.togglePlayPause()
   await _audioPlayer.play();
   state = PlayerState.playing(...);  // ← UI watches this
   _persistSession();                 // ← Save to Hive
   ```

3. **Persistence layer:**
   ```dart
   // PlayerRepository.saveSessionState()
   _sessionBox.put('session', sessionModel.toJson());
   ```

4. **UI rebuilds with new state:**
   ```dart
   // Session screen sees isPlaying=true, updates icon
   Icon(Icons.pause)  // ← automatic
   ```

---

## Packages Used & Why

| Package | Version | Why Chosen |
|---------|---------|-----------|
| **flutter_riverpod** | ^2.4.0 | Type-safe state management with dependency injection; no service locators |
| **hive** | ^2.2.3 | Fast, zero-dependency local storage for reflections & session state |
| **just_audio** | ^0.9.31 | Cross-platform audio playback (iOS, Android, Web); supports looping & seeking |
| **go_router** | ^10.0.0 | Declarative, nested routing with deep linking support |
| **intl** | ^0.19.0 | Date formatting for reflection timestamps |
| **uuid** | ^4.0.0 | Unique IDs for reflections without backend |
| **flutter_lints** | ^5.0.0 | Official Flutter style guide enforcement |

### Trade-offs

**Hive vs Firebase:**
- ✅ Chose Hive: Zero external dependency, instant offline access, no login
- ❌ Trade-off: Can't sync across devices

**Riverpod vs GetX:**
- ✅ Chose Riverpod: Type-safe, testing-friendly, no global state
- ❌ Trade-off: Slightly more boilerplate than GetX

**just_audio vs Flutter Sound:**
- ✅ Chose just_audio: Lighter, faster, better maintained
- ❌ Trade-off: Less editing features (but we don't need them)

---

## What Would Be Improved With 2 More Days

### 1. **Audio Synchronization Bug Fixes** (1 day)
- Currently: Play/pause button can lag on Android due to `just_audio.playing` getter timing
- **Fix:** Implement audio state queue to sync UI + audio perfectly
- **Impact:** Seamless play/pause experience across all platforms

### 2. **Multi-Language Support i18n** (0.5 days)
- Add `flutter_localizations` + `intl_utils`
- Support English, Spanish, Hindi for global audience
- **Impact:** 10x larger potential user base

### 3. **Session Recommendations** (0.5 days)
- Analyze user reflections (mood trends) using basic NLP
- Suggest best ambiences based on historical moods
- Example: "You feel calm after ocean sounds — try it today?"
- **Impact:** Better user retention & personalization

### 4. **Cloud Sync (Optional)** (1 day)
- Add Firebase or Supabase integration
- Backup reflections across devices
- **Impact:** Data safety + device independence

### 5. **Analytics** (0.5 days)
- Track: Session frequency, most-used sounds, journal completion rate
- **Impact:** Understand user behavior, improve features

---

## Project Structure Rationale

**Clean Architecture Layers:**
- **Config:** Isolated theme/routing (easy theme switching)
- **Data:** Repositories abstract storage (swap Hive→Firebase easily)
- **Features:** Feature folders (modular, easy to remove/test)

**Why This Works:**
- New developer can find code quickly
- Easy to test in isolation (mock repositories)
- Features don't depend on each other
- Zero circular dependencies

---

## License

MIT