import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/models/clinical_session_summary.dart';
import '../../core/state/app_state.dart';
import 'road_visual_game.dart';
import 'road_visual_level.dart';
import 'road_visual_session_result.dart';

class RoadVisualScreen extends StatefulWidget {
  const RoadVisualScreen({super.key});

  @override
  State<RoadVisualScreen> createState() => _RoadVisualScreenState();
}

class _RoadVisualScreenState extends State<RoadVisualScreen> {
  RoadVisualGame? game;

  bool initialized = false;
  bool clinicalResultSaved = false;

  int? countdownValue = 3;

  Timer? countdownTimer;
  Timer? hideCountdownTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (initialized) {
      return;
    }

    final appState = context.read<AppState>();

    final difficulty =
        ModalRoute.of(context)?.settings.arguments as RoadVisualDifficulty? ??
        RoadVisualDifficulty.basic;

    game = RoadVisualGame(
      redContrast: appState.redContrast,
      greenContrast: appState.greenContrast,
      difficulty: difficulty,
      onSessionFinished: goToResults,
    );

    initialized = true;

    startCountdown();
  }

  void startCountdown() {
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        return;
      }

      final current = countdownValue ?? 0;

      if (current > 1) {
        setState(() {
          countdownValue = current - 1;
        });

        return;
      }

      timer.cancel();

      setState(() {
        countdownValue = 0;
      });

      game?.startGame();

      hideCountdownTimer = Timer(const Duration(milliseconds: 650), () {
        if (!mounted) {
          return;
        }

        setState(() {
          countdownValue = null;
        });
      });
    });
  }

  void saveClinicalResult(RoadVisualSessionResult result) {
    if (clinicalResultSaved) {
      return;
    }

    if (result.events.isEmpty || result.stats.totalEvents == 0) {
      debugPrint('Sesión de Ruta Visual sin actividad: no se guarda.');

      return;
    }

    final appState = context.read<AppState>();

    final patient = appState.patient;

    if (patient == null) {
      return;
    }

    clinicalResultSaved = true;

    appState.addClinicalSession(
      ClinicalSessionSummary(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        patientId: patient.code,
        gameType: ClinicalGameType.roadVisual,
        gameName: 'Ruta Visual',
        startedAt: result.startedAt,
        endedAt: result.endedAt,
        durationSeconds: result.durationSeconds,
        score: result.score,
        objectiveLabel: 'Objetivos rojos recogidos',
        completedObjective: result.stats.objectivesCollected,
        targetObjective: result.stats.redTotal,

        // Canal rojo.
        redSuccess: result.stats.objectivesCollected,
        redErrors: result.stats.objectivesMissed,

        // Canal verde.
        greenSuccess: result.stats.obstaclesAvoided,
        greenErrors: result.stats.collisions,

        eventsCount: result.events.length,
        observation: result.mainObservation,

        // Aquí no usamos tiempo de
        // reacción porque el tiempo
        // desde aparición hasta recoger
        // un objeto no representa una
        // reacción aislada.
        averageReactionTimeMs: null,
      ),
    );

    debugPrint('===== RESULTADO TÉCNICO RUTA VISUAL =====');

    debugPrint(
      'Objetivos: '
      '${result.stats.objectivesCollected}'
      '/'
      '${result.stats.redTotal}',
    );

    debugPrint(
      'Vehículos evitados: '
      '${result.stats.obstaclesAvoided}',
    );

    debugPrint(
      'Colisiones: '
      '${result.stats.collisions}',
    );

    debugPrint(
      'Cambios de carril: '
      '${result.stats.laneChanges}',
    );

    debugPrint('Puntuación: ${result.score}');

    debugPrint('=========================================');
  }

  void goToResults(RoadVisualSessionResult result) {
    saveClinicalResult(result);

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.roadVisualResults, arguments: result);
    });
  }

  void finishManually() {
    final currentGame = game;

    if (currentGame == null || currentGame.finalResult != null) {
      return;
    }

    final result = currentGame.finishSession(RoadVisualEndReason.manual);

    goToResults(result);
  }

  void exitGame() {
    final currentGame = game;

    if (currentGame != null &&
        currentGame.hasStarted &&
        currentGame.finalResult == null) {
      final result = currentGame.finishSession(RoadVisualEndReason.manual);

      goToResults(result);

      return;
    }

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    hideCountdownTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentGame = game;

    if (currentGame == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE7E9ED),
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;

                if (velocity < -160) {
                  currentGame.moveLeft();
                }

                if (velocity > 160) {
                  currentGame.moveRight();
                }
              },
              child: GameWidget(game: currentGame),
            ),

            Positioned(
              left: 14,
              right: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(20),
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
                                'Ruta Visual',
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        FilledButton(
                          onPressed: currentGame.hasStarted
                              ? finishManually
                              : null,
                          child: const Text('Terminar'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<RoadVisualStats>(
                          valueListenable: currentGame.stats,
                          builder: (context, stats, _) {
                            return Text(
                              '◆ ${stats.objectivesCollected}',
                              style: const TextStyle(
                                color: AppColors.red,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            );
                          },
                        ),

                        ValueListenableBuilder<double>(
                          valueListenable: currentGame.remainingSeconds,
                          builder: (context, remaining, _) {
                            return Text(
                              '${remaining.ceil()} s',
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            );
                          },
                        ),

                        ValueListenableBuilder<int>(
                          valueListenable: currentGame.livesLeft,
                          builder: (context, lives, _) {
                            return Row(
                              children: List.generate(
                                RoadVisualLevelConfig.maxLives,
                                (index) {
                                  final active = index < lives;

                                  return Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: Icon(
                                      active
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: active
                                          ? AppColors.red
                                          : Colors.grey,
                                      size: 22,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    ValueListenableBuilder<RoadVisualStats>(
                      valueListenable: currentGame.stats,
                      builder: (context, stats, _) {
                        return Text(
                          'Vehículos evitados: '
                          '${stats.obstaclesAvoided} · '
                          'Colisiones: '
                          '${stats.collisions}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 24,
              right: 24,
              bottom: 18,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 58,
                      child: FilledButton(
                        onPressed: currentGame.hasStarted
                            ? currentGame.moveLeft
                            : null,
                        child: const Icon(Icons.arrow_left_rounded, size: 34),
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: SizedBox(
                      height: 58,
                      child: FilledButton(
                        onPressed: currentGame.hasStarted
                            ? currentGame.moveRight
                            : null,
                        child: const Icon(Icons.arrow_right_rounded, size: 34),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (countdownValue != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.38),
                  child: Center(
                    child: Text(
                      countdownValue == 0 ? '¡Vamos!' : '$countdownValue',
                      style: TextStyle(
                        color: countdownValue == 0
                            ? AppColors.yellow
                            : Colors.white,
                        fontSize: countdownValue == 0 ? 58 : 82,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
