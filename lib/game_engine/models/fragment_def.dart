import '../models/level_template.dart';

class FragmentDef {
  final int anchorX;
  final int anchorY;
  final LevelTemplate level;
  const FragmentDef({
    required this.anchorX,
    required this.anchorY,
    required this.level,
  });
}
