import 'dart:convert';

class WorkoutItem {
  final String id;
  String name;
  int workTime; // in seconds
  int restTime; // in seconds
  int sets;

  WorkoutItem({
    required this.id,
    this.name = 'Exercise',
    this.workTime = 45,
    this.restTime = 15,
    this.sets = 4,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'workTime': workTime,
        'restTime': restTime,
        'sets': sets,
      };

  factory WorkoutItem.fromJson(Map<String, dynamic> json) => WorkoutItem(
        id: json['id'],
        name: json['name'] ?? 'Exercise',
        workTime: json['workTime'] ?? 45,
        restTime: json['restTime'] ?? 15,
        sets: json['sets'] ?? 4,
      );

  WorkoutItem copyWith({
    String? id,
    String? name,
    int? workTime,
    int? restTime,
    int? sets,
  }) {
    return WorkoutItem(
      id: id ?? this.id,
      name: name ?? this.name,
      workTime: workTime ?? this.workTime,
      restTime: restTime ?? this.restTime,
      sets: sets ?? this.sets,
    );
  }

  int get totalDuration => (workTime + restTime) * sets - restTime;

  String get formattedWorkTime => _formatTime(workTime);
  String get formattedRestTime => _formatTime(restTime);
  String get formattedTotalDuration => _formatTime(totalDuration);

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }
}

class WorkoutSession {
  final String id;
  String name;
  final List<WorkoutItem> exercises;
  final DateTime createdAt;
  int restBetweenExercises; // rest time between different exercises

  WorkoutSession({
    required this.id,
    this.name = 'My Workout',
    required this.exercises,
    required this.createdAt,
    this.restBetweenExercises = 60,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'restBetweenExercises': restBetweenExercises,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: json['id'],
        name: json['name'] ?? 'My Workout',
        exercises: (json['exercises'] as List)
            .map((e) => WorkoutItem.fromJson(e))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
        restBetweenExercises: json['restBetweenExercises'] ?? 60,
      );

  String toJsonString() => jsonEncode(toJson());

  factory WorkoutSession.fromJsonString(String jsonString) =>
      WorkoutSession.fromJson(jsonDecode(jsonString));

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets);

  int get totalExercises => exercises.length;

  int get totalDuration {
    if (exercises.isEmpty) return 0;
    int total = exercises.fold(0, (sum, e) => sum + e.totalDuration);
    // Add rest between exercises
    total += restBetweenExercises * (exercises.length - 1);
    return total;
  }

  String get formattedTotalDuration {
    final total = totalDuration;
    final minutes = total ~/ 60;
    final seconds = total % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
    return '${minutes}m ${seconds}s';
  }
}
