import '../models/exercise.dart';

class ExercisesData {
  static const List<ExerciseCategory> categories = [
    // ═══════════════════════════════════════════════════════════════════════════
    // CHEST
    // ═══════════════════════════════════════════════════════════════════════════
    ExerciseCategory(
      name: 'Chest',
      icon: '💪',
      exercises: [
        Exercise(
          id: 'chest_bench_press',
          name: 'Bench Press',
          category: 'Chest',
          defaultWorkTime: 45,
          defaultRestTime: 60,
          defaultSets: 4,
          description: 'Classic chest builder with barbell',
        ),
        Exercise(
          id: 'chest_push_ups',
          name: 'Push-Ups',
          category: 'Chest',
          defaultWorkTime: 40,
          defaultRestTime: 30,
          defaultSets: 3,
          description: 'Bodyweight chest exercise',
        ),
        Exercise(
          id: 'chest_dumbbell_flyes',
          name: 'Dumbbell Flyes',
          category: 'Chest',
          defaultWorkTime: 40,
          defaultRestTime: 45,
          defaultSets: 3,
          description: 'Isolation exercise for chest',
        ),
        Exercise(
          id: 'chest_incline_press',
          name: 'Incline Press',
          category: 'Chest',
          defaultWorkTime: 45,
          defaultRestTime: 60,
          defaultSets: 4,
          description: 'Upper chest focus',
        ),
        Exercise(
          id: 'chest_cable_crossover',
          name: 'Cable Crossover',
          category: 'Chest',
          defaultWorkTime: 35,
          defaultRestTime: 40,
          defaultSets: 3,
          description: 'Cable chest isolation',
        ),
      ],
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // BACK
    // ═══════════════════════════════════════════════════════════════════════════
    ExerciseCategory(
      name: 'Back',
      icon: '🔙',
      exercises: [
        Exercise(
          id: 'back_pull_ups',
          name: 'Pull-Ups',
          category: 'Back',
          defaultWorkTime: 40,
          defaultRestTime: 60,
          defaultSets: 4,
          description: 'Bodyweight back builder',
        ),
        Exercise(
          id: 'back_deadlift',
          name: 'Deadlift',
          category: 'Back',
          defaultWorkTime: 50,
          defaultRestTime: 90,
          defaultSets: 4,
          description: 'Compound full body lift',
        ),
        Exercise(
          id: 'back_bent_over_rows',
          name: 'Bent Over Rows',
          category: 'Back',
          defaultWorkTime: 45,
          defaultRestTime: 60,
          defaultSets: 4,
          description: 'Barbell rowing motion',
        ),
        Exercise(
          id: 'back_lat_pulldown',
          name: 'Lat Pulldown',
          category: 'Back',
          defaultWorkTime: 40,
          defaultRestTime: 45,
          defaultSets: 3,
          description: 'Cable lat isolation',
        ),
        Exercise(
          id: 'back_seated_row',
          name: 'Seated Cable Row',
          category: 'Back',
          defaultWorkTime: 40,
          defaultRestTime: 45,
          defaultSets: 3,
          description: 'Cable rowing movement',
        ),
      ],
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // LEGS
    // ═══════════════════════════════════════════════════════════════════════════
    ExerciseCategory(
      name: 'Legs',
      icon: '🦵',
      exercises: [
        Exercise(
          id: 'legs_squats',
          name: 'Squats',
          category: 'Legs',
          defaultWorkTime: 50,
          defaultRestTime: 90,
          defaultSets: 4,
          description: 'King of leg exercises',
        ),
        Exercise(
          id: 'legs_lunges',
          name: 'Lunges',
          category: 'Legs',
          defaultWorkTime: 45,
          defaultRestTime: 45,
          defaultSets: 3,
          description: 'Unilateral leg exercise',
        ),
        Exercise(
          id: 'legs_leg_press',
          name: 'Leg Press',
          category: 'Legs',
          defaultWorkTime: 45,
          defaultRestTime: 60,
          defaultSets: 4,
          description: 'Machine leg compound',
        ),
        Exercise(
          id: 'legs_leg_curl',
          name: 'Leg Curl',
          category: 'Legs',
          defaultWorkTime: 35,
          defaultRestTime: 40,
          defaultSets: 3,
          description: 'Hamstring isolation',
        ),
        Exercise(
          id: 'legs_calf_raises',
          name: 'Calf Raises',
          category: 'Legs',
          defaultWorkTime: 30,
          defaultRestTime: 30,
          defaultSets: 4,
          description: 'Calf muscle builder',
        ),
        Exercise(
          id: 'legs_leg_extension',
          name: 'Leg Extension',
          category: 'Legs',
          defaultWorkTime: 35,
          defaultRestTime: 40,
          defaultSets: 3,
          description: 'Quad isolation',
        ),
      ],
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // ARMS
    // ═══════════════════════════════════════════════════════════════════════════
    ExerciseCategory(
      name: 'Arms',
      icon: '💪',
      exercises: [
        Exercise(
          id: 'arms_bicep_curls',
          name: 'Bicep Curls',
          category: 'Arms',
          defaultWorkTime: 35,
          defaultRestTime: 40,
          defaultSets: 3,
          description: 'Classic bicep builder',
        ),
        Exercise(
          id: 'arms_tricep_dips',
          name: 'Tricep Dips',
          category: 'Arms',
          defaultWorkTime: 40,
          defaultRestTime: 45,
          defaultSets: 3,
          description: 'Bodyweight tricep exercise',
        ),
        Exercise(
          id: 'arms_hammer_curls',
          name: 'Hammer Curls',
          category: 'Arms',
          defaultWorkTime: 35,
          defaultRestTime: 40,
          defaultSets: 3,
          description: 'Forearm and bicep focus',
        ),
        Exercise(
          id: 'arms_tricep_pushdown',
          name: 'Tricep Pushdown',
          category: 'Arms',
          defaultWorkTime: 35,
          defaultRestTime: 40,
          defaultSets: 3,
          description: 'Cable tricep isolation',
        ),
        Exercise(
          id: 'arms_preacher_curl',
          name: 'Preacher Curl',
          category: 'Arms',
          defaultWorkTime: 35,
          defaultRestTime: 40,
          defaultSets: 3,
          description: 'Strict bicep isolation',
        ),
      ],
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // SHOULDERS
    // ═══════════════════════════════════════════════════════════════════════════
    ExerciseCategory(
      name: 'Shoulders',
      icon: '🏋️',
      exercises: [
        Exercise(
          id: 'shoulders_overhead_press',
          name: 'Overhead Press',
          category: 'Shoulders',
          defaultWorkTime: 45,
          defaultRestTime: 60,
          defaultSets: 4,
          description: 'Primary shoulder builder',
        ),
        Exercise(
          id: 'shoulders_lateral_raises',
          name: 'Lateral Raises',
          category: 'Shoulders',
          defaultWorkTime: 35,
          defaultRestTime: 40,
          defaultSets: 3,
          description: 'Side delt isolation',
        ),
        Exercise(
          id: 'shoulders_front_raises',
          name: 'Front Raises',
          category: 'Shoulders',
          defaultWorkTime: 35,
          defaultRestTime: 40,
          defaultSets: 3,
          description: 'Front delt isolation',
        ),
        Exercise(
          id: 'shoulders_rear_delt_fly',
          name: 'Rear Delt Fly',
          category: 'Shoulders',
          defaultWorkTime: 35,
          defaultRestTime: 40,
          defaultSets: 3,
          description: 'Rear delt isolation',
        ),
        Exercise(
          id: 'shoulders_shrugs',
          name: 'Shrugs',
          category: 'Shoulders',
          defaultWorkTime: 30,
          defaultRestTime: 35,
          defaultSets: 3,
          description: 'Trap builder',
        ),
      ],
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // CORE
    // ═══════════════════════════════════════════════════════════════════════════
    ExerciseCategory(
      name: 'Core',
      icon: '🎯',
      exercises: [
        Exercise(
          id: 'core_planks',
          name: 'Planks',
          category: 'Core',
          defaultWorkTime: 60,
          defaultRestTime: 30,
          defaultSets: 3,
          description: 'Isometric core hold',
        ),
        Exercise(
          id: 'core_crunches',
          name: 'Crunches',
          category: 'Core',
          defaultWorkTime: 45,
          defaultRestTime: 30,
          defaultSets: 3,
          description: 'Upper ab focus',
        ),
        Exercise(
          id: 'core_russian_twists',
          name: 'Russian Twists',
          category: 'Core',
          defaultWorkTime: 40,
          defaultRestTime: 30,
          defaultSets: 3,
          description: 'Oblique rotations',
        ),
        Exercise(
          id: 'core_leg_raises',
          name: 'Leg Raises',
          category: 'Core',
          defaultWorkTime: 40,
          defaultRestTime: 30,
          defaultSets: 3,
          description: 'Lower ab focus',
        ),
        Exercise(
          id: 'core_mountain_climbers',
          name: 'Mountain Climbers',
          category: 'Core',
          defaultWorkTime: 30,
          defaultRestTime: 20,
          defaultSets: 4,
          description: 'Dynamic core cardio',
        ),
        Exercise(
          id: 'core_dead_bug',
          name: 'Dead Bug',
          category: 'Core',
          defaultWorkTime: 45,
          defaultRestTime: 30,
          defaultSets: 3,
          description: 'Core stability exercise',
        ),
      ],
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // CARDIO
    // ═══════════════════════════════════════════════════════════════════════════
    ExerciseCategory(
      name: 'Cardio',
      icon: '🏃',
      exercises: [
        Exercise(
          id: 'cardio_jumping_jacks',
          name: 'Jumping Jacks',
          category: 'Cardio',
          defaultWorkTime: 45,
          defaultRestTime: 15,
          defaultSets: 4,
          description: 'Classic cardio warmup',
        ),
        Exercise(
          id: 'cardio_burpees',
          name: 'Burpees',
          category: 'Cardio',
          defaultWorkTime: 30,
          defaultRestTime: 30,
          defaultSets: 4,
          description: 'Full body cardio blast',
        ),
        Exercise(
          id: 'cardio_high_knees',
          name: 'High Knees',
          category: 'Cardio',
          defaultWorkTime: 30,
          defaultRestTime: 20,
          defaultSets: 4,
          description: 'Running in place',
        ),
        Exercise(
          id: 'cardio_box_jumps',
          name: 'Box Jumps',
          category: 'Cardio',
          defaultWorkTime: 35,
          defaultRestTime: 30,
          defaultSets: 4,
          description: 'Plyometric power',
        ),
        Exercise(
          id: 'cardio_jump_rope',
          name: 'Jump Rope',
          category: 'Cardio',
          defaultWorkTime: 60,
          defaultRestTime: 30,
          defaultSets: 3,
          description: 'Classic cardio conditioning',
        ),
        Exercise(
          id: 'cardio_sprint_intervals',
          name: 'Sprint Intervals',
          category: 'Cardio',
          defaultWorkTime: 20,
          defaultRestTime: 40,
          defaultSets: 6,
          description: 'High intensity sprints',
        ),
      ],
    ),
  ];

  static List<Exercise> getAllExercises() {
    return categories.expand((category) => category.exercises).toList();
  }

  static Exercise? getExerciseById(String id) {
    try {
      return getAllExercises().firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  static ExerciseCategory? getCategoryByName(String name) {
    try {
      return categories.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }
}
