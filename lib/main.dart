import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/presentation/app_theme.dart';
import 'core/presentation/root_shell.dart';

void main() {
  runApp(const ProviderScope(child: PrayerReminderApp()));
}

class PrayerReminderApp extends StatelessWidget {
  const PrayerReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Salaat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const RootShell(),
    );
  }
}
