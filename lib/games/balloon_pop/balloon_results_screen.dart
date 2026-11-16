import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/widgets/game_results_scaffold.dart';
import 'balloon_session_result.dart';

class BalloonResultsScreen extends StatelessWidget {
  const BalloonResultsScreen({super.key});

  int calculateStars(BalloonSessionResult result) {
    final total = result.stats.popped + result.stats.escaped;

    if (total == 0) {
      return 1;
    }

    final accuracy = result.stats.popped / total;

    if (accuracy >= 0.80) {
      return 3;
    }

    if (accuracy >= 0.60) {
      return 2;
    }

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final result =
        ModalRoute.of(context)?.settings.arguments as BalloonSessionResult?;

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No hay resultados disponibles.')),
      );
    }

    final stars = calculateStars(result);

    debugPrint('===== RESULTADO TÉCNICO EXPLOTA GLOBOS =====');
    debugPrint('Explotados: ${result.stats.popped}');
    debugPrint('Escaparon: ${result.stats.escaped}');
    debugPrint('Rojos explotados: ${result.stats.redPopped}');
    debugPrint('Rojos escapados: ${result.stats.redEscaped}');
    debugPrint('Verdes explotados: ${result.stats.greenPopped}');
    debugPrint('Verdes escapados: ${result.stats.greenEscaped}');
    debugPrint('Eventos: ${result.events.length}');
    debugPrint('===========================================');

    return GameResultsScaffold(
      stars: stars,
      icon: Icons.celebration_rounded,
      accentColor: AppColors.yellow,
      title: stars >= 3
          ? '¡Increíble!'
          : stars == 2
          ? '¡Muy bien!'
          : '¡Buen intento!',
      message: 'Terminaste el reto de Explota Globos.',
      statusTitle: stars >= 2 ? '¡Buen trabajo!' : 'Sigue practicando',
      statusMessage:
          'Tu progreso quedó guardado '
          'para que pueda revisarlo un adulto.',
      onPlayAgain: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.balloonPreparation,
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
