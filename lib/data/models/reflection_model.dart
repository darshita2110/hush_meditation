import 'package:hive/hive.dart';

part 'reflection_model.g.dart';


@HiveType(typeId: 0)
class ReflectionModel extends HiveObject {

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String ambienceId;

  @HiveField(2)
  late String ambienceTitle;

  @HiveField(3)
  late String journalText;

  @HiveField(4)
  late String mood;

  @HiveField(5)
  late DateTime createdAt;

  ReflectionModel({
    required this.id,
    required this.ambienceId,
    required this.ambienceTitle,
    required this.journalText,
    required this.mood,
    required this.createdAt,
  });

  String get journalPreview {
    final lines = journalText.split('\n');
    if (lines.isEmpty || lines.first.isEmpty) {
      return '[Empty reflection]';
    }
    return lines.first;
  }

  bool get isFromToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }
}