import 'dart:convert';

class WorkoutHistory {
  final String id;
  final String workoutName;
  final int workTime;
  final int restTime;
  final int totalSets;
  final int completedSets;
  final DateTime startedAt;
  final DateTime completedAt;
  final bool wasCompleted;

  WorkoutHistory({
    required this.id,
    required this.workoutName,
    required this.workTime,
    required this.restTime,
    required this.totalSets,
    required this.completedSets,
    required this.startedAt,
    required this.completedAt,
    required this.wasCompleted,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workoutName': workoutName,
        'workTime': workTime,
        'restTime': restTime,
        'totalSets': totalSets,
        'completedSets': completedSets,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt.toIso8601String(),
        'wasCompleted': wasCompleted,
      };

  factory WorkoutHistory.fromJson(Map<String, dynamic> json) => WorkoutHistory(
        id: json['id'],
        workoutName: json['workoutName'],
        workTime: json['workTime'],
        restTime: json['restTime'],
        totalSets: json['totalSets'],
        completedSets: json['completedSets'],
        startedAt: DateTime.parse(json['startedAt']),
        completedAt: DateTime.parse(json['completedAt']),
        wasCompleted: json['wasCompleted'],
      );

  String toJsonString() => jsonEncode(toJson());

  factory WorkoutHistory.fromJsonString(String jsonString) =>
      WorkoutHistory.fromJson(jsonDecode(jsonString));

  Duration get totalDuration => completedAt.difference(startedAt);

  String get formattedDuration {
    final duration = totalDuration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  double get completionRate => completedSets / totalSets;
}
