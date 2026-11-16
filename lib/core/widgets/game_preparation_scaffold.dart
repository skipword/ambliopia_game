import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

class GamePreparationInstruction {
  const GamePreparationInstruction({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class GamePreparationScaffold extends StatelessWidget {
  const GamePreparationScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.redEye,
    required this.greenEye,
    required this.selectedDifficultyIndex,
    required this.onDifficultySelected,
    required this.instructions,
    required this.onPlay,
    required this.onRecalibrate,
    super.key,
  });

  final String title;
  final String subtitle;

  final IconData icon;
  final Color accentColor;

  final String redEye;
  final String greenEye;

  final int selectedDifficultyIndex;
  final ValueChanged<int> onDifficultySelected;

  final List<GamePreparationInstruction> instructions;

  final VoidCallback onPlay;
  final VoidCallback onRecalibrate;

  static const difficultyNames = ['Fácil', 'Medio', 'Reto'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Preparar'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                _GameHeader(
                  title: title,
                  subtitle: subtitle,
                  icon: icon,
                  accentColor: accentColor,
                ),

                const SizedBox(height: 16),

                _GlassesBar(redEye: redEye, greenEye: greenEye),

                const SizedBox(height: 20),

                const Text(
                  'Elige tu nivel',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 11),

                Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index < 2 ? 9 : 0),
                        child: _DifficultyCard(
                          index: index,
                          selected: selectedDifficultyIndex == index,
                          accentColor: accentColor,
                          onTap: () {
                            onDifficultySelected(index);
                          },
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < instructions.length; i++) ...[
                        _InstructionRow(
                          instruction: instructions[i],
                          accentColor: accentColor,
                        ),
                        if (i < instructions.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(height: 1),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 6, 20, 12),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: onPlay,
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: const Text(
                      'JUGAR',
                      style: TextStyle(
                        fontSize: 18,
                        letterSpacing: 0.7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                TextButton.icon(
                  onPressed: onRecalibrate,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text(
                    'Recalibrar gafas',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: accentColor, size: 34),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 25,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassesBar extends StatelessWidget {
  const _GlassesBar({required this.redEye, required this.greenEye});

  final String redEye;
  final String greenEye;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_rounded, color: AppColors.navy, size: 23),

          const SizedBox(width: 11),

          Expanded(
            child: Row(
              children: [
                const Icon(Icons.circle, color: AppColors.red, size: 13),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    redEye,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 1,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.black.withValues(alpha: 0.08),
          ),

          Expanded(
            child: Row(
              children: [
                const Icon(Icons.circle, color: AppColors.green, size: 13),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    greenEye,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.index,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? accentColor.withValues(alpha: 0.11) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? accentColor
                  : Colors.black.withValues(alpha: 0.05),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (starIndex) {
                  final active = starIndex <= index;

                  return Icon(
                    active ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: active
                        ? accentColor
                        : Colors.grey.withValues(alpha: 0.35),
                    size: 19,
                  );
                }),
              ),

              const SizedBox(height: 7),

              Text(
                GamePreparationScaffold.difficultyNames[index],
                style: TextStyle(
                  color: selected ? accentColor : AppColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({required this.instruction, required this.accentColor});

  final GamePreparationInstruction instruction;

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(instruction.icon, color: accentColor, size: 21),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            instruction.text,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
