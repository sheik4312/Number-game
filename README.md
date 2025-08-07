# Number Match Game

![Game Screenshot](screenshots/gameplay.gif) <!-- Replace with actual GIF -->  

A challenging puzzle game where players match number tiles based on intuitive number rules. Built with **Flutter** and **Riverpod**, it offers a clean architecture and engaging gameplay across multiple levels.

---

## 🎮 Features

- ✅ Three levels of increasing difficulty
- ⏱️ 2-minute timer per level
- 🔓 Level unlocking and progression
- 🎨 Animated tile interactions
- 🎯 Responsive UI for all screen sizes and orientations
- 🔁 "Add Row" and level reset functionality

---

## 🚀 Setup Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0)
- Dart SDK (>= 2.17.0)

### Installation

```bash
git clone https://github.com/your-username/number-match-game.git
cd number-match-game
flutter pub get
flutter run
```

---

## 🧠 Game Rules

### 🎲 Matching Logic

Match two tiles that are either:
- Equal in value (e.g., 4 and 4)
- Sum to 10 (e.g., 6 and 4)

### 🔁 Valid Match Directions
- Horizontal (same row)
- Vertical (same column)
- Diagonal (same step count on x and y)
- L-shapes and Wraps (if implemented)

### ✅ Path Requirements
- All intermediate tiles between matched tiles must be **cleared/faded**
- No obstructions allowed in the path

---

## 🧱 Level Structure

| Level | Rows | Tiles | Complexity |
|-------|------|-------|------------|
| 1     | 2    | 18    | Basic pairs (1–9) |
| 2     | 3    | 27    | Mix of numbers |
| 3     | 4    | 36    | Randomized, strategic thinking required |

Each level has a **2-minute timer**. When time expires, the level restarts. Match and clear all tiles to unlock the next level.

---

## 📁 Project Structure

```txt
lib/
├── controllers/
│   └── game_controller.dart          # Main game logic and state updates
│
├── models/
│   └── game_tile.dart                # Tile data structure and properties
│
├── providers/                        # Riverpod state providers
│   ├── game_providers.dart
│   ├── home_providers.dart
│   ├── level_providers.dart
│   ├── splash_providers.dart
│   └── timer_provider.dart
│
├── screen/                           # App screens
│   ├── gamescreen.dart
│   ├── home_screen.dart
│   └── splash_screen.dart
│
├── widgets/
│   ├── game/
│   │   ├── tile/
│   │   │   ├── tile_animations.dart  # Tile animation effects
│   │   │   ├── tile_content.dart     # Tile UI content
│   │   │   └── tile_widget.dart      # Interactive tile widget
│   │   ├── add_row_button.dart       # Button to add new row
│   │   ├── game_grid.dart            # Tile grid layout
│   │   ├── level_progress.dart       # Visual level progress display
│   │   └── level_selector.dart       # Widget to choose levels
│   │
│   ├── home/
│   │   ├── animated_button.dart      # Animated UI button
│   │   ├── animated_logo.dart        # Splash/home logo animations
│   │   └── instruction_row.dart      # Row of gameplay instructions
│   │
│   └── splash/
│       ├── splash_content.dart       # Splash screen content layout
│       └── splash_logo.dart          # Splash screen logo animation
│
└── main.dart                         # Entry point of the Flutter app
```txt
lib/
├── controllers/        # State management logic (GameController)
│   └── game_controller.dart
│
├── models/             # Tile data model
│   └── game_tile.dart
│
├── providers/          # Riverpod providers
│   ├── game_providers.dart
│   ├── level_providers.dart
│   ├── splash_providers.dart
│   └── timer_provider.dart
│
├── services/           # For future business logic separation
│   └── (optional)
│
├── widgets/            # Reusable UI components
│   ├── game/
│   │   ├── grid/
│   │   ├── tile/
│   │   └── timer_display.dart
│   ├── home/
│   └── splash/
│
└── views/              # Main screen layouts
    ├── game_screen.dart
    ├── home_screen.dart
    └── splash_screen.dart
```


---

## ⏹️ Controls

- Tap tiles to select/unselect
- Tap the ✅ second tile to validate match
- "➕ Add Row" adds a new row of tiles
- "🔁 Refresh" restarts current level
- Level selector for navigating unlocked levels

---

## 📦 Dependencies

- `flutter_riverpod`: State management
- `flutter_animate`: Animation support
- `google_fonts`: Beautiful fonts (optional)
- `flutter_hooks`: Hook-based widget management (optional)

---

## 📷 Screenshots

Create a `screenshots/` folder and add:

- `gameplay.gif` (main screen recording)
- `home-screen.png`
- `level-select.png`

---

## 🤝 Contributing

Contributions are welcome!  
Feel free to fork the repo, create a branch, and submit pull requests.  
Before contributing, please open an issue to discuss major changes.

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

> Designed with ❤️ using Flutter.
