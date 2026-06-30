import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/models/eye.dart';
import '../../core/state/app_state.dart';

class PianoPreparationScreen extends StatelessWidget {
  const PianoPreparationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final redEye = appState.redLensEye?.label ?? 'Ojo configurado';
    final greenEye = appState.greenLensEye?.label ?? 'Ojo dominante';

    return Scaffold(
      appBar: AppBar(title: const Text('Preparar juego')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Piano Visual',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Antes de iniciar, revisa que las gafas estén bien colocadas.',
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.visibility, color: Colors.white, size: 56),
                    const SizedBox(height: 18),
                    _LensInstruction(
                      color: AppColors.red,
                      label: 'Lente rojo',
                      value: redEye,
                    ),
                    const SizedBox(height: 14),
                    _LensInstruction(
                      color: AppColors.green,
                      label: 'Lente verde',
                      value: greenEye,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text(
                  'Consejo: juega en un lugar iluminado, con el celular frente al rostro y sin mover demasiado la cabeza.',
                  style: TextStyle(height: 1.4),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.pianoVisual);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Estoy listo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    appState.setCalibrationReturnRoute(
                      AppRoutes.pianoPreparation,
                    );

                    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Recalibrar gafas'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LensInstruction extends StatelessWidget {
  const _LensInstruction({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label → $value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
