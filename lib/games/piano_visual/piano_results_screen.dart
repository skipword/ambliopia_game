import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import 'piano_session_result.dart';

class PianoResultsScreen extends StatelessWidget {
  const PianoResultsScreen({super.key});

  int calculateStars(PianoSessionResult result) {
    final total = result.stats.total;

    if (total == 0) return 1;

    final accuracy = result.stats.hits / total;

    if (accuracy >= 0.85) return 3;
    if (accuracy >= 0.60) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final result =
        ModalRoute.of(context)!.settings.arguments as PianoSessionResult;

    final stars = calculateStars(result);

    debugPrint('===== RESULTADO TÉCNICO DE SESIÓN =====');
    debugPrint('Aciertos: ${result.stats.hits}');
    debugPrint('Errores: ${result.stats.misses}');
    debugPrint('Rojo hits: ${result.stats.redHits}');
    debugPrint('Rojo misses: ${result.stats.redMisses}');
    debugPrint('Verde hits: ${result.stats.greenHits}');
    debugPrint('Verde misses: ${result.stats.greenMisses}');
    debugPrint('Duración: ${result.durationSeconds.round()} s');
    debugPrint('Observación: ${result.mainObservation}');
    debugPrint('Eventos registrados: ${result.events.length}');
    debugPrint('======================================');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 86,
                    color: AppColors.yellow,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    result.endedByMaxMisses
                        ? '¡Buen intento!'
                        : '¡Sesión completada!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    result.endedByMaxMisses
                        ? 'Terminaste el intento. Puedes volver a practicar cuando quieras.'
                        : 'Lo hiciste muy bien. Sigue entrenando tu visión con diversión.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final earned = index < stars;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(
                          earned ? Icons.star : Icons.star_border,
                          size: 44,
                          color: earned ? AppColors.yellow : Colors.white38,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
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
                  Icon(Icons.favorite, size: 52, color: AppColors.green),
                  SizedBox(height: 14),
                  Text(
                    '¡Buen trabajo!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tu sesión quedó registrada para que el adulto responsable pueda revisarla después.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, color: AppColors.cyan, size: 34),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Recuerda descansar los ojos después de jugar.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                },
                child: const Text(
                  'Volver al inicio',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.games, (route) => false);
                },
                child: const Text(
                  'Elegir otro juego',
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
