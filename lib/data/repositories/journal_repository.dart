import 'package:hive/hive.dart';
import '../models/reflection_model.dart';

class JournalRepository {
  late Box<ReflectionModel> _reflectionBox;

  Future<void> initialize() async {
    _reflectionBox = Hive.box<ReflectionModel>('reflections');
  }

  Future<void> saveReflection(ReflectionModel reflection) async {
    await _reflectionBox.put(reflection.id, reflection);
  }

  List<ReflectionModel> getReflections() {
    final reflections = _reflectionBox.values.toList();
    reflections.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reflections;
  }

  ReflectionModel? getReflectionById(String id) {
    return _reflectionBox.get(id);
  }

  Future<void> deleteReflection(String id) async {
    await _reflectionBox.delete(id);
  }
}