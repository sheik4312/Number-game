# Number Match Game

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
Step 1: Clone the repository

git clone https://github.com/sheik4312/number-game.git

Step 2: Navigate into the project directory

cd number-game

Step 3: Install dependencies and run the app

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

<div align="center">
  <img src="https://github.com/user-attachments/assets/2760f993-e9fe-457c-8bb2-a64365182bd4" width="250"/>
  <img src="https://github.com/user-attachments/assets/a1786711-eded-4217-9280-ced892eddbf7" width="250"/>
  <img src="https://github.com/user-attachments/assets/ca7d5f2e-b5bc-4d08-8c0f-9690131bb5fa" width="250"/>
</div>

---

## 🤝 Contributing

Contributions are welcome!  
Feel free to fork the repo, create a branch, and submit pull requests.  
Before contributing, please open an issue to discuss major changes.

---


https://github.com/user-attachments/assets/7ade4591-208e-4d33-9e12-4119863b588f


> Designed with ❤️ using Flutter.
