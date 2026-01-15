import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_preset.dart';
import '../models/workout_history.dart';
import '../models/workout_session.dart';
import '../themes/app_themes.dart';

class AppProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.neonGym;
  List<WorkoutPreset> _presets = [];
  List<WorkoutSession> _sessions = [];
  List<WorkoutHistory> _history = [];
  List<String> _favoriteExerciseIds = [];
  bool _soundEnabled = true;

  AppThemeMode get themeMode => _themeMode;
  List<WorkoutPreset> get presets => _presets;
  List<WorkoutSession> get sessions => _sessions;
  List<WorkoutHistory> get history => _history;
  List<String> get favoriteExerciseIds => _favoriteExerciseIds;
  bool get soundEnabled => _soundEnabled;

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = AppThemeMode.values[themeIndex];

    // Load sound setting
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;

    // Load presets
    final presetsJson = prefs.getStringList('presets') ?? [];
    _presets = presetsJson
        .map((json) => WorkoutPreset.fromJsonString(json))
        .toList();

    // Load sessions
    final sessionsJson = prefs.getStringList('sessions') ?? [];
    _sessions = sessionsJson
        .map((json) => WorkoutSession.fromJsonString(json))
        .toList();

    // Load history
    final historyJson = prefs.getStringList('history') ?? [];
    _history = historyJson
        .map((json) => WorkoutHistory.fromJsonString(json))
        .toList();
    _history.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    // Load favorites
    _favoriteExerciseIds = prefs.getStringList('favorites') ?? [];

    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // THEME
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> setTheme(AppThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SOUND
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', enabled);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRESETS
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> addPreset(WorkoutPreset preset) async {
    _presets.add(preset);
    await _savePresets();
    notifyListeners();
  }

  Future<void> updatePreset(WorkoutPreset preset) async {
    final index = _presets.indexWhere((p) => p.id == preset.id);
    if (index != -1) {
      _presets[index] = preset;
      await _savePresets();
      notifyListeners();
    }
  }

  Future<void> deletePreset(String id) async {
    _presets.removeWhere((p) => p.id == id);
    await _savePresets();
    notifyListeners();
  }

  Future<void> _savePresets() async {
    final prefs = await SharedPreferences.getInstance();
    final presetsJson = _presets.map((p) => p.toJsonString()).toList();
    await prefs.setStringList('presets', presetsJson);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSIONS (Multi-exercise workouts)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> addSession(WorkoutSession session) async {
    _sessions.add(session);
    await _saveSessions();
    notifyListeners();
  }

  Future<void> updateSession(WorkoutSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
      await _saveSessions();
      notifyListeners();
    }
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    await _saveSessions();
    notifyListeners();
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = _sessions.map((s) => s.toJsonString()).toList();
    await prefs.setStringList('sessions', sessionsJson);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HISTORY
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> addHistory(WorkoutHistory history) async {
    _history.insert(0, history);
    // Keep only last 100 entries
    if (_history.length > 100) {
      _history = _history.sublist(0, 100);
    }
    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _history.map((h) => h.toJsonString()).toList();
    await prefs.setStringList('history', historyJson);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FAVORITES
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> toggleFavorite(String exerciseId) async {
    if (_favoriteExerciseIds.contains(exerciseId)) {
      _favoriteExerciseIds.remove(exerciseId);
    } else {
      _favoriteExerciseIds.add(exerciseId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteExerciseIds);
    notifyListeners();
  }

  bool isFavorite(String exerciseId) {
    return _favoriteExerciseIds.contains(exerciseId);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATS
  // ═══════════════════════════════════════════════════════════════════════════
  int get totalWorkouts => _history.length;
  
  int get completedWorkouts => _history.where((h) => h.wasCompleted).length;

  Duration get totalWorkoutTime {
    return _history.fold(
      Duration.zero,
      (sum, h) => sum + h.totalDuration,
    );
  }

  int get totalSetsCompleted {
    return _history.fold(0, (sum, h) => sum + h.completedSets);
  }
}
