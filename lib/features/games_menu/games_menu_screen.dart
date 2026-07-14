import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
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

  void startBreakTheRow(BuildContext context) {
    final appState = context.read<AppState>();

    if (appState.hasCompletedCalibration) {
      Navigator.of(context).pushNamed(AppRoutes.breakTheRowPreparation);
      return;
    }

    appState.setCalibrationReturnRoute(AppRoutes.breakTheRowPreparation);
    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            Text(
              'Juegos visuales',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Elige una actividad para comenzar el entrenamiento.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _CalibrationStatusCard(
              calibrated: appState.hasCompletedCalibration,
              onCalibrate: () {
                appState.setCalibrationReturnRoute(AppRoutes.games);
                Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
              },
            ),
            const SizedBox(height: 24),
            _GameCard(
              title: 'Piano Visual',
              subtitle: 'Juego principal',
              description:
                  'Toca las fichas cuando lleguen a la zona correcta. Algunas fichas se deben mantener presionadas.',
              icon: Icons.piano,
              color: AppColors.cyan,
              completedSessions: 0,
              levelText: 'Nivel 1 disponible',
              buttonText: 'Iniciar juego',
              onTap: () {
                startPianoVisual(context);
              },
            ),
            const SizedBox(height: 18),
            _GameCard(
              title: 'Rompe la Fila',
              subtitle: 'Nuevo juego',
              description:
                  'Mueve, rota y baja piezas para completar líneas horizontales en un tablero visual.',
              icon: Icons.grid_view,
              color: AppColors.green,
              completedSessions: 0,
              levelText: 'Nivel 1 disponible',
              buttonText: 'Iniciar juego',
              onTap: () {
                startBreakTheRow(context);
              },
            ),
            const SizedBox(height: 18),
            _GameCard(
              title: 'Burbujas Visuales',
              subtitle: 'Idea futura',
              description:
                  'Juego planeado para trabajar seguimiento visual con estímulos rojo-verde.',
              icon: Icons.bubble_chart,
              color: Colors.grey,
              completedSessions: 0,
              levelText: 'Bloqueado',
              buttonText: 'No disponible',
              locked: true,
              onTap: null,
            ),
            const SizedBox(height: 24),
            const _InfoCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _CalibrationStatusCard extends StatelessWidget {
  const _CalibrationStatusCard({
    required this.calibrated,
    required this.onCalibrate,
  });

  final bool calibrated;
  final VoidCallback onCalibrate;

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
      child: Column(
        children: [
          Row(
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
                      ? 'Gafas calibradas. Puedes iniciar una sesión.'
                      : 'Antes de jugar, debes calibrar las gafas.',
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
          if (!calibrated) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: onCalibrate,
                child: const Text(
                  'Calibrar ahora',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.completedSessions,
    required this.levelText,
    required this.buttonText,
    required this.onTap,
    this.locked = false,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final int completedSessions;
  final String levelText;
  final String buttonText;
  final VoidCallback? onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = locked ? Colors.grey : color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  locked ? Icons.lock : icon,
                  color: effectiveColor,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: effectiveColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _MiniInfoRow(icon: Icons.flag, label: levelText),
                const SizedBox(height: 10),
                _MiniInfoRow(
                  icon: Icons.check_circle,
                  label: '$completedSessions sesiones completadas',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: locked ? null : onTap,
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfoRow extends StatelessWidget {
  const _MiniInfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.cyan, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.favorite, color: AppColors.red, size: 30),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Las sesiones deben ser cortas y acompañadas por un adulto responsable.',
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
