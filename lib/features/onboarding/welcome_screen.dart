import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void startSession(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.patientData);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final illustrationSize = (screenWidth * 0.62)
        .clamp(210.0, 290.0)
        .toDouble();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
          children: [
            Text(
              'Vision Kids',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            const Text(
              'Entrenamiento visual divertido para niños',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 17,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 36),
            Center(child: _HeroIllustration(size: illustrationSize)),
            const SizedBox(height: 36),
            Container(
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
              child: const Column(
                children: [
                  Icon(Icons.sports_esports, color: AppColors.cyan, size: 48),
                  SizedBox(height: 14),
                  Text(
                    'Juega, practica y mejora',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Completa sesiones cortas con juegos visuales usando gafas rojo-verde.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                      'Un adulto debe acompañar al niño durante la configuración, calibración y sesiones de juego.',
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
              startSession(context);
            },
            child: const Text(
              'Comenzar sesión',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.purple,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.68,
            height: size * 0.68,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD7A8),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            top: size * 0.23,
            child: Row(
              children: [
                _LensCircle(
                  color: AppColors.red.withValues(alpha: 0.85),
                  size: size * 0.22,
                ),
                Container(width: size * 0.10, height: 6, color: AppColors.navy),
                _LensCircle(
                  color: AppColors.green.withValues(alpha: 0.85),
                  size: size * 0.22,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: size * 0.26,
            child: Container(
              width: size * 0.22,
              height: size * 0.08,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            top: size * 0.10,
            right: size * 0.18,
            child: const Icon(Icons.star, color: AppColors.yellow, size: 34),
          ),
          Positioned(
            bottom: size * 0.12,
            left: size * 0.18,
            child: const Icon(Icons.favorite, color: AppColors.red, size: 30),
          ),
        ],
      ),
    );
  }
}

class _LensCircle extends StatelessWidget {
  const _LensCircle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navy, width: 5),
      ),
    );
  }
}
