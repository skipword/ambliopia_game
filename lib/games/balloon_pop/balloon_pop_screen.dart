import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/state/app_state.dart';
import '../../core/models/clinical_session_summary.dart';
import 'balloon_level.dart';
import 'balloon_pop_game.dart';
import 'balloon_session_result.dart';

class BalloonPopScreen extends StatefulWidget {
  const BalloonPopScreen({super.key});

  @override
  State<BalloonPopScreen> createState() => _BalloonPopScreenState();
}

class _BalloonPopScreenState extends State<BalloonPopScreen> {
  BalloonPopGame? game;

  bool initialized = false;
  bool clinicalResultSaved = false;

  int? countdownValue = 3;

  Timer? countdownTimer;
  Timer? hideCountdownTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (initialized) return;

    final appState = context.read<AppState>();

    final difficulty =
        ModalRoute.of(context)?.settings.arguments as BalloonDifficulty? ??
        BalloonDifficulty.basic;

    game = BalloonPopGame(
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
      if (!mounted) return;

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
        if (!mounted) return;

        setState(() {
          countdownValue = null;
        });
      });
    });
  }

  void goToResults(BalloonSessionResult result) {
    saveClinicalResult(result);

    Future.microtask(() {
      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.balloonResults, arguments: result);
    });
  }

  void finishManually() {
    final currentGame = game;

    if (currentGame == null || currentGame.finalResult != null) {
      return;
    }

    final result = currentGame.finishSession(BalloonEndReason.manual);

    goToResults(result);
  }

  void saveClinicalResult(BalloonSessionResult result) {
    if (clinicalResultSaved) return;

    final appState = context.read<AppState>();
    final patient = appState.patient;

    if (patient == null) return;

    if (result.events.isEmpty || result.stats.total == 0) {
      debugPrint('Sesión de Globos sin actividad: no se guarda.');
      return;
    }

    clinicalResultSaved = true;

    appState.addClinicalSession(
      ClinicalSessionSummary(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        patientId: patient.code,
        gameType: ClinicalGameType.balloonPop,
        gameName: 'Explota los Globos',
        startedAt: result.startedAt,
        endedAt: result.endedAt,
        durationSeconds: result.durationSeconds,

        // Puntuación sencilla y comparable:
        // un punto por globo explotado.
        score: result.stats.popped,

        objectiveLabel: 'Globos explotados',
        completedObjective: result.stats.popped,
        targetObjective: result.stats.total,

        // Canal rojo
        redSuccess: result.stats.redPopped,
        redErrors: result.stats.redEscaped,

        // Canal verde
        greenSuccess: result.stats.greenPopped,
        greenErrors: result.stats.greenEscaped,

        eventsCount: result.events.length,
        observation: result.mainObservation,
        averageReactionTimeMs: result.averageReactionTimeMs,
      ),
    );

    debugPrint('===== RESULTADO TÉCNICO EXPLOTA LOS GLOBOS =====');
    debugPrint('Explotados: ${result.stats.popped}');
    debugPrint('Escapados: ${result.stats.escaped}');
    debugPrint(
      'Rojo: ${result.stats.redPopped} / '
      '${result.stats.redEscaped}',
    );
    debugPrint(
      'Verde: ${result.stats.greenPopped} / '
      '${result.stats.greenEscaped}',
    );
    debugPrint(
      'Reacción promedio: '
      '${result.averageReactionTimeMs?.toStringAsFixed(1) ?? "N/A"} ms',
    );
    debugPrint('===============================================');
  }

  void exitGame() {
    final currentGame = game;

    if (currentGame != null &&
        currentGame.hasStarted &&
        currentGame.finalResult == null) {
      final result = currentGame.finishSession(BalloonEndReason.manual);

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
      backgroundColor: const Color(0xFFF4F4F5),
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(game: currentGame),

            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: ValueListenableBuilder<BalloonStats>(
                valueListenable: currentGame.stats,
                builder: (context, stats, _) {
                  return ValueListenableBuilder<double>(
                    valueListenable: currentGame.remainingSeconds,
                    builder: (context, remaining, _) {
                      return Container(
                        padding: const EdgeInsets.all(14),
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
                                const Expanded(
                                  child: Text(
                                    'Explota los Globos',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.navy,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
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
                                Text(
                                  '🎈 ${stats.popped}',
                                  style: const TextStyle(
                                    color: AppColors.navy,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '${remaining.ceil()} s',
                                  style: const TextStyle(
                                    color: AppColors.purple,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Escaparon: ${stats.escaped}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            if (countdownValue != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.30),
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
