import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/skeleton/skeleton.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/premium/premium_card.dart';
import '../models/symptom_timeline_entry.dart';
import '../providers/symptom_timeline_provider.dart';

class SymptomTimelineScreen extends ConsumerWidget {
  const SymptomTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(symptomTimelineProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SkeletonResponsive.horizontalPadding(context),
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                    const Expanded(
                      child: Text(
                        'Symptom timeline',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: !timeline.is_ready
                    ? const Center(child: CircularProgressIndicator())
                    : timeline.entries.isEmpty
                        ? const EmptyStateView(
                            emoji: '📈',
                            title: 'No check-ins yet',
                            subtitle:
                                'Analyze symptoms on Health — we will ask how you feel after 2 hours.',
                          )
                        : ListView(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  SkeletonResponsive.horizontalPadding(
                                      context),
                            ),
                            children: [
                              const Text(
                                'Track whether meals actually helped — rate yourself ~2 hours after analysis.',
                                style: TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              if (timeline.pending.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                const PremiumSectionLabel('CHECK IN'),
                                ...timeline.pending.map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _PendingCard(entry: entry),
                                  ),
                                ),
                              ],
                              if (timeline.completed.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const PremiumSectionLabel('HISTORY'),
                                ...timeline.completed.map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _HistoryCard(entry: entry),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 32),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingCard extends ConsumerStatefulWidget {
  final SymptomTimelineEntry entry;

  const _PendingCard({required this.entry});

  @override
  ConsumerState<_PendingCard> createState() => _PendingCardState();
}

class _PendingCardState extends ConsumerState<_PendingCard> {
  int _score = 3;
  final _note_controller = TextEditingController();

  @override
  void dispose() {
    _note_controller.dispose();
    super.dispose();
  }

  String _feeling_label(int score) {
    switch (score) {
      case 1:
        return 'Worse';
      case 2:
        return 'Same-ish';
      case 3:
        return 'Okay';
      case 4:
        return 'Better';
      default:
        return 'Much better';
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final due_label = entry.is_due
        ? 'Ready now'
        : 'Due ${_formatTime(entry.checkin_due_at)}';

    return PremiumCard(
      border_color: entry.is_due
          ? const Color(0xFFBF5AF2).withOpacity(0.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                due_label,
                style: TextStyle(
                  color: entry.is_due
                      ? const Color(0xFFBF5AF2)
                      : const Color(0xFF888888),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(entry.analyzed_at),
                style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.analysis_preview.isEmpty
                ? 'Symptom analysis'
                : entry.analysis_preview,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (entry.suggested_meals.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Suggested: ${entry.suggested_meals.join(', ')}',
              style: const TextStyle(color: Color(0xFF1DB954), fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'How do you feel now? ${_feeling_label(_score)}',
            style: const TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: _score.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: const Color(0xFFBF5AF2),
            onChanged: (value) => setState(() => _score = value.round()),
          ),
          TextField(
            controller: _note_controller,
            maxLines: 2,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Optional note (what you ate, sleep…)',
              hintStyle: TextStyle(color: Color(0xFF555555)),
              filled: true,
              fillColor: Color(0xFF111111),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(symptomTimelineProvider.notifier).submitCheckIn(
                      entry_id: entry.id,
                      feeling_score: _score,
                      note: _note_controller.text,
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBF5AF2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save check-in',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final SymptomTimelineEntry entry;

  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final score = entry.feeling_score ?? 0;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _scoreEmoji(score),
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 8),
              Text(
                _scoreLabel(score),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(entry.checked_in_at ?? entry.analyzed_at),
                style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.analysis_preview,
            style: const TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (entry.note != null && entry.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              entry.note!,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  String _scoreEmoji(int score) {
    switch (score) {
      case 1:
        return '😞';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😊';
      default:
        return '🌟';
    }
  }

  String _scoreLabel(int score) {
    switch (score) {
      case 1:
        return 'Felt worse';
      case 2:
        return 'About the same';
      case 3:
        return 'Okay';
      case 4:
        return 'Felt better';
      default:
        return 'Much better';
    }
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String _formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
