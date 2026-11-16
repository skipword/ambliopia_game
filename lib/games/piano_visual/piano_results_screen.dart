import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/widgets/game_results_scaffold.dart';
import 'piano_session_result.dart';

class PianoResultsScreen extends StatelessWidget {
  const PianoResultsScreen({super.key});

  int calculateStars(PianoSessionResult result) {
    final total = result.stats.total;

    if (total == 0) {
      return 1;
    }

    final accuracy = result.stats.hits / total;

    if (result.endedByMaxMisses) {
      return 1;
    }

    if (accuracy >= 0.85) {
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
        ModalRoute.of(context)?.settings.arguments as PianoSessionResult?;

    if (result == null) {
      return _MissingResultScreen();
    }

    final stars = calculateStars(result);

    debugPrint('===== RESULTADO TÉCNICO DE SESIÓN =====');
    debugPrint(
      'Motivo finalización: '
      '${result.endReason.name}',
    );
    debugPrint(
      'Aciertos: '
      '${result.stats.hits}',
    );
    debugPrint(
      'Errores: '
      '${result.stats.misses}',
    );
    debugPrint(
      'Rojo hits: '
      '${result.stats.redHits}',
    );
    debugPrint(
      'Rojo misses: '
      '${result.stats.redMisses}',
    );
    debugPrint(
      'Verde hits: '
      '${result.stats.greenHits}',
    );
    debugPrint(
      'Verde misses: '
      '${result.stats.greenMisses}',
    );
    debugPrint(
      'Duración: '
      '${result.durationSeconds.round()} s',
    );
    debugPrint(
      'Observación: '
      '${result.mainObservation}',
    );
    debugPrint(
      'Eventos registrados: '
      '${result.events.length}',
    );
    debugPrint('======================================');

    final completed = !result.endedByMaxMisses;

    return GameResultsScaffold(
      stars: stars,

      icon: completed ? Icons.emoji_events_rounded : Icons.favorite_rounded,

      accentColor: AppColors.yellow,

      title: completed ? '¡Muy bien!' : '¡Buen intento!',

      message: completed
          ? 'Completaste Piano Visual.'
          : 'Cada intento cuenta. '
                'Puedes volver a jugar cuando quieras.',

      statusTitle: completed ? 'Sesión completada' : 'Sigue practicando',

      statusMessage:
          'Tu progreso quedó guardado '
          'para que pueda revisarlo un adulto.',

      onPlayAgain: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.pianoPreparation,
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

class _MissingResultScreen extends StatelessWidget {
  const _MissingResultScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sports_esports_rounded,
                    color: AppColors.cyan,
                    size: 64,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No hay una partida reciente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vuelve al menú y comienza un nuevo juego.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.home,
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('VOLVER A JUGAR'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
