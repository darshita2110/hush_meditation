
class AmbienceModel {

  final String id;
  final String title;

  final String tag;

  final int durationMinutes;

  final String description;

  final String imagePath;

  final String audioPath;

  final List<String> sensoryRecipes;

  const AmbienceModel({
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

  int get durationSeconds => durationMinutes * 60;

  String get durationDisplay => '$durationMinutes-${durationMinutes + 1} min';

  bool hasTag(String filterTag) => tag.toLowerCase() == filterTag.toLowerCase();

  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    return title.toLowerCase().contains(query.toLowerCase());
  }
}