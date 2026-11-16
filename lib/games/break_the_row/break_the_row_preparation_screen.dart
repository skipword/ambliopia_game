import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/models/eye.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/game_preparation_scaffold.dart';
import 'break_the_row_level.dart';

class BreakTheRowPreparationScreen extends StatefulWidget {
  const BreakTheRowPreparationScreen({super.key});

  @override
  State<BreakTheRowPreparationScreen> createState() =>
      _BreakTheRowPreparationScreenState();
}

class _BreakTheRowPreparationScreenState
    extends State<BreakTheRowPreparationScreen> {
  BreakTheRowDifficulty selectedDifficulty = BreakTheRowDifficulty.basic;

  void startGame() {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.breakTheRow, arguments: selectedDifficulty);
  }

  void recalibrate() {
    final appState = context.read<AppState>();

    appState.setCalibrationReturnRoute(AppRoutes.breakTheRowPreparation);

    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final redEye = appState.redLensEye?.label ?? 'Ojo configurado';

    final greenEye = appState.greenLensEye?.label ?? 'Ojo dominante';

    final targetLines = selectedDifficulty.config.targetLines;

    return GamePreparationScaffold(
      title: 'Rompe la Fila',
      subtitle: 'Planifica, mueve y completa líneas.',
      icon: Icons.grid_view_rounded,
      accentColor: const Color(0xFF62C98B),
      redEye: redEye,
      greenEye: greenEye,
      selectedDifficultyIndex: BreakTheRowDifficulty.values.indexOf(
        selectedDifficulty,
      ),
      onDifficultySelected: (index) {
        setState(() {
          selectedDifficulty = BreakTheRowDifficulty.values[index];
        });
      },
      instructions: [
        const GamePreparationInstruction(
          icon: Icons.swipe_rounded,
          text: 'Desliza para mover las piezas.',
        ),
        const GamePreparationInstruction(
          icon: Icons.rotate_right_rounded,
          text: 'Toca para rotar y desliza abajo para bajar.',
        ),
        GamePreparationInstruction(
          icon: Icons.flag_rounded,
          text: '$targetLines líneas · 3 vidas.',
        ),
      ],
      onPlay: startGame,
      onRecalibrate: recalibrate,
    );
  }
}
