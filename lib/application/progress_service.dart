import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _key = 'current_level';
  static const int _min = 0;
  static const int _max = 15;

  /// Возвращает текущий уровень (0..15). Если ключ не задан — возвращает 0.
  Future<int> getCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_key) ?? 0;
    return v.clamp(_min, _max);
  }

  /// Сохраняет уровень. Значение автоматически clamp-ится в 0..15.
  Future<void> setCurrentLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, level.clamp(_min, _max));
  }

  /// Вызывать только после победы на уровне.
  /// Возвращает новый уровень (не выходит за 15).
  Future<int> advanceOnWin() async {
    final current = await getCurrentLevel();
    final next = math.min(current + 1, _max);
    await setCurrentLevel(next);
    return next;
  }

  /// Сбрасывает прогресс. Использовать только для отладки и тестов.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
