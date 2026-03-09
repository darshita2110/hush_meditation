import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hush/config/theme/app_colors.dart';
import 'package:hush/config/theme/text_styles.dart';
import 'package:hush/features/player/controllers/player_controller.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);

    // Invisible when no session is active — takes zero space
    if (!playerState.hasActiveSession) return const SizedBox.shrink();

    final ambience = playerState.ambience!;
    final progress = ambience.durationSeconds > 0
        ? (playerState.elapsedSeconds / ambience.durationSeconds)
        .clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () => context.push('/player/${ambience.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.gray900,
          boxShadow: [
            BoxShadow(
              // Fixed: withValues instead of deprecated withOpacity
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thin progress line at top
            LinearProgressIndicator(
              value: progress,
              minHeight: 2,
              backgroundColor: AppColors.gray700,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                children: [
                  // Gradient icon tile
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.breathingGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.self_improvement,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title + elapsed time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ambience.title,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTime(playerState.elapsedSeconds),
                          style: AppTextStyles.caption.copyWith(
                            // Explicit light colour — always on dark bg
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Play / Pause button
                  IconButton(
                    icon: Icon(
                      playerState.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: AppColors.white,
                      size: 28,
                    ),
                    onPressed: () => ref
                        .read(playerProvider.notifier)
                        .togglePlayPause(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}