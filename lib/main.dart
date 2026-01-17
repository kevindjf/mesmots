import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/features/word_lists/presentation/screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MesMotsApp(),
    ),
  );
}

class MesMotsApp extends StatelessWidget {
  const MesMotsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
