import 'package:hive/hive.dart';

part 'ambience_model.g.dart';

@HiveType(typeId: 0)
class AmbienceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String tag;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String imagePath;

  @HiveField(6)
  final String audioPath;

  @HiveField(7)
  final List<String> sensoryRecipes;

  AmbienceModel({
    required this.id,
    required this.title,
    required this.tag,
    required this.durationMinutes,
    required this.description,
    required this.imagePath,
    required this.audioPath,
    required this.sensoryRecipes,
  });

  factory AmbienceModel.fromJson(Map<String, dynamic> json) {
    return AmbienceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      tag: json['tag'] as String,
      durationMinutes: json['durationMinutes'] as int,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String,
      audioPath: json['audioPath'] as String,
      sensoryRecipes: List<String>.from(json['sensoryRecipes'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'tag': tag,
    'durationMinutes': durationMinutes,
    'description': description,
    'imagePath': imagePath,
    'audioPath': audioPath,
    'sensoryRecipes': sensoryRecipes,
  };

  // The slider uses this — was returning 0 because this getter was missing.
  // 0 as denominator → elapsed/0 = NaN → clamps to 0.0 → slider always at start.
  int get durationSeconds => durationMinutes * 60;

  // Used in AmbienceCard
  String get durationDisplay => '$durationMinutes min';
}