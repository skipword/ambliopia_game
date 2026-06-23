import 'package:flutter/material.dart';

import '../../app/app_routes.dart';

class CalibrationStep1Screen extends StatelessWidget {
  const CalibrationStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CalibrationPlaceholder(
      step: 'Paso 1 de 3',
      title: 'Coloca las gafas anaglíficas',
      description: 'Verifica la posición correcta antes de jugar.',
      buttonText: 'Siguiente',
      nextRoute: AppRoutes.calibrationStep2,
    );
  }
}

class _CalibrationPlaceholder extends StatelessWidget {
  const _CalibrationPlaceholder({
    required this.step,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.nextRoute,
  });

  final String step;
  final String title;
  final String description;
  final String buttonText;
  final String nextRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calibración de gafas')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(step),
            const SizedBox(height: 24),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(description),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(nextRoute);
                },
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
