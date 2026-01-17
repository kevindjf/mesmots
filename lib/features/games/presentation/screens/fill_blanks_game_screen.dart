import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_typography.dart';

class FillBlanksGameScreen extends StatelessWidget {
  final String listId;

  const FillBlanksGameScreen({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🟠 Mots à trous'),
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
              'Niveau 3 - En développement',
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
