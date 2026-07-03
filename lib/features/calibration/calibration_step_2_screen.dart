import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/state/app_state.dart';

class CalibrationStep2Screen extends StatelessWidget {
  const CalibrationStep2Screen({super.key});

  void goToNextStep(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.calibrationStep3);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

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
              'Paso 2 de 3',
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
                  Icon(Icons.tune, color: Colors.white, size: 64),
                  SizedBox(height: 18),
                  Text(
                    'Ajusta el contraste',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Mueve los controles hasta que los colores se vean claros con las gafas puestas.',
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
            _ContrastCard(
              title: 'Contraste rojo',
              subtitle: 'Canal del lente rojo',
              color: AppColors.red,
              value: appState.redContrast,
              onChanged: appState.setRedContrast,
            ),
            const SizedBox(height: 18),
            _ContrastCard(
              title: 'Contraste verde',
              subtitle: 'Canal del lente verde',
              color: AppColors.green,
              value: appState.greenContrast,
              onChanged: appState.setGreenContrast,
            ),
            const SizedBox(height: 24),
            _PreviewCard(
              redContrast: appState.redContrast,
              greenContrast: appState.greenContrast,
            ),
            const SizedBox(height: 24),
            const Text(
              'Este ajuste afectará cómo se ven las fichas rojas y verdes dentro del juego.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
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

class _ContrastCard extends StatelessWidget {
  const _ContrastCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final Color color;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.circle,
                color: color.withValues(alpha: value),
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Slider(
            value: value,
            min: 0.3,
            max: 1.0,
            divisions: 7,
            activeColor: color,
            inactiveColor: color.withValues(alpha: 0.18),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.redContrast, required this.greenContrast});

  final double redContrast;
  final double greenContrast;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          const Text(
            'Vista previa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PreviewTile(
                  label: 'Rojo',
                  color: AppColors.red.withValues(alpha: redContrast),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _PreviewTile(
                  label: 'Verde',
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

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
