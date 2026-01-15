import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/workout_session.dart';
import '../models/workout_history.dart';
import '../providers/app_provider.dart';

enum SessionPhase { ready, work, rest, exerciseRest, completed }

class SessionTimerScreen extends StatefulWidget {
  final WorkoutSession session;

  const SessionTimerScreen({super.key, required this.session});

  @override
  State<SessionTimerScreen> createState() => _SessionTimerScreenState();
}

class _SessionTimerScreenState extends State<SessionTimerScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  late int _currentSeconds;
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  SessionPhase _phase = SessionPhase.ready;
  bool _isPaused = false;
  late DateTime _startedAt;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  
  int _totalCompletedSets = 0;

  WorkoutItem get _currentExercise => widget.session.exercises[_currentExerciseIndex];
  bool get _isLastExercise => _currentExerciseIndex >= widget.session.exercises.length - 1;
  bool get _isLastSet => _currentSet >= _currentExercise.sets;

  @override
  void initState() {
    super.initState();
    _currentSeconds = 3;
    _startedAt = DateTime.now();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _startReadyCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startReadyCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds > 1) {
        setState(() => _currentSeconds--);
        _playBeep();
      } else {
        timer.cancel();
        _playBeep(isLong: true);
        _startWorkPhase();
      }
    });
  }

  void _startWorkPhase() {
    setState(() {
      _phase = SessionPhase.work;
      _currentSeconds = _currentExercise.workTime;
    });
    _progressController.duration = Duration(seconds: _currentExercise.workTime);
    _progressController.forward(from: 0);
    _startTimer();
  }

  void _startRestPhase() {
    // Check if this is the last set of this exercise
    if (_isLastSet) {
      // Check if this is the last exercise
      if (_isLastExercise) {
        _completeSession();
        return;
      } else {
        // Move to rest between exercises
        _startExerciseRestPhase();
        return;
      }
    }

    setState(() {
      _phase = SessionPhase.rest;
      _currentSeconds = _currentExercise.restTime;
    });
    _progressController.duration = Duration(seconds: _currentExercise.restTime);
    _progressController.forward(from: 0);
    _startTimer();
  }

  void _startExerciseRestPhase() {
    setState(() {
      _phase = SessionPhase.exerciseRest;
      _currentSeconds = widget.session.restBetweenExercises;
    });
    _progressController.duration = Duration(seconds: widget.session.restBetweenExercises);
    _progressController.forward(from: 0);
    _startTimer();
  }

  void _moveToNextExercise() {
    setState(() {
      _currentExerciseIndex++;
      _currentSet = 1;
    });
    _startWorkPhase();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      if (_currentSeconds > 1) {
        setState(() => _currentSeconds--);
        if (_currentSeconds <= 3) _playBeep();
      } else {
        timer.cancel();
        _playBeep(isLong: true);
        
        if (_phase == SessionPhase.work) {
          _totalCompletedSets++;
          _startRestPhase();
        } else if (_phase == SessionPhase.rest) {
          setState(() => _currentSet++);
          _startWorkPhase();
        } else if (_phase == SessionPhase.exerciseRest) {
          _moveToNextExercise();
        }
      }
    });
  }

  void _completeSession() {
    _timer?.cancel();
    _totalCompletedSets++;
    setState(() => _phase = SessionPhase.completed);

    // Save to history
    final history = WorkoutHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutName: widget.session.name,
      workTime: widget.session.exercises.fold(0, (sum, e) => sum + e.workTime) ~/
          widget.session.exercises.length,
      restTime: widget.session.exercises.fold(0, (sum, e) => sum + e.restTime) ~/
          widget.session.exercises.length,
      totalSets: widget.session.totalSets,
      completedSets: _totalCompletedSets,
      startedAt: _startedAt,
      completedAt: DateTime.now(),
      wasCompleted: true,
    );
    context.read<AppProvider>().addHistory(history);
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _progressController.stop();
    } else {
      _progressController.forward();
    }
  }

  void _skipPhase() {
    _timer?.cancel();
    if (_phase == SessionPhase.work) {
      _totalCompletedSets++;
      _startRestPhase();
    } else if (_phase == SessionPhase.rest) {
      setState(() => _currentSet++);
      _startWorkPhase();
    } else if (_phase == SessionPhase.exerciseRest) {
      _moveToNextExercise();
    }
  }

  void _playBeep({bool isLong = false}) {
    final provider = context.read<AppProvider>();
    if (provider.soundEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void _confirmExit() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('End Session?', style: theme.textTheme.headlineSmall),
        content: Text(
          'Your progress will be saved.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Save partial progress
              if (_totalCompletedSets > 0) {
                final history = WorkoutHistory(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  workoutName: widget.session.name,
                  workTime: _currentExercise.workTime,
                  restTime: _currentExercise.restTime,
                  totalSets: widget.session.totalSets,
                  completedSets: _totalCompletedSets,
                  startedAt: _startedAt,
                  completedAt: DateTime.now(),
                  wasCompleted: false,
                );
                context.read<AppProvider>().addHistory(history);
              }
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('End'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: _phase == SessionPhase.completed,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _phase != SessionPhase.completed) {
          _confirmExit();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getPhaseColor().withValues(alpha: 0.15),
                theme.scaffoldBackgroundColor,
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
          child: SafeArea(
            child: _phase == SessionPhase.completed
                ? _buildCompletedView()
                : _buildTimerView(),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerView() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _confirmExit,
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.session.name,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Exercise ${_currentExerciseIndex + 1}/${widget.session.exercises.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        // Current exercise name
        if (_phase != SessionPhase.ready && _phase != SessionPhase.exerciseRest)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fitness_center, 
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _currentExercise.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Set $_currentSet/${_currentExercise.sets}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Next exercise preview (during exercise rest)
        if (_phase == SessionPhase.exerciseRest && !_isLastExercise)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'NEXT EXERCISE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.session.exercises[_currentExerciseIndex + 1].name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.session.exercises[_currentExerciseIndex + 1].sets} sets • ${widget.session.exercises[_currentExerciseIndex + 1].workTime}s work',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

        const Spacer(),

        // Phase indicator
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _getPhaseColor().withValues(
                  alpha: 0.2 + (_pulseController.value * 0.1),
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: _getPhaseColor(),
                  width: 2,
                ),
              ),
              child: Text(
                _getPhaseText(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: _getPhaseColor(),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 40),

        // Timer display
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 280,
              height: 280,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _TimerRingPainter(
                      progress: _phase == SessionPhase.ready
                          ? 1.0
                          : _progressController.value,
                      color: _getPhaseColor(),
                      backgroundColor:
                          theme.colorScheme.surface.withValues(alpha: 0.5),
                    ),
                  );
                },
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(_currentSeconds),
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: _getPhaseColor(),
                  ),
                ),
                Text(
                  'seconds',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),

        const Spacer(),

        // Overall progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overall Progress',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '$_totalCompletedSets/${widget.session.totalSets} sets',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _totalCompletedSets / widget.session.totalSets,
                backgroundColor: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Exercise progress dots
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.session.exercises.length, (index) {
              final isCompleted = index < _currentExerciseIndex;
              final isCurrent = index == _currentExerciseIndex;
              return Container(
                width: isCurrent ? 40 : 24,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : isCurrent
                          ? _getPhaseColor()
                          : theme.colorScheme.surface,
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 40),

        // Controls
        if (_phase != SessionPhase.ready)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ControlButton(
                  icon: Icons.skip_next,
                  label: 'SKIP',
                  onTap: _skipPhase,
                ),
                _ControlButton(
                  icon: _isPaused ? Icons.play_arrow : Icons.pause,
                  label: _isPaused ? 'RESUME' : 'PAUSE',
                  isPrimary: true,
                  onTap: _togglePause,
                ),
              ],
            ),
          ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCompletedView() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              size: 80,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'SESSION COMPLETE!',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.session.name,
            style: theme.textTheme.titleLarge,
          ),

          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _CompletedStat(
                  icon: Icons.fitness_center,
                  label: 'Exercises Completed',
                  value: '${widget.session.exercises.length}',
                ),
                const SizedBox(height: 16),
                _CompletedStat(
                  icon: Icons.repeat,
                  label: 'Total Sets',
                  value: '${widget.session.totalSets}',
                ),
                const SizedBox(height: 16),
                _CompletedStat(
                  icon: Icons.timer,
                  label: 'Total Time',
                  value: _formatDuration(DateTime.now().difference(_startedAt)),
                ),
                const SizedBox(height: 16),
                _CompletedStat(
                  icon: Icons.local_fire_department,
                  label: 'Est. Calories',
                  value: '~${_estimateCalories()} cal',
                ),
              ],
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('FINISH'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPhaseColor() {
    final theme = Theme.of(context);
    switch (_phase) {
      case SessionPhase.ready:
        return theme.colorScheme.secondary;
      case SessionPhase.work:
        return theme.colorScheme.primary;
      case SessionPhase.rest:
        return theme.colorScheme.secondary;
      case SessionPhase.exerciseRest:
        return Colors.orange;
      case SessionPhase.completed:
        return theme.colorScheme.primary;
    }
  }

  String _getPhaseText() {
    switch (_phase) {
      case SessionPhase.ready:
        return 'GET READY';
      case SessionPhase.work:
        return 'WORK';
      case SessionPhase.rest:
        return 'REST';
      case SessionPhase.exerciseRest:
        return 'NEXT UP';
      case SessionPhase.completed:
        return 'DONE';
    }
  }

  String _formatTime(int seconds) {
    if (seconds >= 60) {
      final mins = seconds ~/ 60;
      final secs = seconds % 60;
      return '$mins:${secs.toString().padLeft(2, '0')}';
    }
    return '$seconds';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  int _estimateCalories() {
    final duration = DateTime.now().difference(_startedAt);
    return (duration.inMinutes * 6.5).round();
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: isPrimary ? 80 : 60,
            height: isPrimary ? 80 : 60,
            decoration: BoxDecoration(
              color: isPrimary
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: isPrimary
                  ? null
                  : Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      width: 2,
                    ),
            ),
            child: Icon(
              icon,
              size: isPrimary ? 40 : 28,
              color: isPrimary
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CompletedStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyLarge),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * (1 - progress),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
