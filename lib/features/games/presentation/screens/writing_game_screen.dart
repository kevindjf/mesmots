import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_typography.dart';

class WritingGameScreen extends StatelessWidget {
  final String listId;

  const WritingGameScreen({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🟣 Écriture'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🚧',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            const Text(
              'Niveau 4 - En développement',
              style: TextStyle(
                fontSize: AppTypography.headingMedium,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}
