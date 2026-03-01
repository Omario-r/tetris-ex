import 'package:flutter/material.dart';

import '../../game_engine/game/game_controller.dart';
import '../../game_engine/game/game_state.dart';
import '../../game_engine/models/board.dart';
import '../../game_engine/rules/randomizer.dart';
import '../../game_engine/data/level_map.dart';
import '../../application/progress_service.dart';
import '../widgets/board_painter.dart';
import 'level_complete_screen.dart';
import 'object_complete_screen.dart';

/// The main game screen widget that displays the Tetris game.
///
/// Uses [TickerProviderStateMixin] to drive the game loop via an
/// [AnimationController] at approximately 60fps.
class GameScreen extends StatefulWidget {
  /// The level index to load (0..15). Defaults to 0.
  final int levelIndex;

  /// Creates a [GameScreen] with the given [levelIndex].
  const GameScreen({super.key, this.levelIndex = 0});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final GameController _controller;
  late double _lastTime;
  static const double _cellSize = 28.0;
  bool _winHandled = false;

  @override
  void initState() {
    super.initState();
    _lastTime = 0.0;
    _winHandled = false;

    // Load level from LevelMap
    final level = LevelMap.levelAt(widget.levelIndex);

    // Initialize game state
    final initialState = GameState(
      board: Board(level.boardWidth, level.boardHeight),
      fallingPiece: null,
      phase: GamePhase.spawning,
      generator: SevenBagGenerator(),
      level: level,
    );

    _controller = GameController(
      initialState: initialState,
      gravityInterval: 1,
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();
    _animController.addListener(_onTick);
  }

  @override
  void dispose() {
    _animController.removeListener(_onTick);
    _animController.dispose();
    super.dispose();
  }

  void _onTick() {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final dt = _lastTime == 0.0 ? 0.0 : now - _lastTime;
    _lastTime = now;

    if (dt > 0) {
      _controller.tick(dt);
    }

    // Check for win condition
    final state = _controller.state;
    if (state.isWin && !_winHandled) {
      _winHandled = true;
      _onWin();
    }

    setState(() {});
  }

  Future<void> _onWin() async {
    final completedLevel = widget.levelIndex;
    await ProgressService().advanceOnWin();
    if (!mounted) return;

    // Capture navigator BEFORE pushReplacement while context is still valid
    final navigator = Navigator.of(context);

    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => LevelCompleteScreen(
          completedLevelIndex: completedLevel,
          onNext: () => _afterLevelComplete(navigator, completedLevel),
        ),
      ),
    );
  }

  void _afterLevelComplete(NavigatorState navigator, int completedLevel) {
    final isLastFragmentOfObject = (completedLevel + 1) % 4 == 0;
    final nextLevel = completedLevel + 1;

    if (isLastFragmentOfObject && nextLevel <= 15) {
      // Show ObjectCompleteScreen
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => ObjectCompleteScreen(
            completedObjectId: completedLevel ~/ 4,
            onNext: () => navigator.pushReplacement(
              MaterialPageRoute(
                builder: (_) => GameScreen(
                  levelIndex: nextLevel <= 15 ? nextLevel : 0,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => GameScreen(
            levelIndex: nextLevel <= 15 ? nextLevel : 0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final boardWidth = state.level.boardWidth;
    final boardHeight = state.level.boardHeight;
    final boardPixelWidth = boardWidth * _cellSize;
    final boardPixelHeight = boardHeight * _cellSize;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // HUD
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Level ${widget.levelIndex + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Game board with overlay
          SizedBox(
            width: boardPixelWidth,
            height: boardPixelHeight,
            child: Stack(
              children: [
                // Board painter
                CustomPaint(
                  size: Size(boardPixelWidth, boardPixelHeight),
                  painter: BoardPainter(
                    state: state,
                    cellSize: _cellSize,
                    animValue: _animController.value,
                  ),
                ),
                // Win/Lose overlay
                if (state.isWin || state.isLost)
                  Container(
                    width: boardPixelWidth,
                    height: boardPixelHeight,
                    color: Colors.black54,
                    child: Center(
                      child: Text(
                        state.isWin ? 'YOU WIN 🎉' : 'GAME OVER',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Control panel
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Movement buttons
                  IconButton(
                    icon: const Icon(Icons.arrow_left, color: Colors.white),
                    onPressed: () => _controller.moveLeft(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward, color: Colors.white),
                    onPressed: () => _controller.softDrop(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => _controller.rotateCW(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right, color: Colors.white),
                    onPressed: () => _controller.moveRight(),
                  ),
                  const SizedBox(width: 24),
                  // ARM button
                  Opacity(
                    opacity: state.canArm ? 1.0 : 0.3,
                    child: IconButton(
                      icon: Text(
                        'ARM',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: state.canArm ? () => _controller.armExplosive() : null,
                    ),
                  ),
                  // DETONATE button
                  Opacity(
                    opacity: state.canDetonate ? 1.0 : 0.3,
                    child: IconButton(
                      icon: const Text(
                        '💥',
                        style: TextStyle(fontSize: 24),
                      ),
                      onPressed: state.canDetonate ? () => _controller.detonate() : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
