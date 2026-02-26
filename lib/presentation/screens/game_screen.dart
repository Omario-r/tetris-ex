import 'package:flutter/material.dart';

import '../../game_engine/game/game_controller.dart';
import '../widgets/board_painter.dart';

/// The main game screen widget that displays the Tetris game.
///
/// Uses [TickerProviderStateMixin] to drive the game loop via an
/// [AnimationController] at approximately 60fps.
class GameScreen extends StatefulWidget {
  /// The game controller that manages game state and logic.
  final GameController controller;

  /// Creates a [GameScreen] with the given [controller].
  const GameScreen({super.key, required this.controller});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final AnimationController _animController;
  late double _lastTime;
  static const double _cellSize = 28.0;

  @override
  void initState() {
    super.initState();
    _lastTime = 0.0;
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
      widget.controller.tick(dt);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final boardWidth = state.level.boardWidth;
    final boardHeight = state.level.boardHeight;
    final boardPixelWidth = boardWidth * _cellSize;
    final boardPixelHeight = boardHeight * _cellSize;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // HUD
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'ETT',
              style: TextStyle(
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Movement buttons
                IconButton(
                  icon: const Icon(Icons.arrow_left, color: Colors.white),
                  onPressed: () => widget.controller.moveLeft(),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, color: Colors.white),
                  onPressed: () => widget.controller.softDrop(),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => widget.controller.rotateCW(),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right, color: Colors.white),
                  onPressed: () => widget.controller.moveRight(),
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
                    onPressed: state.canArm ? () => widget.controller.armExplosive() : null,
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
                    onPressed: state.canDetonate ? () => widget.controller.detonate() : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
