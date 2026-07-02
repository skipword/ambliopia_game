import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/models/eye.dart';
import '../../core/state/app_state.dart';
import 'piano_level.dart';

class PianoPreparationScreen extends StatefulWidget {
  const PianoPreparationScreen({super.key});

  @override
  State<PianoPreparationScreen> createState() => _PianoPreparationScreenState();
}

class _PianoPreparationScreenState extends State<PianoPreparationScreen> {
  PianoDifficulty selectedDifficulty = PianoDifficulty.basic;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final redEye = appState.redLensEye?.label ?? 'Ojo configurado';
    final greenEye = appState.greenLensEye?.label ?? 'Ojo dominante';

    return Scaffold(
      appBar: AppBar(title: const Text('Preparar juego')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
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
            Text(
              'Nivel de dificultad',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final difficulty in PianoDifficulty.values) ...[
              _DifficultyOption(
                difficulty: difficulty,
                selected: selectedDifficulty == difficulty,
                onTap: () {
                  setState(() {
                    selectedDifficulty = difficulty;
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'Regla: la sesión termina si se acumulan 3 errores.',
                style: TextStyle(height: 1.4, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.pianoVisual,
                    arguments: selectedDifficulty,
                  );
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
              height: 54,
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
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  const _DifficultyOption({
    required this.difficulty,
    required this.selected,
    required this.onTap,
  });

  final PianoDifficulty difficulty;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final config = difficulty.config;

    return Material(
      color: selected ? const Color(0xFFE0F7FA) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.cyan : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? AppColors.cyan : AppColors.textMuted,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      config.description,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
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
