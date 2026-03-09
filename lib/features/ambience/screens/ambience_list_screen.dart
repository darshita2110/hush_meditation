import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hush/config/theme/app_colors.dart';
import 'package:hush/features/ambience/controllers/ambience_controller.dart';
import 'package:hush/features/ambience/widgets/ambience_card.dart';
import 'package:hush/features/player/widgets/mini_player.dart';

class AmbienceListScreen extends ConsumerWidget {
  const AmbienceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTag = ref.watch(selectedTagProvider);
    final filteredAmbiences = ref.watch(filteredAmbiencesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hush'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
      body: CustomScrollView(
        slivers: [
          // ── Search bar ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).state = value,
                style: TextStyle(
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
                decoration: InputDecoration(
                  hintText: 'Search ambiences...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.gray500 : AppColors.gray400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.gray700 : AppColors.gray300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.gray700 : AppColors.gray200,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.gray800 : AppColors.gray50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // ── Tag filter chips ──────────────────────────────────────────
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
                    // FIX: replaced FilterChip with a plain GestureDetector +
                    // Container. FilterChip internally overrides labelStyle and
                    // backgroundColor with theme colours in dark mode, making
                    // the text invisible regardless of what we pass in.
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedTagProvider.notifier).state =
                        isSelected ? null : tag;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                              ? AppColors.gray800
                              : AppColors.gray100),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                ? AppColors.gray600
                                : AppColors.gray300),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            // Explicit colour — no theme override possible
                            color: isSelected
                                ? AppColors.white
                                : (isDark
                                ? AppColors.gray200
                                : AppColors.gray700),
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Ambience grid ─────────────────────────────────────────────
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
                        Text(
                          'No ambiences found',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.gray300
                                : AppColors.gray600,
                          ),
                        ),
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