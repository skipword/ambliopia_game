import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import 'break_the_row_session_result.dart';

class BreakTheRowResultsScreen extends StatelessWidget {
  const BreakTheRowResultsScreen({super.key});

  int calculateStars(BreakTheRowSessionResult result) {
    if (result.completedTarget) return 3;
    if (result.endedByMaxLives) return 1;
    if (result.stats.linesCompleted >= 5) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final result =
        ModalRoute.of(context)!.settings.arguments as BreakTheRowSessionResult;

    final stars = calculateStars(result);

    debugPrint('===== RESULTADO TÉCNICO ROMPE LA FILA =====');
    debugPrint('Motivo finalización: ${result.endReason.name}');
    debugPrint('Puntaje: ${result.stats.score}');
    debugPrint('Líneas: ${result.stats.linesCompleted}');
    debugPrint('Vidas perdidas: ${result.stats.livesLost}');
    debugPrint('Piezas colocadas: ${result.stats.piecesPlaced}');
    debugPrint('Piezas fallidas: ${result.stats.piecesFailed}');
    debugPrint('Rojas colocadas: ${result.stats.redPiecesPlaced}');
    debugPrint('Verdes colocadas: ${result.stats.greenPiecesPlaced}');
    debugPrint('Eventos registrados: ${result.events.length}');
    debugPrint('==========================================');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                children: [
                  Icon(
                    result.completedTarget
                        ? Icons.emoji_events
                        : Icons.favorite,
                    size: 86,
                    color: AppColors.yellow,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    result.completedTarget
                        ? '¡Reto completado!'
                        : '¡Buen intento!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    result.completedTarget
                        ? 'Lograste completar las líneas del nivel.'
                        : 'Puedes volver a practicar cuando quieras.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
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
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, color: AppColors.cyan, size: 34),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Recuerda descansar los ojos después de jugar.',
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
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.games, (route) => false);
                },
                child: const Text(
                  'Jugar otra vez',
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
                  ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                },
                child: const Text(
                  'Volver al inicio',
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
