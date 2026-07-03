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

  void startGame(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.pianoVisual, arguments: selectedDifficulty);
  }

  void recalibrate(BuildContext context) {
    final appState = context.read<AppState>();

    appState.setCalibrationReturnRoute(AppRoutes.pianoPreparation);
    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final redEye = appState.redLensEye?.label ?? 'Ojo configurado';
    final greenEye = appState.greenLensEye?.label ?? 'Ojo dominante';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Preparar juego'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            Text(
              'Piano Visual',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Antes de iniciar, revisa la configuración y elige un nivel.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  const Icon(Icons.visibility, color: Colors.white, size: 58),
                  const SizedBox(height: 18),
                  const Text(
                    'Revisa las gafas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LensInstruction(
                    color: AppColors.red,
                    label: 'Lente rojo',
                    value: redEye,
                  ),
                  const SizedBox(height: 12),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.cyan, size: 30),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'La sesión termina si se acumulan 3 errores. Toca las fichas solo cuando lleguen a la zona indicada.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.touch_app, color: Colors.orange, size: 30),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Algunas fichas largas se deben mantener presionadas hasta completar el círculo de progreso.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton.icon(
                onPressed: () {
                  startGame(context);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'Estoy listo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  recalibrate(context);
                },
                icon: const Icon(Icons.settings),
                label: const Text(
                  'Recalibrar gafas',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
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
      color: selected ? const Color(0xFFDDF8FB) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppColors.cyan : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? AppColors.cyan : AppColors.textMuted,
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.name,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      config.description,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
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
              fontSize: 16,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
