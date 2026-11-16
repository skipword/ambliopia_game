import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/app_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openGame(BuildContext context, {required String preparationRoute}) {
    final appState = context.read<AppState>();

    if (appState.hasCompletedCalibration) {
      Navigator.of(context).pushNamed(preparationRoute);
      return;
    }

    appState.setCalibrationReturnRoute(preparationRoute);

    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final patientName = appState.patientDisplayName;

    final games = [
      _GameInfo(
        title: 'Piano Visual',
        skill: 'Atención visual',
        description: 'Toca las fichas a tiempo.',
        color: const Color(0xFF54C9D9),
        background: const Color(0xFFE6F8FB),
        visual: _GameVisualType.piano,
        onTap: () {
          _openGame(context, preparationRoute: AppRoutes.pianoPreparation);
        },
      ),
      _GameInfo(
        title: 'Rompe la Fila',
        skill: 'Planificación',
        description: 'Completa las filas.',
        color: const Color(0xFF62C98B),
        background: const Color(0xFFEAF9F0),
        visual: _GameVisualType.blocks,
        onTap: () {
          _openGame(
            context,
            preparationRoute: AppRoutes.breakTheRowPreparation,
          );
        },
      ),
      _GameInfo(
        title: 'Gallina en Ruta',
        skill: 'Coordinación',
        description: 'Cruza y recoge.',
        color: const Color(0xFFF0A35E),
        background: const Color(0xFFFFF3E8),
        visual: _GameVisualType.farm,
        onTap: () {
          _openGame(
            context,
            preparationRoute: AppRoutes.farmCrossingPreparation,
          );
        },
      ),
      _GameInfo(
        title: 'Explota Globos',
        skill: 'Reacción visual',
        description: 'Explota antes de que escapen.',
        color: const Color(0xFF9D8FE8),
        background: const Color(0xFFF1EEFF),
        visual: _GameVisualType.balloons,
        onTap: () {
          _openGame(context, preparationRoute: AppRoutes.balloonPreparation);
        },
      ),
      _GameInfo(
        title: 'Ruta Visual',
        skill: 'Seguimiento',
        description: 'Esquiva vehículos y recoge objetivos.',
        color: const Color(0xFF6E9FD6),
        background: const Color(0xFFEAF2FB),
        visual: _GameVisualType.road,
        onTap: () {
          _openGame(context, preparationRoute: AppRoutes.roadVisualPreparation);
        },
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, $patientName 👋',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '¿Qué jugamos hoy?',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.sports_esports_rounded,
                        color: AppColors.cyan,
                        size: 29,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 17),

                _CalibrationBar(
                  calibrated: appState.hasCompletedCalibration,
                  onTap: () {
                    appState.setCalibrationReturnRoute(AppRoutes.home);

                    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
                  },
                ),

                const SizedBox(height: 18),

                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 14.0;

                    final cardWidth = (constraints.maxWidth - spacing) / 2;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          height: 220,
                          child: _GameCard(game: games[0]),
                        ),
                        SizedBox(
                          width: cardWidth,
                          height: 220,
                          child: _GameCard(game: games[1]),
                        ),
                        SizedBox(
                          width: cardWidth,
                          height: 220,
                          child: _GameCard(game: games[2]),
                        ),
                        SizedBox(
                          width: cardWidth,
                          height: 220,
                          child: _GameCard(game: games[3]),
                        ),

                        SizedBox(
                          width: constraints.maxWidth,
                          height: 150,
                          child: _WideGameCard(game: games[4]),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

enum _GameVisualType { piano, blocks, farm, balloons, road }

class _GameInfo {
  const _GameInfo({
    required this.title,
    required this.skill,
    required this.description,
    required this.color,
    required this.background,
    required this.visual,
    required this.onTap,
  });

  final String title;
  final String skill;
  final String description;

  final Color color;
  final Color background;

  final _GameVisualType visual;

  final VoidCallback onTap;
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game});

  final _GameInfo game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: game.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: game.color.withValues(alpha: 0.10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 11,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: game.background,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _GameArtwork(type: game.visual),
                ),
              ),

              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 11, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: game.background,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          game.skill,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: game.color,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        game.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const Spacer(),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              game.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11.5,
                                height: 1.15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),

                          _PlayArrow(color: game.color),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideGameCard extends StatelessWidget {
  const _WideGameCard({required this.game});

  final _GameInfo game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: game.onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: game.color.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: game.background,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _GameArtwork(type: game.visual),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, right: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: game.background,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          game.skill,
                          style: TextStyle(
                            color: game.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        game.title,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const Spacer(),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              game.description,
                              maxLines: 2,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _PlayArrow(color: game.color),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayArrow extends StatelessWidget {
  const _PlayArrow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}

class _CalibrationBar extends StatelessWidget {
  const _CalibrationBar({required this.calibrated, required this.onTap});

  final bool calibrated;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = calibrated
        ? const Color(0xFFEAF9F0)
        : const Color(0xFFFFF3E8);

    final accent = calibrated
        ? const Color(0xFF48AD71)
        : const Color(0xFFE9954F);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  calibrated ? Icons.check_rounded : Icons.visibility_outlined,
                  color: accent,
                  size: 22,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      calibrated ? 'Gafas listas' : 'Calibra tus gafas',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      calibrated
                          ? 'Toca para recalibrar'
                          : 'Necesario antes de jugar',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.tune_rounded, color: accent, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameArtwork extends StatelessWidget {
  const _GameArtwork({required this.type});

  final _GameVisualType type;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _GameVisualType.piano:
        return const _PianoArtwork();

      case _GameVisualType.blocks:
        return const _BlocksArtwork();

      case _GameVisualType.farm:
        return const _FarmArtwork();

      case _GameVisualType.balloons:
        return const _BalloonArtwork();

      case _GameVisualType.road:
        return const _RoadArtwork();
    }
  }
}

class _PianoArtwork extends StatelessWidget {
  const _PianoArtwork();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final laneWidth = constraints.maxWidth / 4;

          return ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              children: [
                Container(color: const Color(0xFF242938)),

                for (int i = 1; i < 4; i++)
                  Positioned(
                    left: laneWidth * i - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 9,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      border: const Border(
                        bottom: BorderSide(color: Color(0xFFFFD45C), width: 3),
                      ),
                    ),
                  ),
                ),

                _PianoTile(
                  laneWidth: laneWidth,
                  lane: 0,
                  top: 8,
                  height: 37,
                  color: const Color(0xFFE95F66),
                ),

                _PianoTile(
                  laneWidth: laneWidth,
                  lane: 1,
                  top: 38,
                  height: 54,
                  color: const Color(0xFF55C780),
                ),

                _PianoTile(
                  laneWidth: laneWidth,
                  lane: 2,
                  top: 13,
                  height: 35,
                  color: const Color(0xFF55C780),
                ),

                _PianoTile(
                  laneWidth: laneWidth,
                  lane: 3,
                  top: 52,
                  height: 38,
                  color: const Color(0xFFE95F66),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PianoTile extends StatelessWidget {
  const _PianoTile({
    required this.laneWidth,
    required this.lane,
    required this.top,
    required this.height,
    required this.color,
  });

  final double laneWidth;
  final int lane;
  final double top;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: lane * laneWidth + laneWidth * 0.20,
      top: top,
      child: Container(
        width: laneWidth * 0.60,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(7),
        ),
      ),
    );
  }
}

