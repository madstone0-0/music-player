# Music Player

A Flutter-based offline-first music player focused on local audio playback and local library management.

## Overview

This project provides a complete local music experience with support for:

- Local audio file browsing and playback
- Background playback
- Playlist creation and management
- Song tagging
- Play history tracking
- Lyrics fetching for supported tracks

---

## Features

### Audio Playback
- Play/Pause
- Seek
- Next/Previous controls
- Queue-based playback

### Local Resource Support
- Local file storage access
- Offline playback
- Local metadata persistence
- Background playback support

### Library Management
- Playlist creation and editing
- Add/remove songs from playlists
- Song tagging for custom organization
- Play history logging

### Lyrics
- Lyrics fetching for supported songs/tracks using lrclib

---

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **State management / utility:** GetX (`get`), `get_it`
- **Audio:** `just_audio`, `just_audio_background`
- **Database:** `drift`, `drift_flutter`
- **Metadata:** `audiotags`
- **Networking:** `dio`, `retrofit`, `json_annotation`
- **Permissions:** `permission_handler`
- **Device info:** `device_info_plus`

---

## Project Structure

```text
lib/
  common/      # shared components/helpers
  db/          # local database layer
  intents/     # intent/navigation related logic
  models/      # data models
  screens/     # UI screens
  services/    # playback/business/network services
  utils/       # utilities
  main.dart    # app entry point
```

---

## Getting Started

### Prerequisites
- Flutter SDK (matching project constraints)
- Dart SDK
- Android Studio or VS Code
- Android device/emulator

### Install Dependencies
```bash
flutter pub get
```

### Run the App
```bash
flutter run
```

### Build APK
```bash
flutter build apk
```

---

## Permissions

The app requires media/storage-related permissions on Android to read local audio files.  
Please allow permissions when prompted, otherwise local music browsing/playback will not work.

---

