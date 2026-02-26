import 'package:flutter/material.dart';

import 'game_engine/game/game_controller.dart';
import 'game_engine/game/game_state.dart';
import 'game_engine/models/board.dart';
import 'game_engine/models/level_template.dart';
import 'game_engine/rules/randomizer.dart';
import 'presentation/screens/game_screen.dart';

void main() {
  runApp(const ExplosiveTetrisApp());
}

class ExplosiveTetrisApp extends StatelessWidget {
  const ExplosiveTetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explosive Tetris',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GameScreenWrapper(),
    );
  }
}

class GameScreenWrapper extends StatelessWidget {
  const GameScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize game state
    final initialState = GameState(
      board: Board(defaultLevel.boardWidth, defaultLevel.boardHeight),
      fallingPiece: null,
      phase: GamePhase.spawning,
      generator: SevenBagGenerator(),
      level: defaultLevel,
    );

    final controller = GameController(
      initialState: initialState,
      gravityInterval: 1,
    );

    return GameScreen(controller: controller);
  }
}