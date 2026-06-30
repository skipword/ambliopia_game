import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/state/app_state.dart';
import '../../core/models/eye.dart';

class CalibrationStep3Screen extends StatelessWidget {
  const CalibrationStep3Screen({super.key});

  void finishCalibration(BuildContext context) {
    final appState = context.read<AppState>();

    appState.markCalibrationCompleted();

    final nextRoute = appState.consumeCalibrationReturnRoute(
      defaultRoute: AppRoutes.home,
    );

    Navigator.of(context).pushNamedAndRemoveUntil(nextRoute, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final redEye = appState.redLensEye?.shortLabel ?? 'configurado';
    final greenEye = appState.greenLensEye?.shortLabel ?? 'dominante';

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
            const Text(
              'Con las gafas puestas, confirma qué ves con cada ojo.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _StimulusPreview(
                    color: AppColors.red,
                    label: 'ROJO',
                    symbol: '★',
                  ),
                  _StimulusPreview(
                    color: AppColors.green,
                    label: 'VERDE',
                    symbol: '♦',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _VerificationCard(
              color: AppColors.red,
              text: '¿Ves la estrella roja con tu ojo $redEye?',
            ),
            const SizedBox(height: 12),
            _VerificationCard(
              color: AppColors.green,
              text: '¿Ves el diamante verde con tu ojo $greenEye?',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                onPressed: () => finishCalibration(context),
                child: const Text(
                  'Calibración completada ✓',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StimulusPreview extends StatelessWidget {
  const _StimulusPreview({
    required this.color,
    required this.label,
    required this.symbol,
  });

  final Color color;
  final String label;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              symbol,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
