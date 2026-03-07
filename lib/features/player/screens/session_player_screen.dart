import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arvyax_flutter_app/config/theme/app_colors.dart';
import 'package:arvyax_flutter_app/config/theme/text_styles.dart';
import 'package:arvyax_flutter_app/features/player/controllers/player_controller.dart';
import 'package:arvyax_flutter_app/features/ambience/controllers/ambience_controller.dart';

class SessionPlayerScreen extends ConsumerStatefulWidget {
  final String ambienceId;

  const SessionPlayerScreen({
    Key? key,
    required this.ambienceId,
  }) : super(key: key);

  @override
  ConsumerState<SessionPlayerScreen> createState() => _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(playerProvider.notifier).startSession(widget.ambienceId);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final ambienceAsync = ref.watch(ambienceByIdProvider(widget.ambienceId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ambienceAsync.when(
        data: (ambience) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.breathingGradient,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Breathing Animation
                        _BreathingCircle(),
                        const SizedBox(height: 40),
                        Text(
                          ambience.title,
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Timer Display
                    Text(
                      '${playerState.elapsedSeconds ~/ 60}:${(playerState.elapsedSeconds % 60).toString().padLeft(2, '0')} / ${ambience.durationMinutes}:00',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: 24),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: playerState.elapsedSeconds / ambience.durationSeconds,
                        minHeight: 4,
                        backgroundColor: AppColors.gray200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Play/Pause Button
                    FloatingActionButton(
                      size: 64,
                      onPressed: () {
                        ref.read(playerProvider.notifier).togglePlayPause();
                      },
                      child: Icon(
                        playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // End Session Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _showEndSessionDialog(context, ref);
                        },
                        child: const Text('End Session'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showEndSessionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(playerProvider.notifier).endSession();
              context.push('/reflection/${widget.ambienceId}');
            },
            child: const Text('End'),
          ),
        ],
      ),
    );
  }
}

class _BreathingCircle extends StatefulWidget {
  @override
  State<_BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<_BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}