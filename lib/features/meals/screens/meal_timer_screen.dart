import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../plans/models/recipe.dart';
import '../utils/recipe_duration.dart';
import '../widgets/meal_complete_sheet.dart';

class MealTimerScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const MealTimerScreen({super.key, required this.recipe});

  @override
  ConsumerState<MealTimerScreen> createState() => _MealTimerScreenState();
}

class _MealTimerScreenState extends ConsumerState<MealTimerScreen> {
  late Duration _total_duration;
  late Duration _remaining;
  Timer? _timer;
  bool _is_running = false;
  bool _is_finished = false;
  bool _completion_handled = false;

  @override
  void initState() {
    super.initState();
    _total_duration = parseRecipeDuration(widget.recipe.time);
    _remaining = _total_duration;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _is_running = true;
      _is_finished = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 1) {
        _timer?.cancel();
        setState(() {
          _remaining = Duration.zero;
          _is_running = false;
          _is_finished = true;
        });
        _showCompleteFlow();
        return;
      }
      setState(() {
        _remaining -= const Duration(seconds: 1);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _is_running = false;
    });
  }

  Future<void> _leaveWithoutCompleting() async {
    _timer?.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _showCompleteFlow() async {
    if (_completion_handled || !mounted) return;
    _completion_handled = true;
    _timer?.cancel();
    setState(() {
      _is_running = false;
      _is_finished = true;
    });
    await showMealCompleteSheet(context, widget.recipe);
    if (mounted) Navigator.of(context).pop();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _progress {
    if (_total_duration.inSeconds == 0) return 0;
    return 1 - (_remaining.inSeconds / _total_duration.inSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (did_pop, _) async {
        if (did_pop) return;
        await _leaveWithoutCompleting();
      },
      child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: _leaveWithoutCompleting,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Meal timer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 32),
              Text(recipe.emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                recipe.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                recipe.time,
                style: TextStyle(color: recipe.accent_color, fontSize: 14),
              ),
              const Spacer(),
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: _progress.clamp(0.0, 1.0),
                        strokeWidth: 10,
                        backgroundColor: const Color(0xFF1A1A1A),
                        color: recipe.accent_color,
                      ),
                    ),
                    Text(
                      _formatDuration(_remaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_is_finished)
                const Text(
                  'Time\'s up! 🎉',
                  style: TextStyle(
                    color: Color(0xFF1DB954),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else if (!_is_running && _remaining < _total_duration)
                const Text(
                  'Paused',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _is_running ? _stopTimer : _startTimer,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF2A2A2A)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(_is_running ? 'Stop' : 'Resume'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showCompleteFlow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: recipe.accent_color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Complete',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
