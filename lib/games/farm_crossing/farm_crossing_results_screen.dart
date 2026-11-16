import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/widgets/game_results_scaffold.dart';
import 'farm_crossing_session_result.dart';

class FarmCrossingResultsScreen extends StatelessWidget {
  const FarmCrossingResultsScreen({super.key});

  int calculateStars(FarmCrossingSessionResult result) {
    final totalObjectives =
        result.stats.objectivesCollected + result.stats.objectivesMissed;

    if (totalObjectives == 0) {
      return 1;
    }

    final accuracy = result.stats.objectivesCollected / totalObjectives;

    if (result.stats.collisions >= 3) {
      return 1;
    }

    if (accuracy >= 0.80) {
      return 3;
    }

    if (accuracy >= 0.55) {
      return 2;
    }

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final result =
        ModalRoute.of(context)?.settings.arguments
            as FarmCrossingSessionResult?;

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No hay resultados disponibles.')),
      );
    }

    final stars = calculateStars(result);

    debugPrint('===== RESULTADO TÉCNICO GALLINA EN RUTA =====');
    debugPrint('Motivo finalización: ${result.endReason.name}');
    debugPrint(
      'Objetivos recogidos: '
      '${result.stats.objectivesCollected}',
    );
    debugPrint(
      'Objetivos perdidos: '
      '${result.stats.objectivesMissed}',
    );
    debugPrint(
      'Carriles cruzados: '
      '${result.stats.lanesCrossed}',
    );
    debugPrint('Colisiones: ${result.stats.collisions}');
    debugPrint(
      'Vidas perdidas: '
      '${result.stats.livesLost}',
    );
    debugPrint(
      'Eventos registrados: '
      '${result.events.length}',
    );
    debugPrint('============================================');

    return GameResultsScaffold(
      stars: stars,
      icon: result.stats.collisions >= 3
          ? Icons.favorite_rounded
          : Icons.flag_rounded,
      accentColor: AppColors.yellow,
      title: stars == 3
          ? '¡Gran recorrido!'
          : stars == 2
          ? '¡Muy bien!'
          : '¡Buen intento!',
      message: 'Terminaste tu recorrido con la gallina.',
      statusTitle: stars >= 2 ? '¡Buen trabajo!' : 'Sigue practicando',
      statusMessage:
          'Tu progreso quedó guardado '
          'para que pueda revisarlo un adulto.',
      onPlayAgain: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.farmCrossingPreparation,
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
