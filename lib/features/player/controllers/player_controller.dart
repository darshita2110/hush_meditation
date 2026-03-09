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
    required this.ambienceId,
    required this.ambience,
    required this.elapsedSeconds,
  })  : isPlaying = true,
        error = null,
        isLoading = false;

  PlayerState.paused({
    required this.ambienceId,
    required this.ambience,
    required this.elapsedSeconds,
  })  : isPlaying = false,
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

  bool get hasActiveSession =>
      ambienceId != null && ambience != null && !isLoading && error == null;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class PlayerNotifier extends StateNotifier<PlayerState> {
  final PlayerRepository _repo;
  final Ref _ref;

  late final AudioPlayer _audioPlayer;
  Timer? _timer;

  // _elapsed is the SINGLE SOURCE OF TRUTH for elapsed time.
  // The timer increments this. seek() updates this immediately.
  // State is updated FROM this — never the other way around.
  // This is what was causing slider snap-back: the timer was reading
  // state.elapsedSeconds (stale) instead of this fresh local counter.
  int _elapsed = 0;

  PlayerNotifier(this._repo, this._ref) : super(const PlayerState.idle()) {
    _audioPlayer = AudioPlayer();
    _restoreSession();
  }

  // ── Session lifecycle ────────────────────────────────────────────────────

  Future<void> _restoreSession() async {
    await _repo.initialize();
    final saved = _repo.getSessionState();
    if (saved != null && saved.isActive) {
      try {
        final ambience =
        await _ref.read(ambienceByIdProvider(saved.ambienceId).future);
        await _audioPlayer.setAsset(ambience.audioPath);
        await _audioPlayer.setLoopMode(LoopMode.one);
        _elapsed = saved.elapsedSeconds;
        state = PlayerState.paused(
          ambienceId: ambience.id,
          ambience: ambience,
          elapsedSeconds: _elapsed,
        );
      } catch (_) {
        await _repo.clearSessionState();
      }
    }
  }

  Future<void> startSession(String ambienceId) async {
    if (state.ambienceId == ambienceId && state.hasActiveSession) return;

    try {
      state = const PlayerState.loading();
      final ambience =
      await _ref.read(ambienceByIdProvider(ambienceId).future);

      await _audioPlayer.setAsset(ambience.audioPath);
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();

      _elapsed = 0;

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

  // FIX: use state.isPlaying (our source of truth) not _audioPlayer.playing
  // just_audio's .playing getter lags on Android — this caused the button
  // to appear stuck because we were toggling the wrong direction.
  Future<void> togglePlayPause() async {
    if (!state.hasActiveSession) return;

    if (state.isPlaying) {
      await _audioPlayer.pause();
      _timer?.cancel();
      state = PlayerState.paused(
        ambienceId: state.ambienceId!,
        ambience: state.ambience!,
        elapsedSeconds: _elapsed,
      );
    } else {
      await _audioPlayer.play();
      state = PlayerState.playing(
        ambienceId: state.ambienceId!,
        ambience: state.ambience!,
        elapsedSeconds: _elapsed,
      );
      _startTimer();
    }
    _persistSession();
  }

  // FIX: _elapsed is updated BEFORE state and BEFORE the audio seek.
  // Old code updated state but the timer's next tick still read the old
  // _elapsed value (0 or wherever it was) and snapped back.
  Future<void> seek(Duration position) async {
    _elapsed = position.inSeconds;               // ← update counter first
    state = state.copyWith(elapsedSeconds: _elapsed); // ← then state
    await _audioPlayer.seek(position);           // ← then audio
  }

  Future<void> endSession() async {
    _timer?.cancel();
    _elapsed = 0;
    await _audioPlayer.stop();
    await _repo.clearSessionState();
    state = const PlayerState.idle();
  }

  // ── Timer ────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isPlaying) return;

      // Increment the local counter — NOT state.elapsedSeconds
      // Reading state inside a closure gives a stale snapshot on Riverpod.
      _elapsed++;

      final duration = state.ambience?.durationSeconds ?? 0;

      if (_elapsed >= duration) {
        _timer?.cancel();
        _audioPlayer.stop();
        state = state.copyWith(
          elapsedSeconds: duration,
          isPlaying: false,
        );
        _repo.clearSessionState();
      } else {
        // Push the fresh counter value into state for the UI
        state = state.copyWith(elapsedSeconds: _elapsed);
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
      elapsedSeconds: _elapsed,
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