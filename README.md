# Number Match Puzzle Game

A Flutter-based **Number Match** puzzle game with unlimited progressive levels, smooth animations, and an attractive UI.  
Match numbers according to the rules to clear tiles, progress to higher levels, and beat the timer.

---

## 📱 Features
- ♾ **Unlimited Levels** — levels keep getting harder with more rows
- ⏱ **2-minute timer** for each level
- 🧩 **Matching rules**: Match tiles with the same value or tiles whose sum is **10**
- 🌟 **Path Validation**: Only tiles with a clear path through matched (faded) cells are valid
- ✨ Smooth animations, glowing effects, and sound feedback
- 📈 Progressive difficulty with increasing grid size

---

## 🛠 Setup Steps

### 1️⃣ Prerequisites
Make sure you have installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Stable channel)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- Dart SDK (comes with Flutter)
- A physical device or emulator

### 2️⃣ Clone the Repository
```bash
git clone https://github.com/sheik4312/Number-game.git
cd number-match-game
```

### 3️⃣ Install Dependencies
```bash
flutter pub get
```

### 4️⃣ Run the Game
```bash
flutter run
```

---

## 🎮 Level Structure
- **Unlimited levels** — start from 3 rows and increase by 1 row per 5 level.
- complexity increase with each level.
- Levels unlock automatically after completion.

| Level | Rows | Difficulty       |
|-------|------|------------------|
| 1     | 2    | Beginner         |
| 2     | 3    | Easy             |
| 3     | 4    | Moderate         |
| ...   | +1   | Continues upward |

---

## 🧮 Game Rules
1. **Tile Matching**
   - Two tiles match if:
     - They have **the same value**, **OR**
     - Their values sum to **10**.
2. **Path Rule**
   - A valid match must have a clear path:
     - Can be straight, diagonal, or L-shaped.
     - Intermediate tiles along the path must already be **matched** (faded).
3. **Tile Indexing**
   - Tiles are indexed **top-to-bottom, column-wise** for easier path calculations.
4. **Completion**
   - Match all tiles in the grid to clear the level.
5. **Timer**
   - You have **2 minutes** to complete each level.

---

## 🏗 Architecture

### 📂 Folder Structure
```
lib/
 ├── controllers/
 │    └── game_controller.dart       # Manages game logic and level progression
 ├── models/
 │    └── game_tile.dart              # Data model for tiles
 ├── providers/
 │    ├── game_providers.dart
 │    ├── home_providers.dart
 │    ├── level_providers.dart
 │    ├── splash_providers.dart
 │    └── timer_provider.dart
 ├── screen/
 │    ├── gamescreen.dart
 │    ├── home_screen.dart
 │    └── splash_screen.dart
 ├── widgets/
 │    ├── game/
 │    │    ├── tile/
 │    │    │    ├── tile_animations.dart
 │    │    │    ├── tile_content.dart
 │    │    │    └── tile_widget.dart
 │    │    └── game_grid.dart
 │    ├── home/
 │    │    ├── animated_button.dart
 │    │    ├── animated_logo.dart
 │    │    └── instruction_row.dart
 │    └── splash/
 │         ├── splash_content.dart
 │         └── splash_logo.dart
 └── main.dart
```

### 🛠 State Management
- **Riverpod** is used for:
  - Game state (`gameControllerProvider`)
  - Timer
  - Level progression
  - UI selection states

---

## 💡 How It Works
1. **Start Game** → Tiles generated for the current level.
2. **Player Action** → Tap a tile → Select → Tap another tile.
3. **Validation** → Check matching rules + path rules.
4. **Feedback**
   - ✅ Valid match → Tiles fade
   - ❌ Invalid match → Shake animation
5. **Progression**
   - If grid is cleared → Next level starts automatically.

---

## 📷 Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/b177abdb-85d0-478d-b40c-015f9266c2f6" width="250" />
  <img src="https://github.com/user-attachments/assets/b6afb757-4c12-49c1-980d-e366a052b7d3" width="250" />
  <img src="https://github.com/user-attachments/assets/713d49f9-c1e7-4e3d-bddb-f6e9cf3fbcd9" width="250" />
</p>
Demo Video

https://github.com/user-attachments/assets/07174f11-1fd4-440f-afe9-31ca95ab3417


---

