import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/widgets/game_results_scaffold.dart';
import 'road_visual_session_result.dart';

class RoadVisualResultsScreen extends StatelessWidget {
  const RoadVisualResultsScreen({super.key});

  int calculateStars(RoadVisualSessionResult result) {
    final totalObjectives =
        result.stats.objectivesCollected + result.stats.objectivesMissed;

    if (totalObjectives == 0) {
      return 1;
    }

    final accuracy = result.stats.objectivesCollected / totalObjectives;

    if (result.stats.collisions >= 3) {
      return 1;
    }

    if (accuracy >= 0.80 && result.stats.collisions <= 1) {
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
        ModalRoute.of(context)?.settings.arguments as RoadVisualSessionResult?;

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No hay resultados disponibles.')),
      );
    }

    final stars = calculateStars(result);

    debugPrint('===== RESULTADO TÉCNICO RUTA VISUAL =====');
    debugPrint(
      'Objetivos recogidos: '
      '${result.stats.objectivesCollected}',
    );
    debugPrint(
      'Objetivos perdidos: '
      '${result.stats.objectivesMissed}',
    );
    debugPrint(
      'Vehículos evitados: '
      '${result.stats.obstaclesAvoided}',
    );
    debugPrint('Colisiones: ${result.stats.collisions}');
    debugPrint(
      'Cambios de carril: '
      '${result.stats.laneChanges}',
    );
    debugPrint('=========================================');

    return GameResultsScaffold(
      stars: stars,
      icon: result.stats.collisions >= 3
          ? Icons.favorite_rounded
          : Icons.directions_car_rounded,
      accentColor: AppColors.yellow,
      title: stars == 3
          ? '¡Gran carrera!'
          : stars == 2
          ? '¡Muy bien!'
          : '¡Buen intento!',
      message: 'Terminaste el reto de Ruta Visual.',
      statusTitle: stars >= 2 ? '¡Buen recorrido!' : 'Sigue practicando',
      statusMessage:
          'Tu progreso quedó guardado '
          'para que pueda revisarlo un adulto.',
      onPlayAgain: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.roadVisualPreparation,
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
