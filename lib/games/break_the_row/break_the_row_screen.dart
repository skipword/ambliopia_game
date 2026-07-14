import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'break_the_row_level.dart';

class BreakTheRowScreen extends StatelessWidget {
  const BreakTheRowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final difficulty =
        ModalRoute.of(context)?.settings.arguments as BreakTheRowDifficulty? ??
        BreakTheRowDifficulty.basic;

    final config = difficulty.config;

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text('Rompe la Fila'),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Text(
                      config.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Objetivo: ${config.targetLines} líneas · Vidas: ${config.maxLives}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: config.boardColumns / config.boardRows,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.cyan.withValues(alpha: 0.8),
                          width: 3,
                        ),
                      ),
                      child: CustomPaint(
                        painter: _BoardPreviewPainter(
                          columns: config.boardColumns,
                          rows: config.boardRows,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Aquí conectaremos el tablero real con Flame.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _ControlButton(icon: Icons.arrow_left, onTap: () {}),
                  const SizedBox(width: 10),
                  _ControlButton(icon: Icons.rotate_right, onTap: () {}),
                  const SizedBox(width: 10),
                  _ControlButton(icon: Icons.arrow_right, onTap: () {}),
                  const SizedBox(width: 10),
                  _ControlButton(
                    icon: Icons.keyboard_double_arrow_down,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
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
        child: FilledButton(onPressed: onTap, child: Icon(icon, size: 32)),
      ),
    );
  }
}

class _BoardPreviewPainter extends CustomPainter {
  const _BoardPreviewPainter({required this.columns, required this.rows});

  final int columns;
  final int rows;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;

    for (int column = 1; column < columns; column++) {
      final x = column * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    for (int row = 1; row < rows; row++) {
      final y = row * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPreviewPainter oldDelegate) {
    return oldDelegate.columns != columns || oldDelegate.rows != rows;
  }
}
