import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../themes/app_themes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          Text(
            'APPEARANCE',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 16),

          ...AppThemeMode.values.map((mode) => _ThemeOption(
                mode: mode,
                isSelected: provider.themeMode == mode,
                onTap: () => provider.setTheme(mode),
              )),

          const SizedBox(height: 32),

          // Sound Section
          Text(
            'AUDIO',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 16),

          Card(
            child: SwitchListTile(
              title: Text(
                'Sound & Vibration',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Beeps at phase transitions',
                style: theme.textTheme.bodySmall,
              ),
              secondary: Icon(
                provider.soundEnabled ? Icons.volume_up : Icons.volume_off,
                color: theme.colorScheme.primary,
              ),
              value: provider.soundEnabled,
              onChanged: (value) => provider.setSoundEnabled(value),
              activeColor: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 32),

          // About Section
          Text(
            'ABOUT',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'GymMaster',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your personal workout timer with exercise library and custom presets.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Data management
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.bookmark,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    'Saved Presets',
                    style: theme.textTheme.titleMedium,
                  ),
                  trailing: Text(
                    '${provider.presets.length}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Divider(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  height: 1,
                ),
                ListTile(
                  leading: Icon(
                    Icons.history,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    'Workout History',
                    style: theme.textTheme.titleMedium,
                  ),
                  trailing: Text(
                    '${provider.history.length}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Divider(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  height: 1,
                ),
                ListTile(
                  leading: Icon(
                    Icons.favorite,
                    color: theme.colorScheme.secondary,
                  ),
                  title: Text(
                    'Favorite Exercises',
                    style: theme.textTheme.titleMedium,
                  ),
                  trailing: Text(
                    '${provider.favoriteExerciseIds.length}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final AppThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeData = AppThemes.getTheme(mode);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Theme preview colors
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: themeData.scaffoldBackgroundColor,
                  border: Border.all(
                    color: themeData.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 8,
                      decoration: BoxDecoration(
                        color: themeData.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height: 6,
                      decoration: BoxDecoration(
                        color: themeData.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppThemes.getThemeEmoji(mode),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppThemes.getThemeName(mode),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getThemeDescription(mode),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.neonGym:
        return 'Dark theme with electric cyan and hot pink';
      case AppThemeMode.cleanMinimal:
        return 'Light, calm and focused design';
      case AppThemeMode.sportyEnergy:
        return 'Vibrant purple with lime green energy';
    }
  }
}
