import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/health_profile_provider.dart';

class SleepCycleScreen extends ConsumerStatefulWidget {
  const SleepCycleScreen({super.key});

  @override
  ConsumerState<SleepCycleScreen> createState() => _SleepCycleScreenState();
}

class _SleepCycleScreenState extends ConsumerState<SleepCycleScreen> {
  double _sleep_hours = 7;
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wake_time = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    final saved = ref.read(healthProfileProvider).sleep_hours;
    if (saved != null) {
      _sleep_hours = saved;
    }
  }

  Future<void> _pickTime({required bool is_bedtime}) async {
    final initial = is_bedtime ? _bedtime : _wake_time;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0A84FF),
              surface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (is_bedtime) {
        _bedtime = picked;
      } else {
        _wake_time = picked;
      }
      _syncHoursFromTimes();
    });
  }

  void _syncHoursFromTimes() {
    final bed_minutes = _bedtime.hour * 60 + _bedtime.minute;
    var wake_minutes = _wake_time.hour * 60 + _wake_time.minute;
    if (wake_minutes <= bed_minutes) {
      wake_minutes += 24 * 60;
    }
    final diff = (wake_minutes - bed_minutes) / 60.0;
    _sleep_hours = diff.clamp(4.0, 12.0);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _save() async {
    await ref.read(healthProfileProvider.notifier).saveSleepHours(_sleep_hours);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sleep cycle saved'),
          backgroundColor: Color(0xFF1DB954),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sleep cycle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('🌙', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 8),
                    Text(
                      _sleep_hours.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Color(0xFF0A84FF),
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'hrs',
                        style: TextStyle(color: Color(0xFF888888), fontSize: 22),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF0A84FF),
                  inactiveTrackColor: const Color(0xFF1A1A1A),
                  thumbColor: const Color(0xFF0A84FF),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _sleep_hours,
                  min: 4,
                  max: 12,
                  onChanged: (val) => setState(() => _sleep_hours = val),
                ),
              ),
              const SizedBox(height: 24),
              _timeRow(
                label: 'Bedtime',
                value: _formatTime(_bedtime),
                onTap: () => _pickTime(is_bedtime: true),
              ),
              const SizedBox(height: 12),
              _timeRow(
                label: 'Wake up',
                value: _formatTime(_wake_time),
                onTap: () => _pickTime(is_bedtime: false),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
