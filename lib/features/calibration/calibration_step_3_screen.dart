import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/models/eye.dart';
import '../../core/state/app_state.dart';

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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            Text(
              'Calibración de gafas',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Paso 3 de 3',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Column(
                children: [
                  Icon(Icons.verified, color: Colors.white, size: 66),
                  SizedBox(height: 18),
                  Text(
                    'Verificación final',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Observa las figuras con las gafas puestas y confirma que puedas distinguirlas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _StimulusPreviewCard(
              redEye: redEye,
              greenEye: greenEye,
              redContrast: appState.redContrast,
              greenContrast: appState.greenContrast,
            ),
            const SizedBox(height: 22),
            _InstructionCard(
              icon: Icons.star,
              color: AppColors.red,
              title: 'Figura roja',
              description:
                  'Debe verse principalmente a través del lente rojo, asociado al ojo $redEye.',
            ),
            const SizedBox(height: 14),
            _InstructionCard(
              icon: Icons.diamond,
              color: AppColors.green,
              title: 'Figura verde',
              description:
                  'Debe verse principalmente a través del lente verde, asociado al ojo $greenEye.',
            ),
            const SizedBox(height: 22),
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
                      'Si alguna figura no se distingue bien, vuelve al paso anterior y ajusta el contraste.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
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
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: FilledButton(
            onPressed: () {
              finishCalibration(context);
            },
            child: const Text(
              'Finalizar calibración',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

class _StimulusPreviewCard extends StatelessWidget {
  const _StimulusPreviewCard({
    required this.redEye,
    required this.greenEye,
    required this.redContrast,
    required this.greenContrast,
  });

  final String redEye;
  final String greenEye;
  final double redContrast;
  final double greenContrast;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Text(
            'Prueba visual',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _StimulusFigure(
                  icon: Icons.star,
                  label: 'Rojo',
                  subtitle: 'Ojo $redEye',
                  color: AppColors.red.withValues(alpha: redContrast),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StimulusFigure(
                  icon: Icons.diamond,
                  label: 'Verde',
                  subtitle: 'Ojo $greenEye',
                  color: AppColors.green.withValues(alpha: greenContrast),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StimulusFigure extends StatelessWidget {
  const _StimulusFigure({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 56),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
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
    );
  }
}
