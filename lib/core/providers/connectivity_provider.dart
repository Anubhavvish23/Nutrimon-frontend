import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityNotifier extends Notifier<bool> {
  final Connectivity _connectivity = Connectivity();

  @override
  bool build() {
    _connectivity.onConnectivityChanged.listen(_applyResults);
    refresh();
    return true;
  }

  void _applyResults(List<ConnectivityResult> results) {
    state = _isOnline(results);
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<void> refresh() async {
    final results = await _connectivity.checkConnectivity();
    state = _isOnline(results);
  }
}

final isOnlineProvider =
    NotifierProvider<ConnectivityNotifier, bool>(ConnectivityNotifier.new);
