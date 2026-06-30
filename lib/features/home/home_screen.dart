import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/models/eye.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/app_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final patientName = appState.patientDisplayName;
    final patientSubtitle = appState.patientSubtitle;
    final redEye = appState.redLensEye?.shortLabel ?? 'no configurado';
    final greenEye = appState.greenLensEye?.shortLabel ?? 'no configurado';

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola de nuevo,\n$patientName! 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    patientSubtitle,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      '🔴 Rojo: ojo $redEye   🟢 Verde: ojo $greenEye',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Entrenamiento de hoy',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appState.hasCompletedCalibration
                        ? 'Gafas calibradas. Puedes iniciar el juego.'
                        : 'Primero completa la calibración de gafas.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  _TrainingCard(
                    title: 'Estimulación binocular',
                    tag: 'Piano Visual',
                    color: AppColors.purple,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.games);
                    },
                  ),
                  const SizedBox(height: 18),
                  _TrainingCard(
                    title: 'Velocidad de reacción',
                    tag: 'Corredor Visual',
                    color: Colors.green.shade800,
                    locked: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  const _TrainingCard({
    required this.title,
    required this.tag,
    required this.color,
    required this.onTap,
    this.locked = false,
  });

  final String title;
  final String tag;
  final Color color;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: locked ? Colors.grey.shade500 : color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag, style: const TextStyle(color: AppColors.cyan)),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.bottomRight,
            child: FilledButton(
              onPressed: locked ? null : onTap,
              child: Text(locked ? 'Bloqueado' : 'Jugar'),
            ),
          ),
        ],
      ),
    );
  }
}
