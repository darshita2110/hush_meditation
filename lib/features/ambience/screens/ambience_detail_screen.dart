import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arvyax_flutter_app/config/theme/app_colors.dart';
import 'package:arvyax_flutter_app/config/theme/text_styles.dart';
import 'package:arvyax_flutter_app/features/ambience/controllers/ambience_controller.dart';
import 'package:arvyax_flutter_app/features/player/widgets/mini_player.dart';

class AmbienceDetailScreen extends ConsumerWidget {
  final String ambienceId;

  const AmbienceDetailScreen({super.key, required this.ambienceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambienceAsync = ref.watch(ambienceByIdProvider(ambienceId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    // Hero image fills full screen width at 280px height — cache at full width
    final cacheW = (screenWidth * devicePixelRatio).round();

    return Scaffold(
      bottomNavigationBar: const MiniPlayer(),
      body: ambienceAsync.when(
        data: (ambience) => CustomScrollView(
          slivers: [
            // ── Hero image / gradient header ──────────────────────────────
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.breathingGradient,
                      ),
                    ),
                    Image.asset(
                      ambience.imagePath,
                      fit: BoxFit.cover,
                      // Cache at screen width — reused when user navigates
                      // back and forward without re-decoding the full asset.
                      cacheWidth: cacheW,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    // Gradient overlay for title readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ambience.title,
                            style: AppTextStyles.h2
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _TagChip(tag: ambience.tag),
                              const SizedBox(width: 8),
                              Text(
                                ambience.durationDisplay,
                                style: AppTextStyles.body2
                                    .copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Body content ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ambience.description,
                      style: AppTextStyles.body1.copyWith(
                        color: isDark
                            ? AppColors.gray300
                            : AppColors.gray700,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'Sensory Recipe',
                      style: AppTextStyles.h4.copyWith(
                        color: isDark
                            ? AppColors.white
                            : AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ambience.sensoryRecipes
                          .map((r) =>
                          _SensoryChip(label: r, isDark: isDark))
                          .toList(),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () =>
                            context.push('/player/$ambienceId'),
                        child: Text(
                          'Start Session',
                          style: AppTextStyles.h5
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Text(
        tag,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SensoryChip extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SensoryChip({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray700 : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.gray600
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.body2.copyWith(
          color: isDark ? AppColors.white : AppColors.primaryDark,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}