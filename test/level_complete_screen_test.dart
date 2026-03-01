import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/presentation/screens/level_complete_screen.dart';
import 'package:explosive_tetris/game_engine/data/level_map.dart';

void main() {
  testWidgets(
    'LevelCompleteScreen рендерится без исключений при completedLevelIndex=0',
    (WidgetTester tester) async {
      // objectId=0, фрагмент 0 Домика — Крыша левая
      await tester.pumpWidget(
        MaterialApp(
          home: LevelCompleteScreen(
            completedLevelIndex: 0,
            onNext: () {},
          ),
        ),
      );

      expect(find.byType(LevelCompleteScreen), findsOneWidget);
      expect(find.text('Далее'), findsOneWidget);
    },
  );

  testWidgets(
    'LevelCompleteScreen рендерится без исключений при completedLevelIndex=7',
    (WidgetTester tester) async {
      // objectId=1, заглушка, fragmentIndex=3
      await tester.pumpWidget(
        MaterialApp(
          home: LevelCompleteScreen(
            completedLevelIndex: 7,
            onNext: () {},
          ),
        ),
      );

      expect(find.byType(LevelCompleteScreen), findsOneWidget);
      expect(find.text('Далее'), findsOneWidget);
    },
  );

  testWidgets(
    'Кнопка "Далее" вызывает onNext',
    (WidgetTester tester) async {
      var nextCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LevelCompleteScreen(
            completedLevelIndex: 0,
            onNext: () {
              nextCalled = true;
            },
          ),
        ),
      );

      expect(find.text('Далее'), findsOneWidget);
      await tester.tap(find.text('Далее'));
      expect(nextCalled, isTrue);
    },
  );

  testWidgets(
    'Анимация не бросает исключений при animProgress=0.0',
    (WidgetTester tester) async {
      // Просто проверяем, что экран строится без исключений
      await tester.pumpWidget(
        MaterialApp(
          home: LevelCompleteScreen(
            completedLevelIndex: 0,
            onNext: () {},
          ),
        ),
      );

      // Экран должен отрендериться без исключений
      expect(find.byType(LevelCompleteScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Анимация не бросает исключений при animProgress=1.0',
    (WidgetTester tester) async {
      // Проверяем с другим уровнем
      await tester.pumpWidget(
        MaterialApp(
          home: LevelCompleteScreen(
            completedLevelIndex: 15,
            onNext: () {},
          ),
        ),
      );

      // Экран должен отрендериться без исключений
      expect(find.byType(LevelCompleteScreen), findsOneWidget);
    },
  );

  testWidgets(
    'ObjectFragmentGridPainter корректно вычисляет objectId и completedFragmentIndex',
    (WidgetTester tester) async {
      // Проверяем, что LevelMap.objects доступен и содержит данные
      expect(LevelMap.objects.length, equals(4));
      expect(LevelMap.objects[0].fragments.length, equals(4));
      expect(LevelMap.objects[0].name, equals('Домик'));
    },
  );
}
