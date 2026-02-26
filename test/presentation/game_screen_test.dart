import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explosive_tetris/game_engine/game/game_controller.dart';
import 'package:explosive_tetris/game_engine/game/game_state.dart';
import 'package:explosive_tetris/game_engine/models/board.dart';
import 'package:explosive_tetris/game_engine/models/level_template.dart';
import 'package:explosive_tetris/game_engine/rules/randomizer.dart';
import 'package:explosive_tetris/presentation/screens/game_screen.dart';
import 'package:explosive_tetris/presentation/widgets/board_painter.dart';

/// Creates a [GameController] with an empty board in spawning phase.
GameController createEmptyController() {
  final initialState = GameState(
    board: Board(defaultLevel.boardWidth, defaultLevel.boardHeight),
    fallingPiece: null,
    phase: GamePhase.spawning,
    generator: SevenBagGenerator(seed: 42),
    level: defaultLevel,
  );
  return GameController(initialState: initialState);
}

/// Creates a [GameController] with a piece spawned and ready to move.
GameController createControllerWithPiece() {
  final controller = createEmptyController();
  // Trigger spawn by calling tick
  controller.tick(0.1);
  return controller;
}

/// Creates a [GameController] in a winning state by filling all S cells.
GameController createWinningController() {
  final board = Board(defaultLevel.boardWidth, defaultLevel.boardHeight);
  // Fill all S cells to trigger win condition
  for (final cell in defaultLevel.S) {
    board.setCell(cell.$1, cell.$2, const Cell.occupied());
  }
  final initialState = GameState(
    board: board,
    fallingPiece: null,
    phase: GamePhase.won,
    generator: SevenBagGenerator(seed: 42),
    level: defaultLevel,
  );
  return GameController(initialState: initialState);
}

void main() {
  group('GameScreen', () {
    testWidgets('renders_board_painter', (WidgetTester tester) async {
      final controller = createEmptyController();

      // Set larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(controller: controller),
        ),
      );

      // Find CustomPaint widgets and check that the board painter is present
      final customPaints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      final hasBoardPainter = customPaints.any((cp) => cp.painter is BoardPainter);
      expect(hasBoardPainter, isTrue);

      // Reset viewport
      tester.view.resetPhysicalSize();
    });

    testWidgets('move_buttons_call_controller', (WidgetTester tester) async {
      final controller = createControllerWithPiece();

      // Set larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(controller: controller),
        ),
      );

      // Get initial x position
      final initialX = controller.state.fallingPiece?.x;

      // Tap right button (arrow_right icon)
      final rightButton = find.byIcon(Icons.arrow_right);
      await tester.tap(rightButton, warnIfMissed: false);
      await tester.pump();

      // Verify x position changed
      expect(controller.state.fallingPiece?.x, equals(initialX! + 1));

      // Tap left button (arrow_left icon)
      final leftButton = find.byIcon(Icons.arrow_left);
      await tester.tap(leftButton, warnIfMissed: false);
      await tester.pump();

      // Verify x position changed back
      expect(controller.state.fallingPiece?.x, equals(initialX));

      // Reset viewport
      tester.view.resetPhysicalSize();
    });

    testWidgets('arm_button_hidden_when_cannot_arm', (
      WidgetTester tester,
    ) async {
      // Create controller with no falling piece (canArm == false)
      final controller = createEmptyController();

      // Set larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(controller: controller),
        ),
      );

      // Find ARM button by text
      final armButtonFinder = find.text('ARM');
      expect(armButtonFinder, findsOneWidget);

      // Get the Opacity widget wrapping the ARM button
      final opacityWidget = tester.widget<Opacity>(
        find.ancestor(of: armButtonFinder, matching: find.byType(Opacity)),
      );

      // Verify opacity is 0.3 when canArm is false
      expect(opacityWidget.opacity, equals(0.3));

      // Reset viewport
      tester.view.resetPhysicalSize();
    });

    testWidgets('detonate_button_hidden_when_cannot_detonate', (
      WidgetTester tester,
    ) async {
      // Create controller with no falling piece (canDetonate == false)
      final controller = createEmptyController();

      // Set larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(controller: controller),
        ),
      );

      // Find DETONATE button by emoji
      final detonateButtonFinder = find.text('💥');
      expect(detonateButtonFinder, findsOneWidget);

      // Get the Opacity widget wrapping the DETONATE button
      final opacityWidget = tester.widget<Opacity>(
        find.ancestor(of: detonateButtonFinder, matching: find.byType(Opacity)),
      );

      // Verify opacity is 0.3 when canDetonate is false
      expect(opacityWidget.opacity, equals(0.3));

      // Reset viewport
      tester.view.resetPhysicalSize();
    });

    testWidgets('win_overlay_shown_on_isWin', (WidgetTester tester) async {
      final controller = createWinningController();

      // Set larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(controller: controller),
        ),
      );

      expect(find.text('YOU WIN 🎉'), findsOneWidget);

      // Reset viewport
      tester.view.resetPhysicalSize();
    });
  });
}
