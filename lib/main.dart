import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/utils/database_provider.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/word_lists/presentation/screens/home_screen.dart';
import 'package:mesmots/features/onboarding/presentation/screens/pin_setup_screen.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await initializeDatabase();

  // Initialize TTS service
  final tts = TtsService();
  await tts.initialize();

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
        // Otherwise, show home screen
        return const HomeScreen();
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
