import 'fragment_def.dart';

class ObjectTemplate {
  final int id;
  final String name;
  final List<FragmentDef> fragments; // ровно 4
  const ObjectTemplate({
    required this.id,
    required this.name,
    required this.fragments,
  });
}
