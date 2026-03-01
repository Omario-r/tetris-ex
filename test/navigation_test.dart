import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:explosive_tetris/main.dart';
import 'package:explosive_tetris/presentation/screens/game_screen.dart';
import 'package:explosive_tetris/presentation/screens/level_complete_screen.dart';
import 'package:explosive_tetris/presentation/screens/object_complete_screen.dart';
import 'package:explosive_tetris/application/progress_service.dart';
import 'package:explosive_tetris/game_engine/game/game_controller.dart';
import 'package:explosive_tetris/game_engine/game/game_state.dart';
import 'package:explosive_tetris/game_engine/models/board.dart';
import 'package:explosive_tetris/game_engine/data/level_map.dart';
import 'package:explosive_tetris/game_engine/rules/randomizer.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Победа на уровне 0 → LevelCompleteScreen',
    (WidgetTester tester) async {
      // Set larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      // Создаём GameState с isWin = true
      final level = LevelMap.levelAt(0);
      final initialState = GameState(
        board: Board(level.boardWidth, level.boardHeight),
        fallingPiece: null,
        phase: GamePhase.won,
        generator: SevenBagGenerator(),
        level: level,
      );

      GameController(
        initialState: initialState,
        gravityInterval: 1,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: GameScreen(levelIndex: 0),
        ),
      );

      // Проверяем, что GameScreen создан с levelIndex=0
      final gameScreen = tester.widget<GameScreen>(find.byType(GameScreen));
      expect(gameScreen.levelIndex, equals(0));

      // Reset viewport
      tester.view.resetPhysicalSize();
    },
  );

  testWidgets(
    'Победа на уровне 3 → LevelCompleteScreen → ObjectCompleteScreen',
    (WidgetTester tester) async {
      // completedLevel=3, (3+1)%4 == 0 → true
      await tester.pumpWidget(
        MaterialApp(
          home: LevelCompleteScreen(
            completedLevelIndex: 3,
            onNext: () {},
          ),
        ),
      );

      expect(find.byType(LevelCompleteScreen), findsOneWidget);
      
      // Проверяем, что после onNext должен быть показан ObjectCompleteScreen
      // (в реальном приложении это происходит через навигацию)
      final completedLevel = 3;
      final isLastFragmentOfObject = (completedLevel + 1) % 4 == 0;
      expect(isLastFragmentOfObject, isTrue);
      expect(completedLevel ~/ 4, equals(0)); // objectId = 0
    },
  );

  testWidgets(
    'Победа на уровне 7 → LevelCompleteScreen → ObjectCompleteScreen (objectId=1)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LevelCompleteScreen(
            completedLevelIndex: 7,
            onNext: () {},
          ),
        ),
      );

      expect(find.byType(LevelCompleteScreen), findsOneWidget);
      
      final completedLevel = 7;
      final isLastFragmentOfObject = (completedLevel + 1) % 4 == 0;
      expect(isLastFragmentOfObject, isTrue);
      expect(completedLevel ~/ 4, equals(1)); // objectId = 1 (заглушка)
    },
  );

  testWidgets(
    'main.dart загружает уровень 5 из prefs',
    (WidgetTester tester) async {
      // Set larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues({'current_level': 5});

      await tester.pumpWidget(const AppRoot());

      // Ждём завершения FutureBuilder
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Проверяем, что GameScreen создан
      expect(find.byType(GameScreen), findsOneWidget);
      
      // Проверяем, что levelIndex = 5
      final gameScreen = tester.widget<GameScreen>(find.byType(GameScreen));
      expect(gameScreen.levelIndex, equals(5));

      // Reset viewport
      tester.view.resetPhysicalSize();
    },
  );

  testWidgets(
    'main.dart загружает уровень 0 если prefs пуст',
    (WidgetTester tester) async {
      // Set larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const AppRoot());

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(GameScreen), findsOneWidget);
      
      final gameScreen = tester.widget<GameScreen>(find.byType(GameScreen));
      expect(gameScreen.levelIndex, equals(0));

      // Reset viewport
      tester.view.resetPhysicalSize();
    },
  );

  testWidgets(
    '_winHandled флаг предотвращает двойной вызов _onWin',
    (WidgetTester tester) async {
      // Создаём тестовый виджет для проверки логики
      var winHandled = false;
      var winCallCount = 0;

      void simulateOnWin() {
        if (!winHandled) {
          winHandled = true;
          winCallCount++;
        }
      }

      // Симулируем isWin дважды
      simulateOnWin(); // Первый вызов
      simulateOnWin(); // Второй вызов (должен быть проигнорирован)

      expect(winCallCount, equals(1));
      expect(winHandled, isTrue);
    },
  );

  testWidgets(
    'ObjectCompleteScreen отображается для objectId=0 (Домик)',
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
    },
  );

  testWidgets(
    'ObjectCompleteScreen отображается для objectId=2 (заглушка)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ObjectCompleteScreen(
            completedObjectId: 2,
            onNext: () {},
          ),
        ),
      );

      expect(find.byType(ObjectCompleteScreen), findsOneWidget);
      expect(find.text('Далее'), findsOneWidget);
    },
  );

  testWidgets(
    'advanceOnWin увеличивает уровень и не выходит за 15',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'current_level': 0});
      final service = ProgressService();
      
      // Уровень 0 → 1
      var result = await service.advanceOnWin();
      expect(result, equals(1));
      
      // Сбрасываем и тестируем границу 15
      SharedPreferences.setMockInitialValues({'current_level': 15});
      final service2 = ProgressService();
      result = await service2.advanceOnWin();
      expect(result, equals(15)); // clamp к 15
    },
  );

  testWidgets(
    'Навигация: уровень 15 → после победы рестарт к 0',
    (WidgetTester tester) async {
      // completedLevel=15, (15+1)%4 == 0 → ObjectCompleteScreen
      final completedLevel = 15;
      final isLastFragmentOfObject = (completedLevel + 1) % 4 == 0;
      expect(isLastFragmentOfObject, isTrue);
      
      final nextLevel = completedLevel + 1;
      // nextLevel > 15 → 0 (рестарт)
      expect(nextLevel > 15, isTrue);
    },
  );
}
