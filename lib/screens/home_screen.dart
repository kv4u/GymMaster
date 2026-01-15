import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'exercise_library_screen.dart';
import 'simple_mode_screen.dart';
import 'presets_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.colorScheme.surface,
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GYMMASTER',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Workout Timer',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                      icon: Icon(
                        Icons.settings_outlined,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Main buttons
                Expanded(
                  child: Column(
                    children: [
                      // Exercise Library Button
                      Expanded(
                        child: _MainMenuCard(
                          icon: Icons.fitness_center,
                          title: 'EXERCISE LIBRARY',
                          subtitle: 'Choose from 35+ exercises',
                          color: theme.colorScheme.primary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ExerciseLibraryScreen(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Simple Mode Button
                      Expanded(
                        child: _MainMenuCard(
                          icon: Icons.timer_outlined,
                          title: 'SIMPLE MODE',
                          subtitle: 'Custom time & sets',
                          color: theme.colorScheme.secondary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SimpleModeScreen(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bottom row
                      Row(
                        children: [
                          // Saved Presets & Sessions
                          Expanded(
                            child: _SmallMenuCard(
                              icon: Icons.bookmark_outline,
                              title: 'SAVED',
                              count: provider.presets.length + provider.sessions.length,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PresetsScreen(),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // History
                          Expanded(
                            child: _SmallMenuCard(
                              icon: Icons.history,
                              title: 'HISTORY',
                              count: provider.history.length,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HistoryScreen(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        value: '${provider.totalWorkouts}',
                        label: 'Workouts',
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      _StatItem(
                        value: '${provider.totalSetsCompleted}',
                        label: 'Sets',
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      _StatItem(
                        value: '${provider.totalWorkoutTime.inMinutes}m',
                        label: 'Total Time',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MainMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MainMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 40, color: color),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;

  const _SmallMenuCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: theme.colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$count saved',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
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