class _BlocksArtwork extends StatelessWidget {
  const _BlocksArtwork();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 84,
        height: 96,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF252A36),
          borderRadius: BorderRadius.circular(11),
        ),
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 30,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 2.5,
            mainAxisSpacing: 2.5,
          ),
          itemBuilder: (context, index) {
            Color color = Colors.transparent;

            const redCells = {18, 19, 24, 25, 26, 27};

            const greenCells = {15, 21, 22, 28, 29};

            if (redCells.contains(index)) {
              color = const Color(0xFFE95F66);
            }

            if (greenCells.contains(index)) {
              color = const Color(0xFF55C780);
            }

            return Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FarmArtwork extends StatelessWidget {
  const _FarmArtwork();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(9),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Césped superior.
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 24,
              child: ColoredBox(color: Color(0xFFDCF1DF)),
            ),

            // Carretera despejada.
            const Positioned(
              left: 0,
              right: 0,
              top: 24,
              bottom: 25,
              child: ColoredBox(color: Color(0xFF5D646C)),
            ),

            // Césped inferior.
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 25,
              child: ColoredBox(color: Color(0xFFDCF1DF)),
            ),

            // Objetivo: claramente separado.
            const Positioned(
              right: 16,
              top: 2,
              child: Icon(
                Icons.star_rounded,
                color: Color(0xFFE95F66),
                size: 22,
              ),
            ),

            // Vehículo superior.
            const Positioned(
              left: 12,
              top: 29,
              child: Icon(
                Icons.directions_car_filled_rounded,
                color: Color(0xFF55C780),
                size: 28,
              ),
            ),

            // Vehículo inferior.
            const Positioned(
              right: 13,
              bottom: 30,
              child: Icon(
                Icons.local_shipping_rounded,
                color: Color(0xFF55C780),
                size: 29,
              ),
            ),

            // Trayectoria visual.
            const Positioned(
              left: 0,
              right: 0,
              top: 43,
              child: Center(
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: Color(0xFFABB1B8),
                  size: 20,
                ),
              ),
            ),

            // Gallina roja claramente
            // separada del tráfico.
            const Positioned(
              left: 18,
              bottom: 1,
              child: SizedBox(
                width: 38,
                height: 38,
                child: CustomPaint(painter: _ChickenPainter()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChickenPainter extends CustomPainter {
  const _ChickenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFFE95F66);

    final paint = Paint()..color = color;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.42, size.height * 0.62),
        width: size.width * 0.54,
        height: size.height * 0.47,
      ),
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.64, size.height * 0.34),
      size.width * 0.16,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.60, size.height * 0.15),
      size.width * 0.06,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.69, size.height * 0.14),
      size.width * 0.055,
      paint,
    );

    final beak = Path()
      ..moveTo(size.width * 0.78, size.height * 0.31)
      ..lineTo(size.width * 0.97, size.height * 0.37)
      ..lineTo(size.width * 0.78, size.height * 0.42)
      ..close();

    canvas.drawPath(beak, paint);

    final legs = Paint()
      ..color = color
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.81),
      Offset(size.width * 0.31, size.height),
      legs,
    );

    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.81),
      Offset(size.width * 0.56, size.height),
      legs,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _BalloonArtwork extends StatelessWidget {
  const _BalloonArtwork();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 13,
          bottom: 0,
          child: _MiniBalloon(color: Color(0xFFE95F66), size: 36),
        ),

        Positioned(
          left: 55,
          top: 23,
          child: _MiniBalloon(color: Color(0xFF55C780), size: 31),
        ),

        Positioned(
          right: 12,
          bottom: 7,
          child: _MiniBalloon(color: Color(0xFFE95F66), size: 42),
        ),

        Positioned(
          right: 18,
          top: 5,
          child: SizedBox(
            width: 42,
            height: 42,
            child: CustomPaint(
              painter: _BalloonBurstPainter(color: Color(0xFF55C780)),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniBalloon extends StatelessWidget {
  const _MiniBalloon({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.50,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size),
            ),
          ),
          Positioned(
            top: size - 2,
            child: Container(width: 2, height: size * 0.45, color: color),
          ),
        ],
      ),
    );
  }
}

