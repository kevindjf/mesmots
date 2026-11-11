import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerevise/core/theme/app_theme.dart';
import 'package:jerevise/core/constants/app_strings.dart';
import 'package:jerevise/core/utils/database_provider.dart';
import 'package:jerevise/core/utils/tts_service.dart';
import 'package:jerevise/features/home/presentation/screens/section_home_screen.dart';
import 'package:jerevise/features/onboarding/presentation/screens/pin_setup_screen.dart';
import 'package:jerevise/features/parental/presentation/providers/parental_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await initializeDatabase();

  // Initialize TTS service
  final tts = TtsService();
  await tts.initialize();

  runApp(
    const ProviderScope(
      child: JeReviseApp(),
    ),
  );
}

class JeReviseApp extends StatelessWidget {
  const JeReviseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Widget that determines which screen to show on startup
class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentalSettingsAsync = ref.watch(parentalSettingsProvider);

    return parentalSettingsAsync.when(
      data: (settings) {
        // If PIN is not configured, show onboarding
        if (settings == null || !settings.isPinConfigured) {
          return const PinSetupScreen();
        }
        // Otherwise, show section home screen
        return const SectionHomeScreen();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }
}
