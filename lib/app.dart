import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/core/constants/app_constants.dart';
import 'package:amar_khoroch/app_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/providers/security_provider.dart';

class AmarKhorochApp extends ConsumerStatefulWidget {
  const AmarKhorochApp({super.key});

  @override
  ConsumerState<AmarKhorochApp> createState() => _AmarKhorochAppState();
}

class _AmarKhorochAppState extends ConsumerState<AmarKhorochApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(securityProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style for iOS feel
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppTheme.background,
        colorScheme: ColorScheme.light(
          primary: AppTheme.primaryAccent,
          surface: AppTheme.background,
          onSurface: AppTheme.textPrimary,
          error: AppTheme.destructive,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: AppTheme.titleLarge,
          iconTheme: IconThemeData(color: AppTheme.textPrimary),
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      home: const AppWrapper(),
    );
  }
}
