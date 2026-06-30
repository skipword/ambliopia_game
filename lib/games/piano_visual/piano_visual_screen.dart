import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../core/models/eye.dart';
import '../../core/state/app_state.dart';
import 'piano_visual_game.dart';

class PianoVisualScreen extends StatefulWidget {
  const PianoVisualScreen({super.key});

  @override
  State<PianoVisualScreen> createState() => _PianoVisualScreenState();
}

class _PianoVisualScreenState extends State<PianoVisualScreen> {
  late final PianoVisualGame game;

  @override
  void initState() {
    super.initState();

    final appState = context.read<AppState>();

    game = PianoVisualGame(
      redContrast: appState.redContrast,
      greenContrast: appState.greenContrast,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final redEye = appState.redLensEye?.shortLabel ?? 'configurado';
    final greenEye = appState.greenLensEye?.shortLabel ?? 'dominante';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(game: game),
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: ValueListenableBuilder<PianoStats>(
                valueListenable: game.stats,
                builder: (context, stats, _) {
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
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              label: 'Aciertos',
                              value: '${stats.hits}',
                            ),
                            _StatItem(
                              label: 'Errores',
                              value: '${stats.misses}',
                            ),
                            _StatItem(
                              label: 'Rojo',
                              value: '${stats.redHits}',
                              color: AppColors.red,
                            ),
                            _StatItem(
                              label: 'Verde',
                              value: '${stats.greenHits}',
                              color: AppColors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '🔴 ojo $redEye  ·  🟢 ojo $greenEye',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
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

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: color ?? AppColors.navy,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
