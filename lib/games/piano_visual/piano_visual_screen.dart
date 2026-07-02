import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/state/app_state.dart';
import 'piano_level.dart';
import 'piano_session_result.dart';
import 'piano_visual_game.dart';

class PianoVisualScreen extends StatefulWidget {
  const PianoVisualScreen({super.key});

  @override
  State<PianoVisualScreen> createState() => _PianoVisualScreenState();
}

class _PianoVisualScreenState extends State<PianoVisualScreen> {
  PianoVisualGame? game;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (initialized) return;

    final appState = context.read<AppState>();

    final difficulty =
        ModalRoute.of(context)?.settings.arguments as PianoDifficulty? ??
        PianoDifficulty.basic;

    game = PianoVisualGame(
      redContrast: appState.redContrast,
      greenContrast: appState.greenContrast,
      difficulty: difficulty,
      onSessionFinished: goToResults,
    );

    initialized = true;
  }

  void goToResults(PianoSessionResult result) {
    Future.microtask(() {
      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.pianoResults, arguments: result);
    });
  }

  void finishSessionManually() {
    final currentGame = game;
    if (currentGame == null) return;

    final result = currentGame.finishSession(PianoEndReason.manual);
    goToResults(result);
  }

  @override
  Widget build(BuildContext context) {
    final currentGame = game;

    if (currentGame == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(game: currentGame),
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: ValueListenableBuilder<PianoStats>(
                valueListenable: currentGame.stats,
                builder: (context, stats, _) {
                  final remainingErrors =
                      PianoVisualGame.maxMisses - stats.misses;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.close),
                            ),
                            const Expanded(
                              child: Text(
                                'Piano Visual',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            FilledButton(
                              onPressed: stats.total == 0
                                  ? null
                                  : finishSessionManually,
                              child: const Text('Terminar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Puntos: ${stats.hits}',
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Row(
                              children: List.generate(
                                PianoVisualGame.maxMisses,
                                (index) {
                                  final lost = index < stats.misses;

                                  return Icon(
                                    lost
                                        ? Icons.favorite_border
                                        : Icons.favorite,
                                    color: lost ? Colors.grey : AppColors.red,
                                    size: 26,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          remainingErrors > 0
                              ? 'Te quedan $remainingErrors errores'
                              : 'Fin del intento',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
