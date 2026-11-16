import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/app_bottom_nav.dart';

class GamesMenuScreen extends StatelessWidget {
  const GamesMenuScreen({super.key});

  void _openGame(BuildContext context, {required String preparationRoute}) {
    final appState = context.read<AppState>();

    if (appState.hasCompletedCalibration) {
      Navigator.of(context).pushNamed(preparationRoute);
      return;
    }

    appState.setCalibrationReturnRoute(preparationRoute);

    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
  }

  void startPianoVisual(BuildContext context) {
    _openGame(context, preparationRoute: AppRoutes.pianoPreparation);
  }

  void startBreakTheRow(BuildContext context) {
    _openGame(context, preparationRoute: AppRoutes.breakTheRowPreparation);
  }

  void startFarmCrossing(BuildContext context) {
    _openGame(context, preparationRoute: AppRoutes.farmCrossingPreparation);
  }

  void startBalloonPop(BuildContext context) {
    _openGame(context, preparationRoute: AppRoutes.balloonPreparation);
  }

  void startRoadVisual(BuildContext context) {
    _openGame(context, preparationRoute: AppRoutes.roadVisualPreparation);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final games = [
      _GameInfo(
        title: 'Piano Visual',
        skill: 'Atención visual',
        description: 'Toca las fichas a tiempo.',
        color: const Color(0xFF54C9D9),
        background: const Color(0xFFE6F8FB),
        visual: _GameVisualType.piano,
        onTap: () {
          startPianoVisual(context);
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
          startBreakTheRow(context);
        },
      ),
      _GameInfo(
        title: 'Cruza la Granja',
        skill: 'Coordinación',
        description: 'Cruza y recoge.',
        color: const Color(0xFFF0A35E),
        background: const Color(0xFFFFF3E8),
        visual: _GameVisualType.farm,
        onTap: () {
          startFarmCrossing(context);
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
          startBalloonPop(context);
        },
      ),
      _GameInfo(
        title: 'Ruta Visual',
        skill: 'Seguimiento',
        description: 'Esquiva y recoge.',
        color: const Color(0xFF6E9FD6),
        background: const Color(0xFFEAF2FB),
        visual: _GameVisualType.road,
        onTap: () {
          startRoadVisual(context);
        },
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Qué jugamos?',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Elige un juego y empieza.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.sports_esports_rounded,
                  color: AppColors.cyan,
                  size: 38,
                ),
              ],
            ),

            const SizedBox(height: 18),

            _CalibrationBar(
              calibrated: appState.hasCompletedCalibration,
              onTap: () {
                appState.setCalibrationReturnRoute(AppRoutes.games);

                Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
              },
            ),

            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                final columns = width >= 850 ? 3 : 2;

                final ratio = width >= 850
                    ? 0.92
                    : width >= 550
                    ? 0.86
                    : 0.72;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: games.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: ratio,
                  ),
                  itemBuilder: (context, index) {
                    final game = games[index];

                    return _GameCard(game: game);
                  },
                );
              },
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFE98080),
                    size: 23,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Juega con calma y descansa tus ojos al terminar.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
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
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: game.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: game.color.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: game.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _GameArtwork(type: game.visual, color: game.color),
                ),
              ),

              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 4, 13, 13),
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          game.skill,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 17,
                          height: 1.05,
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
                                fontSize: 12,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),

                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: game.color,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
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
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  calibrated ? Icons.check_rounded : Icons.visibility_outlined,
                  color: accent,
                  size: 23,
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
                          ? 'Toca aquí si quieres recalibrar.'
                          : 'Solo necesitas hacerlo antes de jugar.',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                calibrated
                    ? Icons.tune_rounded
                    : Icons.arrow_forward_ios_rounded,
                color: accent,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameArtwork extends StatelessWidget {
  const _GameArtwork({required this.type, required this.color});

  final _GameVisualType type;
  final Color color;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _GameVisualType.piano:
        return _PianoArtwork(color: color);

      case _GameVisualType.blocks:
        return _BlocksArtwork(color: color);

      case _GameVisualType.farm:
        return _FarmArtwork(color: color);

      case _GameVisualType.balloons:
        return _BalloonArtwork(color: color);

      case _GameVisualType.road:
        return _RoadArtwork(color: color);
    }
  }
}

