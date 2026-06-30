import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/models/eye.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/app_bottom_nav.dart';

class GamesMenuScreen extends StatelessWidget {
  const GamesMenuScreen({super.key});

  void startPianoVisual(BuildContext context) {
    final appState = context.read<AppState>();

    if (appState.hasCompletedCalibration) {
      Navigator.of(context).pushNamed(AppRoutes.pianoPreparation);
      return;
    }

    appState.setCalibrationReturnRoute(AppRoutes.pianoPreparation);

    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final redEye = appState.redLensEye?.shortLabel ?? 'no configurado';
    final greenEye = appState.greenLensEye?.shortLabel ?? 'no configurado';

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Módulos de juegos',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(appState.patientSubtitle),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🔴 Rojo: ojo $redEye\n🟢 Verde: ojo $greenEye',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎹 Piano Visual',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Toca las fichas de colores y entrena la coordinación visual.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _SmallInfoChip(
                          text: appState.hasCompletedCalibration
                              ? 'Calibrado'
                              : 'Requiere calibración',
                          icon: appState.hasCompletedCalibration
                              ? Icons.check_circle
                              : Icons.settings,
                        ),
                        const SizedBox(width: 10),
                        const _SmallInfoChip(text: 'Nivel 1', icon: Icons.star),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () => startPianoVisual(context),
                        child: const Text(
                          'Iniciar Piano Visual',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _LockedGameCard(
                title: 'Corredor Visual',
                subtitle: 'Próximamente',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallInfoChip extends StatelessWidget {
  const _SmallInfoChip({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedGameCard extends StatelessWidget {
  const _LockedGameCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Text(subtitle),
            ],
          ),
        ],
      ),
    );
  }
}
