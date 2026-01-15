import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_session.dart';
import '../providers/app_provider.dart';
import 'session_timer_screen.dart';

class SimpleModeScreen extends StatefulWidget {
  const SimpleModeScreen({super.key});

  @override
  State<SimpleModeScreen> createState() => _SimpleModeScreenState();
}

class _SimpleModeScreenState extends State<SimpleModeScreen> {
  final List<WorkoutItem> _exercises = [];
  int _restBetweenExercises = 60;
  String _sessionName = 'My Workout';

  @override
  void initState() {
    super.initState();
    // Start with one exercise
    _addExercise();
  }

  void _addExercise() {
    setState(() {
      _exercises.add(WorkoutItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Exercise ${_exercises.length + 1}',
      ));
    });
  }

  void _removeExercise(int index) {
    if (_exercises.length > 1) {
      setState(() {
        _exercises.removeAt(index);
      });
    }
  }

  void _updateExercise(int index, WorkoutItem updated) {
    setState(() {
      _exercises[index] = updated;
    });
  }

  int get _totalSets => _exercises.fold(0, (sum, e) => sum + e.sets);

  int get _totalDuration {
    if (_exercises.isEmpty) return 0;
    int total = _exercises.fold(0, (sum, e) => sum + e.totalDuration);
    total += _restBetweenExercises * (_exercises.length - 1);
    return total;
  }

  String get _formattedTotalDuration {
    final total = _totalDuration;
    final minutes = total ~/ 60;
    final seconds = total % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('BUILD WORKOUT'),
        actions: [
          IconButton(
            onPressed: () => _showSaveSessionDialog(context),
            icon: Icon(
              Icons.bookmark_add_outlined,
              color: theme.colorScheme.primary,
            ),
            tooltip: 'Save Session',
          ),
        ],
      ),
      body: Column(
        children: [
          // Session summary header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      icon: Icons.fitness_center,
                      value: '${_exercises.length}',
                      label: 'Exercises',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    _SummaryItem(
                      icon: Icons.repeat,
                      value: '$_totalSets',
                      label: 'Total Sets',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    _SummaryItem(
                      icon: Icons.timer,
                      value: _formattedTotalDuration,
                      label: 'Duration',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Rest between exercises
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.swap_horiz,
                      size: 18,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rest between exercises: ',
                      style: theme.textTheme.bodySmall,
                    ),
                    GestureDetector(
                      onTap: () => _showRestBetweenExercisesDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_restBetweenExercises}s',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Exercise list
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _exercises.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _exercises.removeAt(oldIndex);
                  _exercises.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                return _ExerciseCard(
                  key: ValueKey(_exercises[index].id),
                  index: index,
                  exercise: _exercises[index],
                  canDelete: _exercises.length > 1,
                  onUpdate: (updated) => _updateExercise(index, updated),
                  onDelete: () => _removeExercise(index),
                );
              },
            ),
          ),

          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Add exercise button
                OutlinedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('ADD EXERCISE'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 12),
                // Start button
                ElevatedButton(
                  onPressed: _exercises.isNotEmpty ? _startWorkout : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'START SESSION',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startWorkout() {
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _sessionName,
      exercises: _exercises,
      createdAt: DateTime.now(),
      restBetweenExercises: _restBetweenExercises,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionTimerScreen(session: session),
      ),
    );
  }

  void _showRestBetweenExercisesDialog(BuildContext context) {
    final theme = Theme.of(context);
    int tempRest = _restBetweenExercises;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Rest Between Exercises', style: theme.textTheme.headlineSmall),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${tempRest}s',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: tempRest.toDouble(),
                min: 15,
                max: 180,
                divisions: 33,
                onChanged: (v) => setDialogState(() => tempRest = v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('15s', style: theme.textTheme.bodySmall),
                  Text('180s', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _restBetweenExercises = tempRest);
                Navigator.pop(context);
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveSessionDialog(BuildContext context) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: _sessionName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Save Session', style: theme.textTheme.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Save this ${_exercises.length}-exercise session:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Session name',
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final session = WorkoutSession(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: controller.text.trim(),
                  exercises: _exercises.map((e) => e.copyWith()).toList(),
                  createdAt: DateTime.now(),
                  restBetweenExercises: _restBetweenExercises,
                );
                context.read<AppProvider>().addSession(session);
                setState(() => _sessionName = controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Session "${session.name}" saved!'),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final int index;
  final WorkoutItem exercise;
  final bool canDelete;
  final ValueChanged<WorkoutItem> onUpdate;
  final VoidCallback onDelete;

  const _ExerciseCard({
    super.key,
    required this.index,
    required this.exercise,
    required this.canDelete,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Drag handle
                Icon(
                  Icons.drag_handle,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 8),
                // Exercise number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Exercise name (editable) - now looks like a button
                Expanded(
                  child: InkWell(
                    onTap: () => _showEditNameDialog(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.edit,
                            size: 16,
                            color: theme.colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                if (canDelete)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Settings row - Now with clear editable buttons
            Row(
              children: [
                // Work time
                Expanded(
                  child: _EditableSettingButton(
                    icon: Icons.fitness_center,
                    label: 'WORK',
                    value: '${exercise.workTime}s',
                    color: theme.colorScheme.primary,
                    onTap: () => _showTimeDialog(context, 'Work Time', exercise.workTime, 10, 180, (v) {
                      onUpdate(exercise.copyWith(workTime: v));
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                // Rest time
                Expanded(
                  child: _EditableSettingButton(
                    icon: Icons.pause_circle_outline,
                    label: 'REST',
                    value: '${exercise.restTime}s',
                    color: theme.colorScheme.secondary,
                    onTap: () => _showTimeDialog(context, 'Rest Time', exercise.restTime, 5, 120, (v) {
                      onUpdate(exercise.copyWith(restTime: v));
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                // Sets
                Expanded(
                  child: _EditableSettingButton(
                    icon: Icons.repeat,
                    label: 'SETS',
                    value: '${exercise.sets}',
                    color: theme.colorScheme.primary,
                    onTap: () => _showSetsDialog(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Total duration bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Total: ${exercise.formattedTotalDuration}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: exercise.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Exercise Name', style: theme.textTheme.headlineSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g., Bench Press',
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onUpdate(exercise.copyWith(name: controller.text.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTimeDialog(
    BuildContext context,
    String title,
    int currentValue,
    int min,
    int max,
    ValueChanged<int> onChanged,
  ) {
    final theme = Theme.of(context);
    int tempValue = currentValue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: theme.textTheme.headlineSmall),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${tempValue}s',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: tempValue.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: (max - min) ~/ 5,
                onChanged: (v) => setDialogState(() => tempValue = v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${min}s', style: theme.textTheme.bodySmall),
                  Text('${max}s', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onChanged(tempValue);
                Navigator.pop(context);
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetsDialog(BuildContext context) {
    final theme = Theme.of(context);
    int tempSets = exercise.sets;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Number of Sets', style: theme.textTheme.headlineSmall),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: tempSets > 1
                    ? () => setDialogState(() => tempSets--)
                    : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: theme.colorScheme.secondary,
                  size: 36,
                ),
              ),
              Container(
                width: 80,
                alignment: Alignment.center,
                child: Text(
                  '$tempSets',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: tempSets < 20
                    ? () => setDialogState(() => tempSets++)
                    : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 36,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onUpdate(exercise.copyWith(sets: tempSets));
                Navigator.pop(context);
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Editable setting button with clear visual affordance
class _EditableSettingButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _EditableSettingButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Label at top
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              // Icon and value
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Edit hint
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 12,
                    color: color.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'tap to edit',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: color.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
