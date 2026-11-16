import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/models/eye.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/game_preparation_scaffold.dart';
import 'balloon_level.dart';

class BalloonPreparationScreen extends StatefulWidget {
  const BalloonPreparationScreen({super.key});

  @override
  State<BalloonPreparationScreen> createState() =>
      _BalloonPreparationScreenState();
}

class _BalloonPreparationScreenState extends State<BalloonPreparationScreen> {
  BalloonDifficulty selectedDifficulty = BalloonDifficulty.basic;

  void startGame() {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.balloonPop, arguments: selectedDifficulty);
  }

  void recalibrate() {
    final appState = context.read<AppState>();

    appState.setCalibrationReturnRoute(AppRoutes.balloonPreparation);

    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final redEye = appState.redLensEye?.label ?? 'Ojo configurado';

    final greenEye = appState.greenLensEye?.label ?? 'Ojo dominante';

    return GamePreparationScaffold(
      title: 'Explota Globos',
      subtitle: 'Reacción y búsqueda visual.',
      icon: Icons.bubble_chart_rounded,
      accentColor: const Color(0xFF9D8FE8),
      redEye: redEye,
      greenEye: greenEye,
      selectedDifficultyIndex: BalloonDifficulty.values.indexOf(
        selectedDifficulty,
      ),
      onDifficultySelected: (index) {
        setState(() {
          selectedDifficulty = BalloonDifficulty.values[index];
        });
      },
      instructions: const [
        GamePreparationInstruction(
          icon: Icons.touch_app_rounded,
          text: 'Toca los globos para explotarlos.',
        ),
        GamePreparationInstruction(
          icon: Icons.vertical_align_top_rounded,
          text: 'No dejes que lleguen hasta arriba.',
        ),
        GamePreparationInstruction(
          icon: Icons.timer_rounded,
          text: 'Tienes 60 segundos.',
        ),
      ],
      onPlay: startGame,
      onRecalibrate: recalibrate,
    );
  }
}
