import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/features/appearance/presentation/extensions/appearance_theme.dart';
import 'package:mesmots/features/appearance/presentation/providers/appearance_providers.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/utils/database_provider.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/word_lists/presentation/screens/home_screen.dart';
import 'package:mesmots/features/onboarding/presentation/screens/pin_setup_screen.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';

/// Length of the animated logo of the Android 12+ splash
/// (android/app/src/main/res/drawable/splash_animated.xml).
const _splashAnimation = Duration(milliseconds: 950);

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Android keeps its splash until the first frame: hold that frame until
  // the logo animation has played, so it is never cut short.
  final splashPlayed = Future<void>.delayed(_splashAnimation);
  if (Platform.isAndroid) binding.deferFirstFrame();

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

  if (Platform.isAndroid) {
    await splashPlayed;
    binding.allowFirstFrame();
  }
}

class MesMotsApp extends ConsumerWidget {
  const MesMotsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceProvider);
    return MaterialApp(
      title: AppStrings.appName,
      theme: appearance.themeData,
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
    // Load the sound effects now, so the first one of a game is heard.
    ref.watch(audioServiceProvider);
    final parentalSettingsAsync = ref.watch(parentalSettingsProvider);

    return parentalSettingsAsync.when(
      data: (settings) {
        // If PIN is not configured, show onboarding
        if (!settings.isPinConfigured) {
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
