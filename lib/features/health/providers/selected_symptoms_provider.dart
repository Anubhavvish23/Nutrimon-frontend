import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedSymptomsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String slug) {
    final next = Set<String>.from(state);
    if (next.contains(slug)) {
      next.remove(slug);
    } else {
      next.add(slug);
    }
    state = next;
  }

  void replaceAll(Set<String> slugs) {
    state = Set<String>.from(slugs);
  }

  void clear() {
    state = <String>{};
  }
}

final selectedSymptomsProvider =
    NotifierProvider<SelectedSymptomsNotifier, Set<String>>(
  SelectedSymptomsNotifier.new,
);
