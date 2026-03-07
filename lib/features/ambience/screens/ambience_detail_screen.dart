import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arvyax_flutter_app/config/theme/app_colors.dart';
import 'package:arvyax_flutter_app/config/theme/text_styles.dart';
import 'package:arvyax_flutter_app/features/ambience/controllers/ambience_controller.dart';
import 'package:arvyax_flutter_app/features/player/widgets/mini_player.dart';

class AmbienceDetailScreen extends ConsumerWidget {
  final String ambienceId;

  const AmbienceDetailScreen({
    Key? key,
    required this.ambienceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambienceAsync = ref.watch(ambienceByIdProvider(ambienceId));

    return ambienceAsync.when(
      data: (ambience) => Scaffold(
        bottomNavigationBar: const MiniPlayer(),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          gradient: AppColors.breathingGradient),
                    ),
                    Image.asset(
                      ambience.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(ambience.title, style: AppTextStyles.h2),
                        ),
                        const SizedBox(width: 12),
                        Chip(
                          label: Text(ambience.tag),
                          backgroundColor: AppColors.primaryLight,
                          labelStyle: AppTextStyles.caption
                              .copyWith(color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${ambience.durationMinutes} minutes',
                      style:
                          AppTextStyles.caption.copyWith(color: AppColors.gray500),
                    ),
                    const SizedBox(height: 20),
                    Text(ambience.description, style: AppTextStyles.body1),
                    const SizedBox(height: 28),
                    Text('Sensory Elements', style: AppTextStyles.h4),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ambience.sensoryRecipes
                          .map((r) => Chip(
                                label: Text(r),
                                backgroundColor: AppColors.gray100,
                                labelStyle: AppTextStyles.caption,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () =>
                            context.push('/player/${ambience.id}'),
                        child: const Text('Start Session'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}