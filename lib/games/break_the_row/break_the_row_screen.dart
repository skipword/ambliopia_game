import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/state/app_state.dart';
import 'break_the_row_game.dart';
import 'break_the_row_level.dart';
import 'break_the_row_session_result.dart';

class BreakTheRowScreen extends StatefulWidget {
  const BreakTheRowScreen({super.key});

  @override
  State<BreakTheRowScreen> createState() => _BreakTheRowScreenState();
}

class _BreakTheRowScreenState extends State<BreakTheRowScreen> {
  BreakTheRowGame? game;
  bool initialized = false;

  int? countdownValue = 3;
  Timer? countdownTimer;
  Timer? hideCountdownTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (initialized) return;

    final appState = context.read<AppState>();

    final difficulty =
        ModalRoute.of(context)?.settings.arguments as BreakTheRowDifficulty? ??
        BreakTheRowDifficulty.basic;

    game = BreakTheRowGame(
      difficulty: difficulty,
      redContrast: appState.redContrast,
      greenContrast: appState.greenContrast,
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

  void goToResults(BreakTheRowSessionResult result) {
    Future.microtask(() {
      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.breakTheRowResults, arguments: result);
    });
  }

  void finishManually() {
    final currentGame = game;
    if (currentGame == null) return;

    final result = currentGame.finishSession(BreakTheRowEndReason.manual);
    goToResults(result);
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
      return const Scaffold(
        backgroundColor: Color(0xFF111827),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: currentGame.rotateCurrentPiece,
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;

                if (velocity < -250) {
                  currentGame.moveLeft();
                }

                if (velocity > 250) {
                  currentGame.moveRight();
                }
              },
              onVerticalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;

                if (velocity > 350) {
                  currentGame.fastDrop();
                }
              },
              child: GameWidget(game: currentGame),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: ValueListenableBuilder<BreakTheRowStats>(
                valueListenable: currentGame.stats,
                builder: (context, stats, _) {
                  final livesLeft =
                      currentGame.config.maxLives - stats.livesLost;

                  return Container(
                    padding: const EdgeInsets.all(14),
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
                                'Rompe la Fila',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            FilledButton(
                              onPressed: stats.totalPieces == 0
                                  ? null
                                  : finishManually,
                              child: const Text('Terminar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Líneas: ${stats.linesCompleted}/${currentGame.config.targetLines}',
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Row(
                              children: List.generate(
                                currentGame.config.maxLives,
                                (index) {
                                  final lost = index >= livesLeft;

                                  return Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      lost
                                          ? Icons.favorite_border
                                          : Icons.favorite,
                                      color: lost ? Colors.grey : AppColors.red,
                                      size: 26,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 88,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: const Text(
                  'Puedes usar los botones o probar gestos en pantalla',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  _ControlButton(
                    icon: Icons.arrow_left,
                    onTap: currentGame.moveLeft,
                  ),
                  const SizedBox(width: 10),
                  _ControlButton(
                    icon: Icons.rotate_right,
                    onTap: currentGame.rotateCurrentPiece,
                  ),
                  const SizedBox(width: 10),
                  _ControlButton(
                    icon: Icons.arrow_right,
                    onTap: currentGame.moveRight,
                  ),
                  const SizedBox(width: 10),
                  _ControlButton(
                    icon: Icons.keyboard_double_arrow_down,
                    onTap: currentGame.fastDrop,
                  ),
                ],
              ),
            ),
            if (countdownValue != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        countdownValue == 0 ? '¡Vamos!' : '$countdownValue',
                        key: ValueKey(countdownValue),
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
        height: 58,
        child: FilledButton(onPressed: onTap, child: Icon(icon, size: 31)),
      ),
    );
  }
}
