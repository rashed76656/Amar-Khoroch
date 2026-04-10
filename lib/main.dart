import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/data/hive/hive_init.dart';
import 'package:amar_khoroch/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local database
  await HiveBoxes.init();

  runApp(
    const ProviderScope(
      child: AmarKhorochApp(),
    ),
  );
}