class _BalloonBurstPainter extends CustomPainter {
  const _BalloonBurstPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, 4, paint);

    const directions = [
      Offset(0, -17),
      Offset(0, 17),
      Offset(-17, 0),
      Offset(17, 0),
      Offset(-12, -12),
      Offset(12, -12),
      Offset(-12, 12),
      Offset(12, 12),
    ];

    for (final offset in directions) {
      final direction = offset / offset.distance;

      canvas.drawLine(center + direction * 8, center + offset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BalloonBurstPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _RoadArtwork extends StatelessWidget {
  const _RoadArtwork();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Color(0xFFDDE3E8))),

            Positioned(
              left: 12,
              right: 12,
              top: 0,
              bottom: 0,
              child: Container(color: const Color(0xFF414750)),
            ),

            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(),
                  _RoadDashedLine(),
                  SizedBox(),
                  _RoadDashedLine(),
                  SizedBox(),
                ],
              ),
            ),

            const Positioned(
              left: 25,
              top: 12,
              child: Icon(
                Icons.directions_car_filled_rounded,
                color: Color(0xFF55C780),
                size: 28,
              ),
            ),

            const Positioned(
              right: 25,
              top: 38,
              child: Icon(
                Icons.directions_car_filled_rounded,
                color: Color(0xFF55C780),
                size: 28,
              ),
            ),

            const Positioned(
              right: 33,
              bottom: 20,
              child: Icon(
                Icons.diamond_rounded,
                color: Color(0xFFE95F66),
                size: 19,
              ),
            ),

            const Positioned(
              left: 0,
              right: 0,
              bottom: 2,
              child: Center(
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: Color(0xFFE95F66),
                  size: 38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoadDashedLine extends StatelessWidget {
  const _RoadDashedLine();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        5,
        (_) => Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
