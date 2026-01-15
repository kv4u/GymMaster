import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/workout_history.dart';
import '../providers/app_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final history = provider.history;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('WORKOUT HISTORY'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              onPressed: () => _confirmClearHistory(context),
              icon: Icon(
                Icons.delete_sweep,
                color: theme.colorScheme.error.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
      body: history.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                // Stats summary
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                        theme.colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatSummary(
                        icon: Icons.fitness_center,
                        value: '${provider.totalWorkouts}',
                        label: 'Workouts',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      _StatSummary(
                        icon: Icons.check_circle_outline,
                        value: '${provider.completedWorkouts}',
                        label: 'Completed',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      _StatSummary(
                        icon: Icons.repeat,
                        value: '${provider.totalSetsCompleted}',
                        label: 'Sets',
                      ),
                    ],
                  ),
                ),

                // History list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return _HistoryCard(history: item);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Workout History',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first workout\nto see it here',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear History?', style: theme.textTheme.headlineSmall),
        content: Text(
          'This will permanently delete all workout history.',
          style: theme.textTheme.bodyMedium,
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
              context.read<AppProvider>().clearHistory();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _StatSummary extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatSummary({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final WorkoutHistory history;

  const _HistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: history.wasCompleted
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : theme.colorScheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    history.wasCompleted
                        ? Icons.check_circle
                        : Icons.cancel_outlined,
                    color: history.wasCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.workoutName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateFormat.format(history.completedAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: history.wasCompleted
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : theme.colorScheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    history.wasCompleted ? 'Completed' : 'Partial',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: history.wasCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _HistoryDetail(
                  icon: Icons.repeat,
                  value: '${history.completedSets}/${history.totalSets}',
                  label: 'Sets',
                ),
                const SizedBox(width: 24),
                _HistoryDetail(
                  icon: Icons.timer_outlined,
                  value: history.formattedDuration,
                  label: 'Duration',
                ),
                const SizedBox(width: 24),
                _HistoryDetail(
                  icon: Icons.fitness_center,
                  value: '${history.workTime}s',
                  label: 'Work',
                ),
                const SizedBox(width: 24),
                _HistoryDetail(
                  icon: Icons.pause,
                  value: '${history.restTime}s',
                  label: 'Rest',
                ),
              ],
            ),
            if (!history.wasCompleted) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: history.completionRate,
                backgroundColor: theme.colorScheme.error.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.error),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryDetail extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _HistoryDetail({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
