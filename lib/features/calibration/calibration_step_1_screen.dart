import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';

class CalibrationStep1Screen extends StatelessWidget {
  const CalibrationStep1Screen({super.key});

  void goToNextStep(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.calibrationStep2);
  }

  @override
  Widget build(BuildContext context) {
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
              'Paso 1 de 3',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Column(
                children: [
                  Icon(Icons.remove_red_eye, color: Colors.white, size: 74),
                  SizedBox(height: 22),
                  Text(
                    'Coloca las gafas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Asegúrate de que el lente rojo y el lente verde estén bien puestos antes de continuar.',
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
            _InstructionCard(
              icon: Icons.check_circle,
              title: 'Revisa la posición',
              description:
                  'Las gafas deben quedar cómodas y alineadas con los ojos.',
            ),
            const SizedBox(height: 14),
            _InstructionCard(
              icon: Icons.lightbulb,
              title: 'Buena iluminación',
              description:
                  'Usa la app en un lugar con luz suficiente y sin reflejos fuertes.',
            ),
            const SizedBox(height: 14),
            _InstructionCard(
              icon: Icons.person,
              title: 'Acompañamiento',
              description:
                  'Un adulto debe ayudar al niño durante la calibración y el juego.',
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
              goToNextStep(context);
            },
            child: const Text(
              'Siguiente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
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
          Icon(icon, color: AppColors.cyan, size: 30),
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
