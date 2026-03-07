import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:arvyax_flutter_app/data/models/ambience_model.dart';
import 'package:arvyax_flutter_app/data/repositories/player_repository.dart';
import 'package:arvyax_flutter_app/features/ambience/controllers/ambience_controller.dart';

class PlayerNotifier extends StateNotifier<PlayerState> {
  final PlayerRepository _playerRepository;
  final Ref _ref;
  late AudioPlayer _audioPlayer;
  int? _sessionDuration;
  
  PlayerNotifier(this._playerRepository, this._ref) 
      : super(const PlayerState.idle()) {
    _initializeAudioPlayer();
  }

  Future<void> _initializeAudioPlayer() async {
    _audioPlayer = AudioPlayer();
  }

  Future<void> startSession(String ambienceId) async {
    try {
      state = const PlayerState.loading();
      
      final ambience = await _ref.read(ambienceByIdProvider(ambienceId).future);
      _sessionDuration = ambience.durationSeconds;
      
      await _audioPlayer.setAsset(ambience.audioPath);
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
      
      state = PlayerState.playing(
        ambienceId: ambienceId,
        ambience: ambience,
        elapsedSeconds: 0,
      );
    } catch (e) {
      state = PlayerState.error(e.toString());
    }
  }

  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> seek(Duration duration) async {
    await _audioPlayer.seek(duration);
  }

  Future<void> endSession() async {
    await _audioPlayer.stop();
    state = const PlayerState.idle();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

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

  PlayerState.error(String error)
      : ambienceId = null,
        ambience = null,
        elapsedSeconds = 0,
        isPlaying = false,
        error = error,
        isLoading = false;
}

final playerRepositoryProvider = Provider((ref) => PlayerRepository());

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  return PlayerNotifier(repo, ref);
});