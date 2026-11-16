import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/widgets/game_results_scaffold.dart';
import 'break_the_row_session_result.dart';

class BreakTheRowResultsScreen extends StatelessWidget {
  const BreakTheRowResultsScreen({super.key});

  int calculateStars(BreakTheRowSessionResult result) {
    if (result.completedTarget) {
      return 3;
    }

    if (result.endedByMaxLives) {
      return 1;
    }

    if (result.stats.linesCompleted >= 5) {
      return 2;
    }

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final result =
        ModalRoute.of(context)?.settings.arguments as BreakTheRowSessionResult?;

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No hay resultados disponibles.')),
      );
    }

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

    return GameResultsScaffold(
      stars: stars,
      icon: result.completedTarget
          ? Icons.grid_view_rounded
          : Icons.favorite_rounded,
      accentColor: AppColors.yellow,
      title: result.completedTarget ? '¡Fila completada!' : '¡Buen intento!',
      message: result.completedTarget
          ? 'Superaste el reto de Rompe la Fila.'
          : 'Cada partida te prepara para el próximo reto.',
      statusTitle: result.completedTarget
          ? 'Reto completado'
          : 'Sigue practicando',
      statusMessage:
          'Tu progreso quedó guardado '
          'para que pueda revisarlo un adulto.',
      onPlayAgain: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.breakTheRowPreparation,
          (route) => route.settings.name == AppRoutes.home,
        );
      },
      onHome: () {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      },
    );
  }
}
