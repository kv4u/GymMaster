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
  late AnimationController _phaseTransitionController;
  late Animation<double> _phaseScaleAnimation;

  int _totalCompletedSets = 0;

  WorkoutItem get _currentExercise =>
      widget.session.exercises[_currentExerciseIndex];
  bool get _isLastExercise =>
      _currentExerciseIndex >= widget.session.exercises.length - 1;
  bool get _isLastSet => _currentSet >= _currentExercise.sets;

  @override
  void initState() {
    super.initState();
    _currentSeconds = 3;
    _startedAt = DateTime.now();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _phaseTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _phaseScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _phaseTransitionController,
        curve: Curves.elasticOut,
      ),
    );

    _phaseTransitionController.forward();
    _startReadyCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    _phaseTransitionController.dispose();
    super.dispose();
  }

  void _animatePhaseChange() {
    _phaseTransitionController.forward(from: 0);
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
    _animatePhaseChange();
    setState(() {
      _phase = SessionPhase.work;
      _currentSeconds = _currentExercise.workTime;
    });
    _progressController.duration = Duration(seconds: _currentExercise.workTime);
    _progressController.forward(from: 0);
    _startTimer();
  }

  void _startRestPhase() {
    if (_isLastSet) {
      if (_isLastExercise) {
        _completeSession();
        return;
      } else {
        _startExerciseRestPhase();
        return;
      }
    }

    _animatePhaseChange();
    setState(() {
      _phase = SessionPhase.rest;
      _currentSeconds = _currentExercise.restTime;
    });
    _progressController.duration = Duration(seconds: _currentExercise.restTime);
    _progressController.forward(from: 0);
    _startTimer();
  }

  void _startExerciseRestPhase() {
    _animatePhaseChange();
    setState(() {
      _phase = SessionPhase.exerciseRest;
      _currentSeconds = widget.session.restBetweenExercises;
    });
    _progressController.duration =
        Duration(seconds: widget.session.restBetweenExercises);
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
    _animatePhaseChange();
    setState(() => _phase = SessionPhase.completed);

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
      _pulseController.stop();
    } else {
      _progressController.forward();
      _pulseController.repeat(reverse: true);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('End Session?', style: theme.textTheme.headlineSmall),
        content: Text(
          'Your progress will be saved to history.',
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
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getPhaseColor().withValues(alpha: 0.2),
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
        _buildTopBar(theme),

        const SizedBox(height: 16),

        // Exercise info card
        if (_phase != SessionPhase.ready)
          _buildExerciseInfo(theme),

        const Spacer(),

        // Main timer section
        ScaleTransition(
          scale: _phaseScaleAnimation,
          child: Column(
            children: [
              // Phase indicator
              _buildPhaseIndicator(theme),
              const SizedBox(height: 32),
              // Timer circle
              _buildTimerCircle(theme),
            ],
          ),
        ),

        const Spacer(),

        // Progress section
        _buildProgressSection(theme),

        const SizedBox(height: 24),

        // Controls
        if (_phase != SessionPhase.ready) _buildControls(theme),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _confirmExit,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.close_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 22,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.session.name.toUpperCase(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Exercise ${_currentExerciseIndex + 1} of ${widget.session.exercises.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 44), // Balance
        ],
      ),
    );
  }

  Widget _buildExerciseInfo(ThemeData theme) {
    if (_phase == SessionPhase.exerciseRest) {
      return _buildNextExercisePreview(theme);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getPhaseColor().withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getPhaseColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              color: _getPhaseColor(),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentExercise.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_currentExercise.workTime}s work • ${_currentExercise.restTime}s rest',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _getPhaseColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'SET $_currentSet/${_currentExercise.sets}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: _getPhaseColor(),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextExercisePreview(ThemeData theme) {
    final nextExercise = widget.session.exercises[_currentExerciseIndex + 1];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_forward_rounded, 
                color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Text(
                'NEXT EXERCISE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nextExercise.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${nextExercise.sets} sets • ${nextExercise.workTime}s work • ${nextExercise.restTime}s rest',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator(ThemeData theme) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: _getPhaseColor().withValues(
              alpha: 0.15 + (_pulseController.value * 0.1),
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _getPhaseColor().withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getPhaseColor().withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: _pulseController.value * 5,
              ),
            ],
          ),
          child: Text(
            _getPhaseText(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: _getPhaseColor(),
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerCircle(ThemeData theme) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 240 + (_pulseController.value * 10),
                height: 240 + (_pulseController.value * 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getPhaseColor().withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              );
            },
          ),
          // Progress ring
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(240, 240),
                painter: _ModernTimerPainter(
                  progress: _phase == SessionPhase.ready
                      ? 1.0
                      : _progressController.value,
                  color: _getPhaseColor(),
                  backgroundColor: theme.colorScheme.surface,
                  strokeWidth: 10,
                ),
              );
            },
          ),
          // Time display
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(_currentSeconds),
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  color: _getPhaseColor(),
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'seconds',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Overall progress bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Session Progress',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '$_totalCompletedSets / ${widget.session.totalSets} sets',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _totalCompletedSets / widget.session.totalSets,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Exercise dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.session.exercises.length, (index) {
              final isCompleted = index < _currentExerciseIndex;
              final isCurrent = index == _currentExerciseIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 32 : 16,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : isCurrent
                          ? _getPhaseColor()
                          : theme.colorScheme.surface,
                  border: !isCompleted && !isCurrent
                      ? Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        )
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Skip button
          _ControlButton(
            icon: Icons.skip_next_rounded,
            label: 'SKIP',
            onTap: _skipPhase,
            isPrimary: false,
          ),
          const SizedBox(width: 32),
          // Pause/Play button
          _ControlButton(
            icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            label: _isPaused ? 'RESUME' : 'PAUSE',
            onTap: _togglePause,
            isPrimary: true,
            color: _isPaused ? theme.colorScheme.primary : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedView() {
    final theme = Theme.of(context);
    final duration = DateTime.now().difference(_startedAt);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          // Trophy animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          Text(
            'WORKOUT COMPLETE!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.session.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 40),

          // Stats grid
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _CompletedStatCard(
                        icon: Icons.fitness_center_rounded,
                        value: '${widget.session.exercises.length}',
                        label: 'Exercises',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompletedStatCard(
                        icon: Icons.repeat_rounded,
                        value: '${widget.session.totalSets}',
                        label: 'Sets',
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CompletedStatCard(
                        icon: Icons.timer_rounded,
                        value: '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        label: 'Duration',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompletedStatCard(
                        icon: Icons.local_fire_department_rounded,
                        value: '~${(duration.inMinutes * 6.5).round()}',
                        label: 'Calories',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'DONE',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
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
}

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final Color? color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.color,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.color ?? theme.colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Column(
          children: [
            Container(
              width: widget.isPrimary ? 80 : 60,
              height: widget.isPrimary ? 80 : 60,
              decoration: BoxDecoration(
                color: widget.isPrimary
                    ? buttonColor
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: widget.isPrimary
                    ? null
                    : Border.all(
                        color: buttonColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                boxShadow: widget.isPrimary
                    ? [
                        BoxShadow(
                          color: buttonColor.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                size: widget.isPrimary ? 36 : 26,
                color: widget.isPrimary
                    ? Colors.white
                    : buttonColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _CompletedStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernTimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _ModernTimerPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

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
  bool shouldRepaint(covariant _ModernTimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
