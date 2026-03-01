import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explosive_tetris/presentation/screens/game_screen.dart';
import 'package:explosive_tetris/presentation/widgets/board_painter.dart';

void main() {
  group('GameScreen', () {
    testWidgets('renders_board_painter', (WidgetTester tester) async {
      // Set larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: GameScreen(levelIndex: 0),
        ),
      );

      // Find CustomPaint widgets and check that the board painter is present
      final customPaints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      final hasBoardPainter = customPaints.any((cp) => cp.painter is BoardPainter);
      expect(hasBoardPainter, isTrue);

      // Reset viewport
      tester.view.resetPhysicalSize();
    });

    testWidgets('renders_without_error', (WidgetTester tester) async {
      // Set larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: GameScreen(levelIndex: 0),
        ),
      );

      // Verify GameScreen renders
      expect(find.byType(GameScreen), findsOneWidget);

      // Reset viewport
      tester.view.resetPhysicalSize();
    });

    testWidgets('arm_button_disabled_when_cannot_arm', (
      WidgetTester tester,
    ) async {
      // Set larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: GameScreen(levelIndex: 0),
        ),
      );

      // Find ARM button by text
      final armButtonFinder = find.text('ARM');
      expect(armButtonFinder, findsOneWidget);

      // Get the Opacity widget wrapping the ARM button
      final opacityWidget = tester.widget<Opacity>(
        find.ancestor(of: armButtonFinder, matching: find.byType(Opacity)),
      );

      // Verify opacity is 0.3 when canArm is false (initial state)
      expect(opacityWidget.opacity, equals(0.3));

      // Reset viewport
      tester.view.resetPhysicalSize();
    });

    testWidgets('detonate_button_disabled_when_cannot_detonate', (
      WidgetTester tester,
    ) async {
      // Set larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: GameScreen(levelIndex: 0),
        ),
      );

      // Find DETONATE button by emoji
      final detonateButtonFinder = find.text('💥');
      expect(detonateButtonFinder, findsOneWidget);

      // Get the Opacity widget wrapping the DETONATE button
      final opacityWidget = tester.widget<Opacity>(
        find.ancestor(of: detonateButtonFinder, matching: find.byType(Opacity)),
      );

      // Verify opacity is 0.3 when canDetonate is false (initial state)
      expect(opacityWidget.opacity, equals(0.3));

      // Reset viewport
      tester.view.resetPhysicalSize();
    });

    testWidgets('renders_level_text', (WidgetTester tester) async {
      // Set larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: GameScreen(levelIndex: 0),
        ),
      );

      // Verify level text is shown
      expect(find.text('Level 1'), findsOneWidget);

      // Reset viewport
      tester.view.resetPhysicalSize();
    });
  });
}
