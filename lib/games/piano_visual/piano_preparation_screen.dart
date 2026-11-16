import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/models/eye.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/game_preparation_scaffold.dart';
import 'piano_level.dart';

class PianoPreparationScreen extends StatefulWidget {
  const PianoPreparationScreen({super.key});

  @override
  State<PianoPreparationScreen> createState() => _PianoPreparationScreenState();
}

class _PianoPreparationScreenState extends State<PianoPreparationScreen> {
  PianoDifficulty selectedDifficulty = PianoDifficulty.basic;

  void startGame() {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.pianoVisual, arguments: selectedDifficulty);
  }

  void recalibrate() {
    final appState = context.read<AppState>();

    appState.setCalibrationReturnRoute(AppRoutes.pianoPreparation);

    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final redEye = appState.redLensEye?.label ?? 'Ojo configurado';

    final greenEye = appState.greenLensEye?.label ?? 'Ojo dominante';

    return GamePreparationScaffold(
      title: 'Piano Visual',
      subtitle: 'Atención, precisión y ritmo visual.',
      icon: Icons.piano_rounded,
      accentColor: const Color(0xFF54C9D9),
      redEye: redEye,
      greenEye: greenEye,
      selectedDifficultyIndex: PianoDifficulty.values.indexOf(
        selectedDifficulty,
      ),
      onDifficultySelected: (index) {
        setState(() {
          selectedDifficulty = PianoDifficulty.values[index];
        });
      },
      instructions: const [
        GamePreparationInstruction(
          icon: Icons.touch_app_rounded,
          text: 'Toca las fichas en la zona indicada.',
        ),
        GamePreparationInstruction(
          icon: Icons.pan_tool_alt_rounded,
          text: 'Mantén presionadas las fichas largas.',
        ),
        GamePreparationInstruction(
          icon: Icons.flag_rounded,
          text: '90 s · 40 fichas · máximo 3 errores.',
        ),
      ],
      onPlay: startGame,
      onRecalibrate: recalibrate,
    );
  }
}
