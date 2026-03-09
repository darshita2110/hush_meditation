import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:hush/data/models/reflection_model.dart';
import 'package:hush/data/repositories/journal_repository.dart';

final journalRepositoryProvider = Provider((ref) => JournalRepository());

class JournalNotifier extends StateNotifier<List<ReflectionModel>> {
  final JournalRepository _repo;

  JournalNotifier(this._repo) : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _repo.initialize();
    _loadReflections();
  }

  void _loadReflections() {
    state = _repo.getReflections();
  }

  Future<void> saveReflection({
    required String ambienceId,
    required String ambienceTitle,
    required String journalText,
    required String mood,
  }) async {
    const uuid = Uuid();
    final reflection = ReflectionModel(
      id: uuid.v4(),
      ambienceId: ambienceId,
      ambienceTitle: ambienceTitle,
      journalText: journalText,
      mood: mood,
      createdAt: DateTime.now(),
    );

    await _repo.saveReflection(reflection);
    _loadReflections();
  }

  Future<void> deleteReflection(String id) async {
    await _repo.deleteReflection(id);
    _loadReflections();
  }
}

final journalProvider = StateNotifierProvider<JournalNotifier, List<ReflectionModel>>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  return JournalNotifier(repo);
});