class _PianoArtwork extends StatelessWidget {
  const _PianoArtwork({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final laneWidth = constraints.maxWidth / 4;

          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF242938),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              for (int i = 1; i < 4; i++)
                Positioned(
                  left: laneWidth * i - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 11,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFFFD45C).withValues(alpha: 0.9),
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: laneWidth * 0.18,
                top: 10,
                child: _MiniPianoTile(
                  width: laneWidth * 0.62,
                  height: 38,
                  color: const Color(0xFFE96B70),
                ),
              ),

              Positioned(
                left: laneWidth * 1 + laneWidth * 0.18,
                top: 38,
                child: _MiniPianoTile(
                  width: laneWidth * 0.62,
                  height: 55,
                  color: const Color(0xFF64C990),
                ),
              ),

              Positioned(
                left: laneWidth * 2 + laneWidth * 0.18,
                top: 17,
                child: _MiniPianoTile(
                  width: laneWidth * 0.62,
                  height: 34,
                  color: const Color(0xFF64C990),
                ),
              ),

              Positioned(
                left: laneWidth * 3 + laneWidth * 0.18,
                top: 53,
                child: _MiniPianoTile(
                  width: laneWidth * 0.62,
                  height: 42,
                  color: const Color(0xFFE96B70),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniPianoTile extends StatelessWidget {
  const _MiniPianoTile({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
    );
  }
}

class _BlocksArtwork extends StatelessWidget {
  const _BlocksArtwork({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 92,
        height: 104,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: const Color(0xFF252A36),
          borderRadius: BorderRadius.circular(12),
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
            Color cellColor = Colors.transparent;

            const redCells = {18, 19, 24, 25, 26, 27};

            const greenCells = {15, 21, 22, 28, 29};

            if (redCells.contains(index)) {
              cellColor = const Color(0xFFE96B70);
            }

            if (greenCells.contains(index)) {
              cellColor = const Color(0xFF62C98B);
            }

            return Container(
              decoration: BoxDecoration(
                color: cellColor,
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
  const _FarmArtwork({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(9),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: const Color(0xFFDFF2E3))),

            // Carretera.
            Positioned(
              left: 0,
              right: 0,
              top: 25,
              bottom: 22,
              child: Container(color: const Color(0xFF5D646C)),
            ),

            // Separadores de carril.
            Positioned(left: 0, right: 0, top: 48, child: _MiniRoadDivider()),

            Positioned(left: 0, right: 0, top: 72, child: _MiniRoadDivider()),

            // Vehículos verdes.
            const Positioned(
              left: 12,
              top: 30,
              child: Icon(
                Icons.directions_car_filled_rounded,
                color: Color(0xFF50C47C),
                size: 29,
              ),
            ),

            const Positioned(
              right: 10,
              top: 58,
              child: Icon(
                Icons.local_shipping_rounded,
                color: Color(0xFF50C47C),
                size: 31,
              ),
            ),

            const Positioned(
              left: 48,
              top: 55,
              child: Icon(
                Icons.directions_car_filled_rounded,
                color: Color(0xFF50C47C),
                size: 24,
              ),
            ),

            // Objetivo rojo.
            const Positioned(
              right: 32,
              top: 31,
              child: Icon(
                Icons.star_rounded,
                color: Color(0xFFE95F66),
                size: 22,
              ),
            ),

            // Gallina roja.
            const Positioned(
              left: 33,
              bottom: 1,
              child: SizedBox(
                width: 42,
                height: 42,
                child: CustomPaint(painter: _FarmChickenPainter()),
              ),
            ),

            // Flecha indicando que cruza.
            const Positioned(
              left: 77,
              bottom: 8,
              child: Icon(
                Icons.arrow_upward_rounded,
                color: Color(0xFF8B939C),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniRoadDivider extends StatelessWidget {
  const _MiniRoadDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        4,
        (_) => Container(
          width: 18,
          height: 2,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _FarmChickenPainter extends CustomPainter {
  const _FarmChickenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const red = Color(0xFFE95F66);

    final paint = Paint()..color = red;

    // Cuerpo.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.48, size.height * 0.61),
        width: size.width * 0.61,
        height: size.height * 0.52,
      ),
      paint,
    );

    // Cabeza.
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.32),
      size.width * 0.18,
      paint,
    );

    // Cresta.
    canvas.drawCircle(
      Offset(size.width * 0.59, size.height * 0.13),
      size.width * 0.07,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.69, size.height * 0.12),
      size.width * 0.065,
      paint,
    );

    // Pico: seguimos dentro del
    // mismo canal rojo.
    final beak = Path()
      ..moveTo(size.width * 0.82, size.height * 0.30)
      ..lineTo(size.width, size.height * 0.37)
      ..lineTo(size.width * 0.82, size.height * 0.42)
      ..close();

    canvas.drawPath(beak, paint);

    // Patas.
    final legPaint = Paint()
      ..color = red
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.40, size.height * 0.82),
      Offset(size.width * 0.34, size.height),
      legPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.59, size.height * 0.82),
      Offset(size.width * 0.64, size.height),
      legPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _BalloonArtwork extends StatelessWidget {
  const _BalloonArtwork({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Globo rojo subiendo.
        const Positioned(
          left: 14,
          bottom: 1,
          child: _MiniBalloon(color: Color(0xFFE95F66), size: 38),
        ),

        // Globo verde.
        const Positioned(
          left: 57,
          top: 22,
          child: _MiniBalloon(color: Color(0xFF56C882), size: 33),
        ),

        // Otro globo rojo.
        const Positioned(
          right: 13,
          bottom: 8,
          child: _MiniBalloon(color: Color(0xFFE95F66), size: 43),
        ),

        // Globo explotando.
        const Positioned(
          right: 20,
          top: 7,
          child: SizedBox(
            width: 43,
            height: 43,
            child: CustomPaint(
              painter: _BalloonBurstPainter(color: Color(0xFF56C882)),
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
      height: size * 1.55,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: size,
            height: size * 1.04,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size),
            ),
          ),

          Positioned(
            top: size * 0.94,
            child: Transform.rotate(
              angle: 0.78,
              child: Container(
                width: size * 0.16,
                height: size * 0.16,
                color: color,
              ),
            ),
          ),

          Positioned(
            top: size * 1.05,
            child: Container(width: 2, height: size * 0.48, color: color),
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
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Pequeño centro de explosión.
    canvas.drawCircle(center, 5, paint);

    final rays = [
      const Offset(0, -18),
      const Offset(0, 18),
      const Offset(-18, 0),
      const Offset(18, 0),
      const Offset(-13, -13),
      const Offset(13, -13),
      const Offset(-13, 13),
      const Offset(13, 13),
    ];

    for (final ray in rays) {
      final direction = ray / ray.distance;

      final start = center + direction * 9;

      final end = center + ray;

      canvas.drawLine(start, end, paint);
    }

    // Fragmentos del globo.
    canvas.drawCircle(const Offset(8, 10), 3, paint);

    canvas.drawCircle(Offset(size.width - 7, size.height - 11), 2.5, paint);

    canvas.drawCircle(Offset(size.width - 9, 7), 2.5, paint);
  }

  @override
  bool shouldRepaint(covariant _BalloonBurstPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _RoadArtwork extends StatelessWidget {
  const _RoadArtwork({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(9),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: const Color(0xFFDDE3E8))),

            // Carretera más ancha y claramente
            // dividida en 3 carriles.
            Positioned(
              left: 15,
              right: 15,
              top: 0,
              bottom: 0,
              child: Container(color: const Color(0xFF424851)),
            ),

            // Primera separación.
            Positioned(
              left: 52,
              top: 0,
              bottom: 0,
              child: _VerticalRoadMarks(),
            ),

            // Segunda separación.
            Positioned(
              right: 52,
              top: 0,
              bottom: 0,
              child: _VerticalRoadMarks(),
            ),

            // Obstáculo verde carril izquierdo.
            const Positioned(
              left: 23,
              top: 13,
              child: Icon(
                Icons.directions_car_filled_rounded,
                color: Color(0xFF54C881),
                size: 30,
              ),
            ),

            // Obstáculo verde carril derecho.
            const Positioned(
              right: 22,
              top: 43,
              child: Icon(
                Icons.directions_car_filled_rounded,
                color: Color(0xFF54C881),
                size: 31,
              ),
            ),

            // Objetivo rojo.
            const Positioned(
              right: 27,
              bottom: 24,
              child: Icon(
                Icons.diamond_rounded,
                color: Color(0xFFE95F66),
                size: 20,
              ),
            ),

            // Vehículo jugador rojo.
            const Positioned(
              left: 0,
              right: 0,
              bottom: 4,
              child: Center(
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: Color(0xFFE95F66),
                  size: 39,
                ),
              ),
            ),

            // Pequeñas líneas de movimiento.
            Positioned(
              left: 0,
              right: 0,
              bottom: 43,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 3,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 3,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalRoadMarks extends StatelessWidget {
  const _VerticalRoadMarks();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        5,
        (_) => Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
