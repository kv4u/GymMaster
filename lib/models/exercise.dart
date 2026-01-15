class Exercise {
  final String id;
  final String name;
  final String category;
  final int defaultWorkTime; // in seconds
  final int defaultRestTime; // in seconds
  final int defaultSets;
  final String? description;
  final String? iconName;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    this.defaultWorkTime = 45,
    this.defaultRestTime = 30,
    this.defaultSets = 3,
    this.description,
    this.iconName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'defaultWorkTime': defaultWorkTime,
        'defaultRestTime': defaultRestTime,
        'defaultSets': defaultSets,
        'description': description,
        'iconName': iconName,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        defaultWorkTime: json['defaultWorkTime'] ?? 45,
        defaultRestTime: json['defaultRestTime'] ?? 30,
        defaultSets: json['defaultSets'] ?? 3,
        description: json['description'],
        iconName: json['iconName'],
      );
}

class ExerciseCategory {
  final String name;
  final String icon;
  final List<Exercise> exercises;

  const ExerciseCategory({
    required this.name,
    required this.icon,
    required this.exercises,
  });
}
