import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/health_profile_provider.dart';

class HealthConditionsScreen extends ConsumerStatefulWidget {
  const HealthConditionsScreen({super.key});

  @override
  ConsumerState<HealthConditionsScreen> createState() =>
      _HealthConditionsScreenState();
}

class _HealthConditionsScreenState extends ConsumerState<HealthConditionsScreen> {
  static const List<String> _allergy_options = [
    'Nuts',
    'Dairy',
    'Gluten',
    'Eggs',
    'Soy',
    'Shellfish',
    'Fish',
    'Sesame',
  ];

  static const List<String> _condition_options = [
    'Diabetes',
    'Hypertension',
    'Thyroid',
    'PCOS',
    'Asthma',
    'Heart disease',
    'Kidney disease',
    'None',
  ];

  final Set<String> _selected_allergies = {};
  final Set<String> _selected_conditions = {};

  @override
  void initState() {
    super.initState();
    final profile = ref.read(healthProfileProvider);
    _selected_allergies.addAll(profile.allergies);
    _selected_conditions.addAll(profile.conditions);
  }

  void _toggle(Set<String> set, String item) {
    setState(() {
      if (set.contains(item)) {
        set.remove(item);
      } else {
        if (item == 'None' && set == _selected_conditions) {
          set.clear();
        }
        set.add(item);
        if (set == _selected_conditions && item != 'None') {
          set.remove('None');
        }
      }
    });
  }

  Future<void> _save() async {
    await ref.read(healthProfileProvider.notifier).saveAllergiesAndConditions(
          allergies: _selected_allergies.toList(),
          conditions: _selected_conditions.toList(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        'Allergies & conditions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select all that apply',
                    style: TextStyle(color: Color(0xFF666666), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('ALLERGIES'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allergy_options
                          .map(
                            (item) => _chip(
                              label: item,
                              selected: _selected_allergies.contains(item),
                              color: const Color(0xFFFF9500),
                              onTap: () => _toggle(_selected_allergies, item),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                    _sectionLabel('CONDITIONS'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _condition_options
                          .map(
                            (item) => _chip(
                              label: item,
                              selected: _selected_conditions.contains(item),
                              color: const Color(0xFFFF375F),
                              onTap: () => _toggle(_selected_conditions, item),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF888888),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : const Color(0xFF2A2A2A),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF888888),
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
