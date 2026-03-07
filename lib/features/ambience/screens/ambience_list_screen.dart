import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arvyax_flutter_app/config/theme/app_colors.dart';
import 'package:arvyax_flutter_app/features/ambience/controllers/ambience_controller.dart';
import 'package:arvyax_flutter_app/features/ambience/widgets/ambience_card.dart';
import 'package:arvyax_flutter_app/features/player/widgets/mini_player.dart';

class AmbienceListScreen extends ConsumerWidget {
  const AmbienceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTag = ref.watch(selectedTagProvider);
    final filteredAmbiences = ref.watch(filteredAmbiencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ArvyaX'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
          ),
        ],
      ),
      // MiniPlayer sits above the bottom system bar
      bottomNavigationBar: const MiniPlayer(),
      body: CustomScrollView(
        slivers: [
          // ── Search bar ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: (value) =>
                    ref.read(searchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Search ambiences...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.gray300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // ── Tag filter chips ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['Focus', 'Calm', 'Sleep', 'Reset'].map((tag) {
                  final isSelected = selectedTag == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        ref.read(selectedTagProvider.notifier).state =
                            selected ? tag : null;
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.gray900,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Grid ────────────────────────────────────────────────────────
          filteredAmbiences.when(
            data: (ambiences) {
              if (ambiences.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: AppColors.gray400),
                        const SizedBox(height: 16),
                        const Text('No ambiences found'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(searchQueryProvider.notifier)
                                .state = '';
                            ref
                                .read(selectedTagProvider.notifier)
                                .state = null;
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ambience = ambiences[index];
                      return AmbienceCard(
                        ambience: ambience,
                        onTap: () =>
                            context.push('/detail/${ambience.id}'),
                      );
                    },
                    childCount: ambiences.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}