/// Битмаска Target-окна, MSB-first.
/// Клетка (localX, localY) → бит b = (width*height - 1) - (localY*width + localX).
/// Поддерживает окна до 8×8 (64 бита, Dart int).
class TargetMask {
  final int width;
  final int height;
  final int mask;

  const TargetMask({
    required this.width,
    required this.height,
    required this.mask,
  });

  /// true если клетка (localX, localY) входит в S.
  bool contains(int localX, int localY) {
    final totalBits = width * height;
    final bitIndex = (totalBits - 1) - (localY * width + localX);
    return (mask & (1 << bitIndex)) != 0;
  }

  /// Возвращает все локальные координаты клеток S.
  List<({int x, int y})> get cells {
    final result = <({int x, int y})>[];
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (contains(x, y)) {
          result.add((x: x, y: y));
        }
      }
    }
    return result;
  }
}

/// Дефолтная маска MVP: крест толщиной 2 в окне 6×6.
/// Hex: 0x30CFFF30C
const defaultTargetMask = TargetMask(
  width: 6,
  height: 6,
  mask: 0x30CFFF30C,
);
