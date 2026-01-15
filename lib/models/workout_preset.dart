import 'dart:convert';

class WorkoutPreset {
  final String id;
  final String name;
  final int workTime; // in seconds
  final int restTime; // in seconds
  final int sets;
  final DateTime createdAt;
  final String? exerciseId; // optional, if linked to an exercise

  WorkoutPreset({
    required this.id,
    required this.name,
    required this.workTime,
    required this.restTime,
    required this.sets,
    required this.createdAt,
    this.exerciseId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'workTime': workTime,
        'restTime': restTime,
        'sets': sets,
        'createdAt': createdAt.toIso8601String(),
        'exerciseId': exerciseId,
      };

  factory WorkoutPreset.fromJson(Map<String, dynamic> json) => WorkoutPreset(
        id: json['id'],
        name: json['name'],
        workTime: json['workTime'],
        restTime: json['restTime'],
        sets: json['sets'],
        createdAt: DateTime.parse(json['createdAt']),
        exerciseId: json['exerciseId'],
      );

  String toJsonString() => jsonEncode(toJson());

  factory WorkoutPreset.fromJsonString(String jsonString) =>
      WorkoutPreset.fromJson(jsonDecode(jsonString));

  String get formattedWorkTime => _formatTime(workTime);
  String get formattedRestTime => _formatTime(restTime);

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }

  int get totalDuration => (workTime + restTime) * sets - restTime;
  
  String get formattedTotalDuration {
    final total = totalDuration;
    final minutes = total ~/ 60;
    final secs = total % 60;
    return '${minutes}m ${secs}s';
  }
}
