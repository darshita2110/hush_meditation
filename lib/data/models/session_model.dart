
class SessionModel {
  final String ambienceId;
  final DateTime startedAt;
  final int elapsedSeconds;
  final bool isPlaying;

  const SessionModel({
    required this.ambienceId,
    required this.startedAt,
    required this.elapsedSeconds,
    required this.isPlaying,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      ambienceId: json['ambienceId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      elapsedSeconds: json['elapsedSeconds'] as int,
      isPlaying: json['isPlaying'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'ambienceId': ambienceId,
    'startedAt': startedAt.toIso8601String(),
    'elapsedSeconds': elapsedSeconds,
    'isPlaying': isPlaying,
  };


  bool get isActive {
    final age = DateTime.now().difference(startedAt);
    return age.inHours < 24;
  }
}