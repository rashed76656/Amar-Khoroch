import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/data/hive/hive_init.dart';

final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier();
});

class SecurityState {
  final bool isPinEnabled;
  final bool isLocked;

  SecurityState({required this.isPinEnabled, required this.isLocked});

  SecurityState copyWith({bool? isPinEnabled, bool? isLocked}) {
    return SecurityState(
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  SecurityNotifier()
      : super(SecurityState(
          isPinEnabled: _hasPin(),
          isLocked: _hasPin(),
        ));

  static bool _hasPin() {
    return HiveBoxes.settings.get('pinHash') != null;
  }

  String _hash(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> setupPin(String pin) async {
    final hashed = _hash(pin);
    await HiveBoxes.settings.put('pinHash', hashed);
    state = state.copyWith(isPinEnabled: true, isLocked: false);
    return true;
  }

  Future<bool> verifyAndUnlock(String pin) async {
    final storedHash = HiveBoxes.settings.get('pinHash') as String?;
    if (storedHash == null) return true;

    final inputHash = _hash(pin);
    if (inputHash == storedHash) {
      state = state.copyWith(isLocked: false);
      return true;
    }
    return false;
  }

  Future<bool> removePin(String currentPin) async {
    final storedHash = HiveBoxes.settings.get('pinHash') as String?;
    if (storedHash == null) return true;

    if (_hash(currentPin) == storedHash) {
      await HiveBoxes.settings.delete('pinHash');
      state = state.copyWith(isPinEnabled: false, isLocked: false);
      return true;
    }
    return false;
  }

  void lock() {
    if (state.isPinEnabled) {
      state = state.copyWith(isLocked: true);
    }
  }
}
