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
    super.key,
    required this.ambienceId,
  });

  @override
  ConsumerState<SessionPlayerScreen> createState() =>
      _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen> {
  double? _draggingValue;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(playerProvider.notifier).startSession(widget.ambienceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final ambienceAsync = ref.watch(ambienceByIdProvider(widget.ambienceId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlaying = playerState.isPlaying;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: ambienceAsync.when(
        data: (ambience) {
          final elapsed = playerState.elapsedSeconds;
          final total = ambience.durationSeconds;
          final sliderValue = _draggingValue ??
              (total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0);

          return Column(
            children: [
              // ── Gradient hero ──────────────────────────────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppColors.breathingGradient,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _BreathingCircle(),
                        const SizedBox(height: 32),
                        Text(
                          ambience.title,
                          style: AppTextStyles.h2
                              .copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ambience.tag,
                          style: AppTextStyles.body2
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Controls panel ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                color: isDark ? AppColors.gray800 : AppColors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Time labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmt(elapsed),
                            style: AppTextStyles.caption.copyWith(
                              color: isDark
                                  ? AppColors.gray300
                                  : AppColors.gray600,
                            )),
                        Text(_fmt(total),
                            style: AppTextStyles.caption.copyWith(
                              color: isDark
                                  ? AppColors.gray300
                                  : AppColors.gray600,
                            )),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Seek slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7),
                        overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16),
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: isDark
                            ? AppColors.gray600
                            : AppColors.gray200,
                        thumbColor: AppColors.primary,
                        overlayColor:
                        AppColors.primary.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: sliderValue,
                        onChangeStart: (v) =>
                            setState(() => _draggingValue = v),
                        onChanged: (v) =>
                            setState(() => _draggingValue = v),
                        onChangeEnd: (v) {
                          setState(() => _draggingValue = null);
                          ref.read(playerProvider.notifier).seek(
                            Duration(seconds: (v * total).round()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Play / Pause FAB ───────────────────────────────────
                    // FIX: NO ValueKey on the FAB itself.
                    // Previously ValueKey(isPlaying) was on FloatingActionButton,
                    // which made Flutter destroy + recreate the entire FAB widget
                    // on every tap. The first tap triggered the widget swap
                    // animation; the second tap actually fired onPressed.
                    // Solution: stable FAB (no key), ValueKey only on the Icon
                    // inside AnimatedSwitcher so only the icon animates.
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: FloatingActionButton(
                        backgroundColor: AppColors.primary,
                        heroTag: 'player_fab',
                        onPressed: () => ref
                            .read(playerProvider.notifier)
                            .togglePlayPause(),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            // Key on Icon only — triggers switcher animation
                            // without recreating the FAB
                            key: ValueKey(isPlaying),
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // End Session
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark
                                ? AppColors.gray500
                                : AppColors.gray300,
                          ),
                          foregroundColor: isDark
                              ? AppColors.gray200
                              : AppColors.gray700,
                        ),
                        onPressed: () =>
                            _showEndSessionDialog(context, ref),
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
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showEndSessionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text(
          'Your progress will be saved and you can write a reflection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _endAndNavigate();
            },
            child: Text('End',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _endAndNavigate() async {
    await ref.read(playerProvider.notifier).endSession();
    if (mounted) context.push('/reflection/${widget.ambienceId}');
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ── Breathing circle ──────────────────────────────────────────────────────────

class _BreathingCircle extends StatefulWidget {
  const _BreathingCircle();

  @override
  State<_BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<_BreathingCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.25),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.15),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: const Icon(
          Icons.self_improvement,
          color: Colors.white,
          size: 56,
        ),
      ),
    );
  }
}