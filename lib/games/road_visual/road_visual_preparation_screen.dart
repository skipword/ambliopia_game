import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/models/eye.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/game_preparation_scaffold.dart';
import 'road_visual_level.dart';

class RoadVisualPreparationScreen extends StatefulWidget {
  const RoadVisualPreparationScreen({super.key});

  @override
  State<RoadVisualPreparationScreen> createState() =>
      _RoadVisualPreparationScreenState();
}

class _RoadVisualPreparationScreenState
    extends State<RoadVisualPreparationScreen> {
  RoadVisualDifficulty selectedDifficulty = RoadVisualDifficulty.basic;

  void startGame() {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.roadVisual, arguments: selectedDifficulty);
  }

  void recalibrate() {
    final appState = context.read<AppState>();

    appState.setCalibrationReturnRoute(AppRoutes.roadVisualPreparation);

    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final redEye = appState.redLensEye?.label ?? 'Ojo configurado';

    final greenEye = appState.greenLensEye?.label ?? 'Ojo dominante';

    return GamePreparationScaffold(
      title: 'Ruta Visual',
      subtitle: 'Seguimiento y coordinación visual.',
      icon: Icons.directions_car_rounded,
      accentColor: const Color(0xFF6E9FD6),
      redEye: redEye,
      greenEye: greenEye,
      selectedDifficultyIndex: RoadVisualDifficulty.values.indexOf(
        selectedDifficulty,
      ),
      onDifficultySelected: (index) {
        setState(() {
          selectedDifficulty = RoadVisualDifficulty.values[index];
        });
      },
      instructions: const [
        GamePreparationInstruction(
          icon: Icons.swap_horiz_rounded,
          text: 'Cambia de carril para conducir.',
        ),
        GamePreparationInstruction(
          icon: Icons.diamond_rounded,
          text: 'Recoge rojos y evita verdes.',
        ),
        GamePreparationInstruction(
          icon: Icons.timer_rounded,
          text: '60 segundos · 3 vidas.',
        ),
      ],
      onPlay: startGame,
      onRecalibrate: recalibrate,
    );
  }
}
