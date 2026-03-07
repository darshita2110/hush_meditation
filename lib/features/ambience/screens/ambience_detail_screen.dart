import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arvyax_flutter_app/config/theme/app_colors.dart';
import 'package:arvyax_flutter_app/config/theme/text_styles.dart';
import 'package:arvyax_flutter_app/features/ambience/controllers/ambience_controller.dart';

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
      data: (ambience) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Hero Image
              SliverAppBar(
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.breathingGradient,
                    ),
                    child: Image.asset(
                      ambience.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ambience.title,
                              style: AppTextStyles.h2,
                            ),
                          ),
                          Chip(
                            label: Text(ambience.tag),
                            backgroundColor: AppColors.primaryLight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${ambience.durationMinutes} minutes',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 20),
                      // Description
                      Text(
                        ambience.description,
                        style: AppTextStyles.body1,
                      ),
                      const SizedBox(height: 24),
                      // Sensory Recipes
                      Text(
                        'Sensory Elements',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ambience.sensoryRecipes.map((recipe) {
                          return Chip(
                            label: Text(recipe),
                            backgroundColor: AppColors.gray100,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      // Start Session Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/player/${ambience.id}');
                          },
                          child: const Text('Start Session'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}