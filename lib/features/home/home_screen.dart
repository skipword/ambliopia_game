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

    final redEye = appState.redLensEye?.shortLabel ?? 'configurado';
    final greenEye = appState.greenLensEye?.shortLabel ?? 'dominante';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hola,',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    patientName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    patientSubtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🔴 Rojo: ojo $redEye\n🟢 Verde: ojo $greenEye',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _StatusCard(calibrated: appState.hasCompletedCalibration),
            const SizedBox(height: 24),
            Text(
              'Entrenamiento de hoy',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            _TrainingCard(
              title: 'Piano Visual',
              description:
                  'Toca las fichas cuando lleguen a la zona correcta y completa tu sesión visual.',
              icon: Icons.piano,
              buttonText: 'Ir al juego',
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.games);
              },
            ),
            const SizedBox(height: 16),
            _TrainingCard(
              title: 'Rompe la Fila',
              description:
                  'Mueve, rota y baja piezas para completar líneas horizontales.',
              icon: Icons.grid_view,
              buttonText: 'Ir al juego',
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.games);
              },
            ),
            const SizedBox(height: 24),
            _TipCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.calibrated});

  final bool calibrated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: calibrated ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: calibrated
              ? AppColors.green.withValues(alpha: 0.25)
              : Colors.orange.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            calibrated ? Icons.check_circle : Icons.warning_amber_rounded,
            color: calibrated ? AppColors.green : Colors.orange,
            size: 38,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              calibrated
                  ? 'Las gafas ya están calibradas. Puedes iniciar el entrenamiento.'
                  : 'Antes de jugar, debes completar la calibración de gafas.',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 15,
                height: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  const _TrainingCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.buttonText,
    required this.onTap,
    this.locked = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final String buttonText;
  final VoidCallback? onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: locked
                      ? Colors.grey.withValues(alpha: 0.16)
                      : AppColors.cyan.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  locked ? Icons.lock : icon,
                  color: locked ? Colors.grey : AppColors.cyan,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: locked ? null : onTap,
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb, color: AppColors.cyan, size: 32),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Recuerda hacer sesiones cortas y descansar los ojos después de jugar.',
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
    );
  }
}
