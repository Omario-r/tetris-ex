import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:explosive_tetris/application/progress_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Default level is 0', () async {
    final s = ProgressService();
    expect(await s.getCurrentLevel(), 0);
  });

  test('setCurrentLevel / getCurrentLevel round-trip', () async {
    final s = ProgressService();
    await s.setCurrentLevel(5);
    expect(await s.getCurrentLevel(), 5);
  });

  test('advanceOnWin increments level', () async {
    final s = ProgressService();
    await s.setCurrentLevel(7);
    expect(await s.advanceOnWin(), 8);
    expect(await s.getCurrentLevel(), 8);
  });

  test('advanceOnWin clamps at 15', () async {
    final s = ProgressService();
    await s.setCurrentLevel(15);
    expect(await s.advanceOnWin(), 15);
    expect(await s.getCurrentLevel(), 15);
  });

  test('Out-of-range values are clamped', () async {
    final s = ProgressService();
    await s.setCurrentLevel(999);
    expect(await s.getCurrentLevel(), 15);
    await s.setCurrentLevel(-10);
    expect(await s.getCurrentLevel(), 0);
  });

  test('reset clears progress', () async {
    final s = ProgressService();
    await s.setCurrentLevel(7);
    await s.reset();
    expect(await s.getCurrentLevel(), 0);
  });
}
