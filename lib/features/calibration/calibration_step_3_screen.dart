import 'package:flutter/material.dart';

import '../../app/app_routes.dart';

class CalibrationStep3Screen extends StatelessWidget {
  const CalibrationStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calibración de gafas')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Paso 3 de 3'),
            const SizedBox(height: 24),
            Text(
              'Verificación final',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text('Con las gafas puestas, confirma qué ves con cada ojo.'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.pianoVisual);
                },
                child: const Text('Iniciar juego'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
