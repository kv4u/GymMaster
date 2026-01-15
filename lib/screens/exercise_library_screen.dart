import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/exercises_data.dart';
import '../models/exercise.dart';
import '../providers/app_provider.dart';
import 'timer_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String? _selectedCategory;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();

    final categories = ExercisesData.categories;
    final filteredExercises = _getFilteredExercises();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('EXERCISE LIBRARY'),
        actions: [
          if (provider.favoriteExerciseIds.isNotEmpty)
            IconButton(
              onPressed: () => _showFavorites(context),
              icon: Icon(
                Icons.favorite,
                color: theme.colorScheme.secondary,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),

          // Category chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      label: 'All',
                      icon: '🔥',
                      isSelected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                  );
                }
                final category = categories[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryChip(
                    label: category.name,
                    icon: category.icon,
                    isSelected: _selectedCategory == category.name,
                    onTap: () => setState(() => _selectedCategory = category.name),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Exercise list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                return _ExerciseCard(
                  exercise: exercise,
                  isFavorite: provider.isFavorite(exercise.id),
                  onTap: () => _showExerciseDetails(context, exercise),
                  onFavorite: () => provider.toggleFavorite(exercise.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Exercise> _getFilteredExercises() {
    var exercises = ExercisesData.getAllExercises();

    if (_selectedCategory != null) {
      exercises = exercises
          .where((e) => e.category == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      exercises = exercises
          .where((e) =>
              e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return exercises;
  }

  void _showFavorites(BuildContext context) {
    final provider = context.read<AppProvider>();
    final favorites = ExercisesData.getAllExercises()
        .where((e) => provider.isFavorite(e.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '❤️ Favorites',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            if (favorites.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No favorites yet'),
                ),
              )
            else
              ...favorites.map((e) => ListTile(
                    title: Text(e.name),
                    subtitle: Text(e.category),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      _showExerciseDetails(context, e);
                    },
                  )),
          ],
        ),
      ),
    );
  }

  void _showExerciseDetails(BuildContext context, Exercise exercise) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ExerciseDetailSheet(exercise: exercise),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const _ExerciseCard({
    required this.exercise,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.defaultWorkTime}s work • ${exercise.defaultRestTime}s rest • ${exercise.defaultSets} sets',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseDetailSheet extends StatefulWidget {
  final Exercise exercise;

  const _ExerciseDetailSheet({required this.exercise});

  @override
  State<_ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<_ExerciseDetailSheet> {
  late int _workTime;
  late int _restTime;
  late int _sets;

  @override
  void initState() {
    super.initState();
    _workTime = widget.exercise.defaultWorkTime;
    _restTime = widget.exercise.defaultRestTime;
    _sets = widget.exercise.defaultSets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            widget.exercise.name,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            widget.exercise.category,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          if (widget.exercise.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.exercise.description!,
              style: theme.textTheme.bodyMedium,
            ),
          ],

          const SizedBox(height: 24),

          // Settings
          _TimeSetting(
            label: 'Work Time',
            value: _workTime,
            min: 10,
            max: 120,
            onChanged: (v) => setState(() => _workTime = v),
          ),
          const SizedBox(height: 16),
          _TimeSetting(
            label: 'Rest Time',
            value: _restTime,
            min: 5,
            max: 120,
            onChanged: (v) => setState(() => _restTime = v),
          ),
          const SizedBox(height: 16),
          _SetsSetting(
            value: _sets,
            onChanged: (v) => setState(() => _sets = v),
          ),

          const SizedBox(height: 24),

          // Total time
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Total: ${_formatTotalTime()}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimerScreen(
                      workoutName: widget.exercise.name,
                      workTime: _workTime,
                      restTime: _restTime,
                      sets: _sets,
                    ),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('START WORKOUT'),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatTotalTime() {
    final total = (_workTime + _restTime) * _sets - _restTime;
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '${minutes}m ${seconds}s';
  }
}

class _TimeSetting extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _TimeSetting({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.titleSmall),
            Text(
              '${value}s',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: (max - min) ~/ 5,
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}

class _SetsSetting extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _SetsSetting({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Sets', style: theme.textTheme.titleSmall),
        Row(
          children: [
            IconButton(
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
              icon: Icon(
                Icons.remove_circle_outline,
                color: theme.colorScheme.secondary,
              ),
            ),
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: value < 20 ? () => onChanged(value + 1) : null,
              icon: Icon(
                Icons.add_circle_outline,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
