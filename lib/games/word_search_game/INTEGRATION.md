# 🔍 Word Search Game — GameHub Integration Guide

## 📁 Folder Structure

Copy the `word_search` folder into:
```
lib/games/word_search/
```

Final path layout:
```
lib/
└── games/
    └── word_search/
        ├── word_search_entry.dart        ← Entry point (use this in GameHub)
        ├── models/
        │   ├── level_model.dart
        │   └── game_state.dart
        ├── data/
        │   └── levels_data.dart
        ├── services/
        │   ├── grid_generator.dart
        │   ├── ws_storage_service.dart
        │   └── ws_game_provider.dart
        ├── utils/
        │   └── ws_theme.dart
        ├── widgets/
        │   ├── ws_grid_cell.dart
        │   ├── ws_word_grid.dart
        │   └── ws_word_list.dart
        └── screens/
            ├── ws_home_screen.dart
            ├── ws_level_select_screen.dart
            ├── ws_game_screen.dart
            └── ws_level_complete_screen.dart
```

---

## 🔧 Step 1 — pubspec.yaml

Add these to your existing `pubspec.yaml` dependencies:

```yaml
dependencies:
  shared_preferences: ^2.2.2   # for saving progress
  confetti: ^0.7.0             # for win celebration
  flutter_animate: ^4.3.0      # for animations (optional)
```

Then run:
```bash
flutter pub get
```

---

## 🔧 Step 2 — GameHubScreen

In your `game_hub_screen.dart`, add this import at the top:

```dart
import 'package:games_hub/games/word_search/word_search_entry.dart';
```

Then add a new `gameItem` inside your GridView:

```dart
gameItem(
  Image.asset("assets/images/addon.png"),   // or any icon you have
  "Word Search",
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WordSearchEntry(),
      ),
    );
  },
),
```

---

## ✅ That's it!

No changes needed to `main.dart` or any other file.  
The game handles its own Provider, storage init, and navigation internally.

---

## 🎮 Features Included

| Feature | Status |
|---|---|
| 15 levels, 5 themes | ✅ |
| Easy / Medium / Hard grids | ✅ |
| Swipe word selection | ✅ |
| Word highlight with colors | ✅ |
| Hint system | ✅ |
| Timer + Score | ✅ |
| Level unlock progression | ✅ |
| Daily Challenge | ✅ |
| Level Complete + Stars | ✅ |
| Pause / Resume / Restart | ✅ |
| Offline progress saving | ✅ |
| Dark theme (matches GameHub) | ✅ |
