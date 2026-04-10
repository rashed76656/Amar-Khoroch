import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/providers/security_provider.dart';
import 'package:amar_khoroch/providers/workspace_provider.dart';
import 'package:amar_khoroch/screens/home/home_screen.dart';
import 'package:amar_khoroch/screens/security/pin_screen.dart';
import 'package:amar_khoroch/screens/setup/workspace_setup_screen.dart';

class AppWrapper extends ConsumerWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityProvider);
    final activeWorkspace = ref.watch(activeWorkspaceProvider);

    // 1. If PIN is enabled and locked, show unlock screen
    if (securityState.isPinEnabled && securityState.isLocked) {
      return const PinScreen(mode: PinScreenMode.unlock);
    }

    // 2. If no workspace exists, show setup screen
    // Note: If workspaces are still loading, activeWorkspace might be null briefly,
    // but WorkspaceNotifier._load() runs synchronously on init since it's from local DB.
    if (activeWorkspace == null) {
      return const WorkspaceSetupScreen();
    }

    // 3. Otherwise, show main app
    return const HomeScreen();
  }
}
