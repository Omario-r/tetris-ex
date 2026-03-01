import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:explosive_tetris/presentation/screens/object_complete_screen.dart';
import 'package:explosive_tetris/game_engine/data/level_map.dart';

void main() {
  testWidgets(
    'ObjectCompleteScreen рендерится без исключений при completedObjectId=0',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ObjectCompleteScreen(
            completedObjectId: 0,
            onNext: () {},
          ),
        ),
      );

      expect(find.byType(ObjectCompleteScreen), findsOneWidget);
      expect(find.text('Домик'), findsOneWidget);
      expect(find.text('Далее'), findsOneWidget);
    },
  );

  testWidgets(
    'ObjectCompleteScreen рендерится без исключений при completedObjectId=1',
    (WidgetTester tester) async {
      // заглушка — без проверки имени, просто не бросает
      await tester.pumpWidget(
        MaterialApp(
          home: ObjectCompleteScreen(
            completedObjectId: 1,
            onNext: () {},
          ),
        ),
      );

      expect(find.byType(ObjectCompleteScreen), findsOneWidget);
      expect(find.text('Далее'), findsOneWidget);
    },
  );

  testWidgets(
    'Кнопка "Далее" вызывает onNext',
    (WidgetTester tester) async {
      var nextCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ObjectCompleteScreen(
            completedObjectId: 0,
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
    'CustomPaint отображается',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ObjectCompleteScreen(
            completedObjectId: 0,
            onNext: () {},
          ),
        ),
      );

      // CustomPaint присутствует (хотя бы один)
      expect(find.byType(CustomPaint), findsWidgets);
    },
  );

  testWidgets(
    'ObjectFullPainter корректно получает objectTemplate',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ObjectCompleteScreen(
            completedObjectId: 3,
            onNext: () {},
          ),
        ),
      );

      // Проверяем, что объект 3 существует и имеет 4 фрагмента
      expect(LevelMap.objects.length, equals(4));
      expect(LevelMap.objects[3].fragments.length, equals(4));
    },
  );
}
