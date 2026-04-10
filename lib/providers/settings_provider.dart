import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/data/hive/hive_init.dart';

/// Whether amounts are visible or hidden.
final amountVisibilityProvider =
    StateNotifierProvider<AmountVisibilityNotifier, bool>((ref) {
  return AmountVisibilityNotifier();
});

class AmountVisibilityNotifier extends StateNotifier<bool> {
  AmountVisibilityNotifier() : super(true) {
    _load();
  }

  void _load() {
    state = HiveBoxes.settings.get('amountVisible', defaultValue: true) as bool;
  }

  void toggle() {
    state = !state;
    HiveBoxes.settings.put('amountVisible', state);
  }

  void set(bool visible) {
    state = visible;
    HiveBoxes.settings.put('amountVisible', state);
  }
}
