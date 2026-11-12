import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../core/state/app_state.dart';
import '../../core/models/clinical_session_summary.dart';
import 'farm_crossing_session_result.dart';
import 'farm_crossing_game.dart';
import 'farm_crossing_level.dart';

class FarmCrossingScreen extends StatefulWidget {
  const FarmCrossingScreen({super.key, required this.difficulty});

  final FarmCrossingDifficulty difficulty;

  @override
  State<FarmCrossingScreen> createState() => _FarmCrossingScreenState();
}

class _FarmCrossingScreenState extends State<FarmCrossingScreen> {
  FarmCrossingGame? game;

  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (initialized) return;

    final appState = context.read<AppState>();

    game = FarmCrossingGame(
      difficulty: widget.difficulty,
      redContrast: appState.redContrast,
      greenContrast: appState.greenContrast,
      onSessionFinished: saveClinicalResult,
    );

    initialized = true;
  }

  void exitGame() {
    final currentGame = game;

    if (currentGame != null &&
        currentGame.hasStarted &&
        currentGame.finalResult == null) {
      currentGame.finishSession(FarmCrossingEndReason.manual);
    }

    Navigator.of(context).pop();
  }

  void saveClinicalResult(FarmCrossingSessionResult result) {
    final appState = context.read<AppState>();
    final patient = appState.patient;

    if (patient == null) return;

    final score =
        result.stats.roundsCompleted * 100 +
        result.stats.objectivesCollected * 25;

    appState.addClinicalSession(
      ClinicalSessionSummary(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        patientId: patient.code,
        gameType: ClinicalGameType.farmCrossing,
        gameName: 'Cruza la Granja',
        startedAt: result.startedAt,
        endedAt: result.endedAt,
        durationSeconds: result.durationSeconds,
        score: score,
        objectiveLabel: 'Cruces completados',
        completedObjective: result.stats.roundsCompleted,
        targetObjective: game?.config.targetCrossings ?? 0,

        // Canal rojo:
        redSuccess: result.stats.objectivesCollected,
        redErrors: result.stats.objectivesMissed,

        // Canal verde:
        greenSuccess: result.stats.lanesCrossed,
        greenErrors: result.stats.collisions,

        eventsCount: result.events.length,
        observation: result.mainObservation,

        // No usamos averageReactionTimeMs porque
        // averageLaneTimeMs no es realmente tiempo de reacción.
        averageReactionTimeMs: null,
      ),
    );

    debugPrint('===== RESULTADO TÉCNICO CRUZA LA GRANJA =====');
    debugPrint('Motivo finalización: ${result.endReason.name}');
    debugPrint('Cruces: ${result.stats.roundsCompleted}');
    debugPrint('Objetivos recogidos: ${result.stats.objectivesCollected}');
    debugPrint('Objetivos perdidos: ${result.stats.objectivesMissed}');
    debugPrint('Carriles cruzados: ${result.stats.lanesCrossed}');
    debugPrint('Colisiones: ${result.stats.collisions}');
    debugPrint('Vidas perdidas: ${result.stats.livesLost}');
    debugPrint('Eventos registrados: ${result.events.length}');
    debugPrint(
      'Tiempo promedio por carril: ${result.averageLaneTimeMs?.toStringAsFixed(1) ?? "N/A"} ms',
    );
    debugPrint('=============================================');
  }

  @override
  Widget build(BuildContext context) {
    final currentGame = game;

    if (currentGame == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;

                if (velocity < -220) {
                  currentGame.moveLeft();
                }

                if (velocity > 220) {
                  currentGame.moveRight();
                }
              },
              onVerticalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;

                if (velocity < -220) {
                  currentGame.moveUp();
                }

                if (velocity > 220) {
                  currentGame.moveDown();
                }
              },
              child: GameWidget(game: currentGame),
            ),

            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: exitGame,
                          icon: const Icon(Icons.close),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Cruza la Granja',
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                currentGame.config.name,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: currentGame.livesLeft,
                          builder: (context, lives, _) {
                            return Row(
                              children: List.generate(
                                FarmCrossingGame.maxLives,
                                (index) {
                                  final active = index < lives;

                                  return Padding(
                                    padding: const EdgeInsets.only(left: 3),
                                    child: Icon(
                                      active
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: active
                                          ? AppColors.red
                                          : Colors.grey,
                                      size: 23,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<int>(
                            valueListenable: currentGame.roundsCompleted,
                            builder: (context, rounds, _) {
                              return Text(
                                'Cruces: '
                                '$rounds/${currentGame.config.targetCrossings}',
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.w900,
                                ),
                              );
                            },
                          ),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: currentGame.objectivesCollected,
                          builder: (context, collected, _) {
                            return Text(
                              'Objetivos: $collected',
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w900,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Row(
                children: [
                  _ControlButton(
                    icon: Icons.arrow_left,
                    onTap: currentGame.moveLeft,
                  ),
                  const SizedBox(width: 8),
                  _ControlButton(
                    icon: Icons.arrow_upward,
                    onTap: currentGame.moveUp,
                  ),
                  const SizedBox(width: 8),
                  _ControlButton(
                    icon: Icons.arrow_downward,
                    onTap: currentGame.moveDown,
                  ),
                  const SizedBox(width: 8),
                  _ControlButton(
                    icon: Icons.arrow_right,
                    onTap: currentGame.moveRight,
                  ),
                ],
              ),
            ),

            ValueListenableBuilder<bool>(
              valueListenable: currentGame.roundCompleted,
              builder: (context, roundCompleted, _) {
                if (!roundCompleted || currentGame.sessionCompleted.value) {
                  return const SizedBox.shrink();
                }

                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.50),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(28),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🐔', style: TextStyle(fontSize: 58)),
                            const SizedBox(height: 12),
                            const Text(
                              '¡Cruce completado!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ValueListenableBuilder<bool>(
                              valueListenable: currentGame.objectiveCollected,
                              builder: (context, collected, _) {
                                return Text(
                                  collected
                                      ? 'También recogiste el objetivo.'
                                      : 'Esta vez no recogiste el objetivo.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: currentGame.startNextRound,
                                child: const Text('Siguiente cruce'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            ValueListenableBuilder<bool>(
              valueListenable: currentGame.sessionCompleted,
              builder: (context, completed, _) {
                if (!completed) {
                  return const SizedBox.shrink();
                }

                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(28),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🐔', style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 12),
                            const Text(
                              '¡Sesión completada!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ValueListenableBuilder<int>(
                              valueListenable: currentGame.objectivesCollected,
                              builder: (context, collected, _) {
                                return Text(
                                  'Objetivos recogidos: '
                                  '$collected/${currentGame.config.targetCrossings}',
                                  style: const TextStyle(
                                    color: AppColors.navy,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder<int>(
                              valueListenable: currentGame.collisions,
                              builder: (context, collisions, _) {
                                return Text(
                                  'Colisiones: $collisions',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: currentGame.restartSession,
                                child: const Text('Jugar otra sesión'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            ValueListenableBuilder<bool>(
              valueListenable: currentGame.gameOver,
              builder: (context, gameOver, _) {
                if (!gameOver) {
                  return const SizedBox.shrink();
                }

                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(28),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🐔', style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 14),
                            const Text(
                              '¡Cuidado con los carros!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder<int>(
                              valueListenable: currentGame.collisions,
                              builder: (context, collisions, _) {
                                return Text(
                                  'Tuviste $collisions colisiones.',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: currentGame.restartSession,
                                child: const Text('Intentar otra vez'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 56,
        child: FilledButton(onPressed: onTap, child: Icon(icon, size: 28)),
      ),
    );
  }
}
