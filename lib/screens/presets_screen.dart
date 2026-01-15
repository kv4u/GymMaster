import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_preset.dart';
import '../models/workout_session.dart';
import '../providers/app_provider.dart';
import 'timer_screen.dart';
import 'session_timer_screen.dart';

class PresetsScreen extends StatefulWidget {
  const PresetsScreen({super.key});

  @override
  State<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends State<PresetsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('SAVED WORKOUTS'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          indicatorColor: theme.colorScheme.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.list_alt, size: 18),
                  const SizedBox(width: 8),
                  Text('Sessions (${provider.sessions.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bookmark, size: 18),
                  const SizedBox(width: 8),
                  Text('Quick (${provider.presets.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Sessions tab
          _buildSessionsList(context, provider),
          // Quick presets tab
          _buildPresetsList(context, provider),
        ],
      ),
    );
  }

  Widget _buildSessionsList(BuildContext context, AppProvider provider) {
    final sessions = provider.sessions;

    if (sessions.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.list_alt,
        title: 'No Saved Sessions',
        subtitle: 'Create multi-exercise sessions\nin Simple Mode',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _SessionCard(
          session: session,
          onTap: () => _startSession(context, session),
          onDelete: () => _confirmDeleteSession(context, session),
        );
      },
    );
  }

  Widget _buildPresetsList(BuildContext context, AppProvider provider) {
    final presets = provider.presets;

    if (presets.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.bookmark_outline,
        title: 'No Quick Presets',
        subtitle: 'Quick presets are simple\nsingle-exercise timers',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final preset = presets[index];
        return _PresetCard(
          preset: preset,
          onTap: () => _startPreset(context, preset),
          onDelete: () => _confirmDeletePreset(context, preset),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _startSession(BuildContext context, WorkoutSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionTimerScreen(session: session),
      ),
    );
  }

  void _startPreset(BuildContext context, WorkoutPreset preset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          workoutName: preset.name,
          workTime: preset.workTime,
          restTime: preset.restTime,
          sets: preset.sets,
        ),
      ),
    );
  }

  void _confirmDeleteSession(BuildContext context, WorkoutSession session) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Session?', style: theme.textTheme.headlineSmall),
        content: Text(
          'Remove "${session.name}" (${session.exercises.length} exercises)?',
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
              context.read<AppProvider>().deleteSession(session.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePreset(BuildContext context, WorkoutPreset preset) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Preset?', style: theme.textTheme.headlineSmall),
        content: Text(
          'Remove "${preset.name}"?',
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
              context.read<AppProvider>().deletePreset(preset.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionCard({
    required this.session,
    required this.onTap,
    required this.onDelete,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.list_alt,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${session.exercises.length} exercises • ${session.totalSets} sets',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Exercise preview
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: session.exercises.take(4).map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      e.name,
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                }).toList(),
              ),
              if (session.exercises.length > 4)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${session.exercises.length - 4} more',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Total: ${session.formattedTotalDuration}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(session.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Created today';
    if (diff.inDays == 1) return 'Created yesterday';
    if (diff.inDays < 7) return 'Created ${diff.inDays} days ago';
    return 'Created ${date.day}/${date.month}/${date.year}';
  }
}

class _PresetCard extends StatelessWidget {
  final WorkoutPreset preset;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PresetCard({
    required this.preset,
    required this.onTap,
    required this.onDelete,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.bookmark,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Quick single-exercise timer',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
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
              Row(
                children: [
                  _PresetDetail(
                    icon: Icons.fitness_center,
                    label: 'Work',
                    value: preset.formattedWorkTime,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  _PresetDetail(
                    icon: Icons.pause_circle_outline,
                    label: 'Rest',
                    value: preset.formattedRestTime,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 16),
                  _PresetDetail(
                    icon: Icons.repeat,
                    label: 'Sets',
                    value: '${preset.sets}',
                    color: theme.colorScheme.primary,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      preset.formattedTotalDuration,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
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

class _PresetDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _PresetDetail({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
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
