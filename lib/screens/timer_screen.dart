import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/workout_history.dart';
import '../providers/app_provider.dart';

enum TimerPhase { ready, work, rest, completed }

class TimerScreen extends StatefulWidget {
  final String workoutName;
  final int workTime;
  final int restTime;
  final int sets;

  const TimerScreen({
    super.key,
    required this.workoutName,
    required this.workTime,
    required this.restTime,
    required this.sets,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  late int _currentSeconds;
  int _currentSet = 1;
  TimerPhase _phase = TimerPhase.ready;
  bool _isPaused = false;
  late DateTime _startedAt;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _currentSeconds = 3; // Countdown before start
    _startedAt = DateTime.now();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Start ready countdown
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
      _phase = TimerPhase.work;
      _currentSeconds = widget.workTime;
    });
    _progressController.duration = Duration(seconds: widget.workTime);
    _progressController.forward(from: 0);
    _startTimer();
  }

  void _startRestPhase() {
    if (_currentSet >= widget.sets) {
      _completeWorkout();
      return;
    }

    setState(() {
      _phase = TimerPhase.rest;
      _currentSeconds = widget.restTime;
    });
    _progressController.duration = Duration(seconds: widget.restTime);
    _progressController.forward(from: 0);
    _startTimer();
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
        if (_phase == TimerPhase.work) {
          _startRestPhase();
        } else {
          setState(() => _currentSet++);
          _startWorkPhase();
        }
      }
    });
  }

  void _completeWorkout() {
    _timer?.cancel();
    setState(() => _phase = TimerPhase.completed);

    // Save to history
    final history = WorkoutHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutName: widget.workoutName,
      workTime: widget.workTime,
      restTime: widget.restTime,
      totalSets: widget.sets,
      completedSets: _currentSet,
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
    if (_phase == TimerPhase.work) {
      _startRestPhase();
    } else if (_phase == TimerPhase.rest) {
      setState(() => _currentSet++);
      _startWorkPhase();
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
        title: Text('End Workout?', style: theme.textTheme.headlineSmall),
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
              final history = WorkoutHistory(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                workoutName: widget.workoutName,
                workTime: widget.workTime,
                restTime: widget.restTime,
                totalSets: widget.sets,
                completedSets: _currentSet - 1,
                startedAt: _startedAt,
                completedAt: DateTime.now(),
                wasCompleted: false,
              );
              if (_currentSet > 1) {
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
      canPop: _phase == TimerPhase.completed,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _phase != TimerPhase.completed) {
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
            child: _phase == TimerPhase.completed
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
              Column(
                children: [
                  Text(
                    widget.workoutName,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    'Set $_currentSet of ${widget.sets}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 48), // Balance
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
            // Progress ring
            SizedBox(
              width: 280,
              height: 280,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _TimerRingPainter(
                      progress: _phase == TimerPhase.ready
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
            // Time text
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

        // Set progress dots
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.sets, (index) {
              final isCompleted = index < _currentSet - 1;
              final isCurrent = index == _currentSet - 1;
              return Container(
                width: isCurrent ? 16 : 12,
                height: isCurrent ? 16 : 12,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : isCurrent
                          ? _getPhaseColor()
                          : theme.colorScheme.surface,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 40),

        // Controls
        if (_phase != TimerPhase.ready)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Skip button
                _ControlButton(
                  icon: Icons.skip_next,
                  label: 'SKIP',
                  onTap: _skipPhase,
                ),
                // Pause/Play button
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
          // Success icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 80,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'WORKOUT COMPLETE!',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.workoutName,
            style: theme.textTheme.titleLarge,
          ),

          const SizedBox(height: 40),

          // Stats
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _CompletedStat(
                  icon: Icons.repeat,
                  label: 'Sets Completed',
                  value: '${widget.sets}',
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
                  label: 'Estimated Calories',
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
      case TimerPhase.ready:
        return theme.colorScheme.secondary;
      case TimerPhase.work:
        return theme.colorScheme.primary;
      case TimerPhase.rest:
        return theme.colorScheme.secondary;
      case TimerPhase.completed:
        return theme.colorScheme.primary;
    }
  }

  String _getPhaseText() {
    switch (_phase) {
      case TimerPhase.ready:
        return 'GET READY';
      case TimerPhase.work:
        return 'WORK';
      case TimerPhase.rest:
        return 'REST';
      case TimerPhase.completed:
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
    // Rough estimate: ~5-8 cal per minute of workout
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

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
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
