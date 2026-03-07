import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arvyax_flutter_app/data/models/ambience_model.dart';
import 'package:arvyax_flutter_app/data/repositories/ambience_repository.dart';

final ambienceRepositoryProvider = Provider((ref) => AmbienceRepository());

final ambiencesProvider = FutureProvider<List<AmbienceModel>>((ref) async {
  final repo = ref.watch(ambienceRepositoryProvider);
  return repo.getAmbiences();
});

final ambienceByIdProvider = FutureProvider.family<AmbienceModel, String>((ref, id) async {
  final repo = ref.watch(ambienceRepositoryProvider);
  return repo.getAmbienceById(id);
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedTagProvider = StateProvider<String?>((ref) => null);

final filteredAmbiencesProvider = FutureProvider<List<AmbienceModel>>((ref) async {
  final ambiences = await ref.watch(ambiencesProvider.future);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedTag = ref.watch(selectedTagProvider);

  return ambiences.where((ambience) {
    final matchesSearch = ambience.title.toLowerCase().contains(searchQuery.toLowerCase());
    final matchesTag = selectedTag == null || ambience.tag == selectedTag;
    return matchesSearch && matchesTag;
  }).toList();
});