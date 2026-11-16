import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/models/eye.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/game_preparation_scaffold.dart';
import 'farm_crossing_level.dart';

class FarmCrossingPreparationScreen extends StatefulWidget {
  const FarmCrossingPreparationScreen({super.key});

  @override
  State<FarmCrossingPreparationScreen> createState() =>
      _FarmCrossingPreparationScreenState();
}

class _FarmCrossingPreparationScreenState
    extends State<FarmCrossingPreparationScreen> {
  FarmCrossingDifficulty selectedDifficulty = FarmCrossingDifficulty.basic;

  void startGame() {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.farmCrossing, arguments: selectedDifficulty);
  }

  void recalibrate() {
    final appState = context.read<AppState>();

    appState.setCalibrationReturnRoute(AppRoutes.farmCrossingPreparation);

    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final redEye = appState.redLensEye?.label ?? 'Ojo configurado';

    final greenEye = appState.greenLensEye?.label ?? 'Ojo dominante';

    final target = selectedDifficulty.config.targetObjectives;

    return GamePreparationScaffold(
      title: 'Gallina en Ruta',
      subtitle: 'Cruza, esquiva y recoge objetivos.',
      icon: Icons.emoji_nature_rounded,
      accentColor: const Color(0xFFF0A35E),
      redEye: redEye,
      greenEye: greenEye,
      selectedDifficultyIndex: FarmCrossingDifficulty.values.indexOf(
        selectedDifficulty,
      ),
      onDifficultySelected: (index) {
        setState(() {
          selectedDifficulty = FarmCrossingDifficulty.values[index];
        });
      },
      instructions: [
        const GamePreparationInstruction(
          icon: Icons.swipe_rounded,
          text: 'Desliza para mover la gallina.',
        ),
        const GamePreparationInstruction(
          icon: Icons.star_rounded,
          text: 'Recoge los objetivos rojos.',
        ),
        GamePreparationInstruction(
          icon: Icons.favorite_rounded,
          text: '$target objetivos · 3 vidas.',
        ),
      ],
      onPlay: startGame,
      onRecalibrate: recalibrate,
    );
  }
}
