# Explosive Tetris

This project was developed entirely with the help of an LLM and codinig agent.

A unique Tetris variant with explosive mechanics and target-based victory conditions, built with Flutter.

## Overview

Explosive Tetris (MVP) is a specialized Tetris prototype where the goal is not just to clear lines, but to fill a specific **Target Mask (S)** while keeping the surrounding **Halo (H)** clear. Players can strategically arm their pieces to become "Explosive," allowing them to pass through existing blocks and detonate to clear specific areas.

### Key Features
- **Explosive Mode:** Arm a piece once per turn to go through blocks and explode on impact or command.
- **Target Mechanics:** Win by filling a 6×6 cross-shaped target at the bottom of the field.
- **Halo Rule:** Victory requires the cells immediately adjacent to the target to be empty.
- **Limited Columnar Gravity:** After an explosion, only blocks above the removed cells shift down.

## Tech Stack
- **Language:** Dart
- **Framework:** Flutter
- **Platform Support:** Android, iOS (standard Flutter targets)
- **Package Manager:** `pub`
- **Randomizer:** 7-bag generator for tetrominoes.

## Requirements
- **Flutter SDK:** `^3.10.4` (as specified in `pubspec.yaml`)
- **Dart SDK:** compatible with the specified Flutter version.

## Setup & Run

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd Tetris-ex-project/explosive_tetris
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    ```bash
    flutter run
    ```

## Project Structure

```text
lib/
├── application/         # App logic and game loop
│   └── game_loop.dart   # Ticker/AnimationController integration
├── game_engine/         # Pure Dart game logic (no Flutter dependencies)
│   ├── game/            # Game state and controller
│   ├── models/          # Data models (Board, Piece, LevelTemplate, etc.)
│   └── rules/           # Game rules (Collision, Explosion, Rotation, etc.)
├── presentation/        # UI layer
│   ├── screens/         # Main game screen
│   └── widgets/         # Custom painters and HUD elements
└── main.dart            # Entry point
```

## Scripts & Testing

### Running Tests
The project uses `flutter_test` for unit and widget testing.

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/game_engine/rules/collision_test.dart
```

### Core Scripts
Standard Flutter CLI commands are used:
- `flutter analyze`: Static analysis for the project.
- `flutter build <platform>`: Build the app for a specific platform (e.g., `apk`, `ios`).

## Core Mechanics (MVP)

- **Board Size:** 10×20
- **Target Window:** 6×6 cross (MSB-first hex: `0x30CFFF30C`) anchored at `(2, 14)`.
- **Halo:** 8-neighborhood surrounding the target.
- **Piece Rotation:** Clockwise (CW) only, no wall kicks (SRS is post-MVP).
- **Detonation:** Manual or automatic upon hitting the bottom boundary in Explosive mode.

## Env Vars
- No custom environment variables are currently used by the MVP.

## TODOs / Roadmap
- [ ] Implement CCW rotation.
- [ ] Add Wall kicks (SRS).
- [ ] Implement soft drop vs. hard drop.
- [ ] Add explosion and gravity animations.
- [ ] Implement move limits per level.
- [ ] Add sound effects.

## License
TODO: Add license information.
