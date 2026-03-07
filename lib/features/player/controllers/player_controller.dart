import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:arvyax_flutter_app/data/models/ambience_model.dart';
import 'package:arvyax_flutter_app/data/models/session_model.dart';
import 'package:arvyax_flutter_app/data/repositories/player_repository.dart';
import 'package:arvyax_flutter_app/features/ambience/controllers/ambience_controller.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class PlayerState {
  final String? ambienceId;
  final AmbienceModel? ambience;
  final int elapsedSeconds;
  final bool isPlaying;
  final String? error;
  final bool isLoading;

  const PlayerState({
    this.ambienceId,
    this.ambience,
    this.elapsedSeconds = 0,
    this.isPlaying = false,
    this.error,
    this.isLoading = false,
  });

  const PlayerState.idle()
      : ambienceId = null,
        ambience = null,
        elapsedSeconds = 0,
        isPlaying = false,
        error = null,
        isLoading = false;

  const PlayerState.loading()
      : ambienceId = null,
        ambience = null,
        elapsedSeconds = 0,
        isPlaying = false,
        error = null,
        isLoading = true;

  PlayerState.playing({
    required String ambienceId,
    required AmbienceModel ambience,
    required int elapsedSeconds,
  })  : ambienceId = ambienceId,
        ambience = ambience,
        elapsedSeconds = elapsedSeconds,
        isPlaying = true,
        error = null,
        isLoading = false;

  PlayerState.paused({
    required String ambienceId,
    required AmbienceModel ambience,
    required int elapsedSeconds,
  })  : ambienceId = ambienceId,
        ambience = ambience,
        elapsedSeconds = elapsedSeconds,
        isPlaying = false,
        error = null,
        isLoading = false;

  PlayerState.error(String message)
      : ambienceId = null,
        ambience = null,
        elapsedSeconds = 0,
        isPlaying = false,
        error = message,
        isLoading = false;

  PlayerState copyWith({
    String? ambienceId,
    AmbienceModel? ambience,
    int? elapsedSeconds,
    bool? isPlaying,
    String? error,
    bool? isLoading,
  }) {
    return PlayerState(
      ambienceId: ambienceId ?? this.ambienceId,
      ambience: ambience ?? this.ambience,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isPlaying: isPlaying ?? this.isPlaying,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// True when a session is loaded (playing or paused), used for mini-player
  bool get hasActiveSession =>
      ambienceId != null && ambience != null && !isLoading && error == null;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class PlayerNotifier extends StateNotifier<PlayerState> {
  final PlayerRepository _repo;
  final Ref _ref;

  late final AudioPlayer _audioPlayer;
  Timer? _timer;

  PlayerNotifier(this._repo, this._ref) : super(const PlayerState.idle()) {
    _audioPlayer = AudioPlayer();
    _restoreSession();
  }

  // ── Session lifecycle ──────────────────────────────────────────────────────

  Future<void> _restoreSession() async {
    await _repo.initialize();
    final saved = _repo.getSessionState();
    if (saved != null && saved.isActive) {
      try {
        final ambience =
            await _ref.read(ambienceByIdProvider(saved.ambienceId).future);
        await _audioPlayer.setAsset(ambience.audioPath);
        await _audioPlayer.setLoopMode(LoopMode.one);
        // Restore paused – don't auto-play on restore so user decides
        state = PlayerState.paused(
          ambienceId: ambience.id,
          ambience: ambience,
          elapsedSeconds: saved.elapsedSeconds,
        );
      } catch (_) {
        await _repo.clearSessionState();
      }
    }
  }

  Future<void> startSession(String ambienceId) async {
    // If the same session is already loaded just return
    if (state.ambienceId == ambienceId && state.hasActiveSession) return;

    try {
      state = const PlayerState.loading();
      final ambience =
          await _ref.read(ambienceByIdProvider(ambienceId).future);

      await _audioPlayer.setAsset(ambience.audioPath);
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();

      state = PlayerState.playing(
        ambienceId: ambienceId,
        ambience: ambience,
        elapsedSeconds: 0,
      );

      _startTimer();
      _persistSession();
    } catch (e) {
      state = PlayerState.error(e.toString());
    }
  }

  Future<void> togglePlayPause() async {
    if (!state.hasActiveSession) return;

    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      _timer?.cancel();
      state = PlayerState.paused(
        ambienceId: state.ambienceId!,
        ambience: state.ambience!,
        elapsedSeconds: state.elapsedSeconds,
      );
    } else {
      await _audioPlayer.play();
      state = PlayerState.playing(
        ambienceId: state.ambienceId!,
        ambience: state.ambience!,
        elapsedSeconds: state.elapsedSeconds,
      );
      _startTimer();
    }
    _persistSession();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Ends session and clears everything. Call before navigating to reflection.
  Future<void> endSession() async {
    _timer?.cancel();
    await _audioPlayer.stop();
    await _repo.clearSessionState();
    state = const PlayerState.idle();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isPlaying) return;

      final elapsed = state.elapsedSeconds + 1;
      final duration = state.ambience?.durationSeconds ?? 0;

      if (elapsed >= duration) {
        // Session complete – stop timer, keep state for mini-player to detect
        _timer?.cancel();
        _audioPlayer.stop();
        state = state.copyWith(elapsedSeconds: duration, isPlaying: false);
        _repo.clearSessionState();
      } else {
        state = state.copyWith(elapsedSeconds: elapsed);
        _persistSession();
      }
    });
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  void _persistSession() {
    if (!state.hasActiveSession) return;
    _repo.saveSessionState(SessionModel(
      ambienceId: state.ambienceId!,
      startedAt: DateTime.now(),
      elapsedSeconds: state.elapsedSeconds,
      isPlaying: state.isPlaying,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final playerRepositoryProvider = Provider((ref) => PlayerRepository());

final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  return PlayerNotifier(repo, ref);
});