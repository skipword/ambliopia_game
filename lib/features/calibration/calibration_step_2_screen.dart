import 'package:flutter/material.dart';

import '../../app/app_routes.dart';

class CalibrationStep2Screen extends StatelessWidget {
  const CalibrationStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calibración de gafas')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paso 2 de 3'),
            const SizedBox(height: 24),
            Text(
              'Ajuste de contraste',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text('Lente rojo · 70%'),
            const Slider(value: 0.7, onChanged: null),
            const SizedBox(height: 24),
            const Text('Lente verde · 70%'),
            const Slider(value: 0.7, onChanged: null),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.calibrationStep3);
                },
                child: const Text('Siguiente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
