import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../../core/services/game_music_service.dart';
import 'balloon_level.dart';
import 'balloon_session_result.dart';

enum BalloonShape { circle, star, diamond, triangle, heart }

class BalloonPopGame extends FlameGame {
  BalloonPopGame({
    required this.redContrast,
    required this.greenContrast,
    required this.difficulty,
    required this.onSessionFinished,
  }) : config = difficulty.config;

  static const String popSound = 'balloon_pop.mp3';

  final double redContrast;
  final double greenContrast;

  final BalloonDifficulty difficulty;
  final BalloonLevelConfig config;

  final void Function(BalloonSessionResult result) onSessionFinished;

  final Random random = Random();

  final ValueNotifier<BalloonStats> stats = ValueNotifier(BalloonStats.empty());

  final ValueNotifier<double> remainingSeconds = ValueNotifier(
    BalloonLevelConfig.sessionDurationSeconds,
  );

  final List<BalloonEvent> _events = [];

  // Mantiene una proporción equilibrada de estímulos
  // rojos y verdes.
  final List<BalloonChannel> _channelBag = [];

  DateTime? _startedAt;

  BalloonSessionResult? _finalResult;

  BalloonSessionResult? get finalResult => _finalResult;

  double elapsedSeconds = 0;
  double spawnTimer = 0;

  int nextBalloonId = 1;

  bool hasStarted = false;
  bool isSessionFinished = false;

  double get speedMultiplier {
    if (elapsedSeconds < 20) {
      return 1.00;
    }

    if (elapsedSeconds < 40) {
      return 1.10;
    }

    return 1.20;
  }

  double get escapeBoundaryY {
    if (!hasLayout) {
      return 140;
    }

    return min(150.0, size.y * 0.22).toDouble();
  }

  @override
  Color backgroundColor() {
    return const Color(0xFFF4F4F5);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await FlameAudio.audioCache.load(popSound);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!hasStarted || isSessionFinished) {
      return;
    }

    elapsedSeconds += dt;
    spawnTimer += dt;

    final remaining =
        BalloonLevelConfig.sessionDurationSeconds - elapsedSeconds;

    remainingSeconds.value = remaining.clamp(
      0,
      BalloonLevelConfig.sessionDurationSeconds,
    );

    if (spawnTimer >= config.spawnIntervalSeconds && hasLayout) {
      spawnTimer = 0;

      spawnBalloon();
    }

    if (elapsedSeconds >= BalloonLevelConfig.sessionDurationSeconds) {
      final result = finishSession(BalloonEndReason.timeCompleted);

      onSessionFinished(result);
    }
  }

  void startGame() {
    if (hasStarted) return;

    hasStarted = true;
    _startedAt = DateTime.now();

    GameMusicService.instance.playRandom(
      moods: {GameMusicMood.calm, GameMusicMood.playful},
      volume: 0.22,
    );

    // Fuerza el primer spawn en cuanto Flame tenga
    // disponible el tamaño real del juego.
    spawnTimer = config.spawnIntervalSeconds;
  }

  List<BalloonComponent> get activeBalloons {
    return children
        .whereType<BalloonComponent>()
        .where((balloon) => !balloon.wasPopped && !balloon.wasEscaped)
        .toList();
  }

  BalloonChannel _nextChannel() {
    if (_channelBag.isEmpty) {
      _channelBag.addAll([
        BalloonChannel.red,
        BalloonChannel.red,
        BalloonChannel.green,
        BalloonChannel.green,
      ]);

      _channelBag.shuffle(random);
    }

    return _channelBag.removeLast();
  }

  double _chooseSpawnX(double balloonSize) {
    final horizontalMargin = balloonSize * 0.60;

    final minCenterX = horizontalMargin;

    final maxCenterX = max(minCenterX, size.x - horizontalMargin);

    for (int attempt = 0; attempt < 10; attempt++) {
      final candidateX =
          minCenterX + random.nextDouble() * max(1.0, maxCenterX - minCenterX);

      final tooClose = activeBalloons.any((balloon) {
        // Solo revisamos los globos que todavía están
        // cerca de la zona de aparición.
        if (balloon.y < size.y * 0.55) {
          return false;
        }

        final balloonCenterX = balloon.x + balloon.size.x / 2;

        final minimumDistance = (balloon.size.x + balloonSize) * 0.48;

        return (balloonCenterX - candidateX).abs() < minimumDistance;
      });

      if (!tooClose) {
        return candidateX;
      }
    }

    // Si no encontramos un espacio ideal después
    // de varios intentos, usamos una posición válida.
    return minCenterX + random.nextDouble() * max(1.0, maxCenterX - minCenterX);
  }

  void spawnBalloon() {
    if (isSessionFinished || !hasLayout) {
      return;
    }

    if (activeBalloons.length >= config.maxActiveBalloons) {
      return;
    }

    final channel = _nextChannel();

    final shape =
        BalloonShape.values[random.nextInt(BalloonShape.values.length)];

    final balloonSize =
        config.minSize +
        random.nextDouble() * (config.maxSize - config.minSize);

    final speed =
        config.minSpeed +
        random.nextDouble() * (config.maxSpeed - config.minSpeed);

    final centerX = _chooseSpawnX(balloonSize);

    final balloon = BalloonComponent(
      id: nextBalloonId,
      channel: channel,
      shape: shape,
      speed: speed,
      spawnedAtSeconds: elapsedSeconds,
      color: colorForChannel(channel),
      horizontalAmplitude: 8 + random.nextDouble() * 18,
      horizontalAngularSpeed: 0.8 + random.nextDouble() * 0.8,
      horizontalPhase: random.nextDouble() * 2 * pi,
      position: Vector2(centerX - balloonSize / 2, size.y + balloonSize),
      size: Vector2(balloonSize, balloonSize * 1.18),
      onPop: registerPop,
      onEscape: registerEscape,
    );

    nextBalloonId++;

    add(balloon);
  }

  Color colorForChannel(BalloonChannel channel) {
    if (channel == BalloonChannel.red) {
      final value = (255 * redContrast.clamp(0.3, 1.0)).round();

      return Color.fromARGB(255, value, 0, 0);
    }

    final value = (255 * greenContrast.clamp(0.3, 1.0)).round();

    return Color.fromARGB(255, 0, value, 0);
  }

  void registerPop(BalloonComponent balloon) {
    if (isSessionFinished) return;

    FlameAudio.play(popSound, volume: 0.70);

    add(
      BalloonPopEffectComponent(
        position: Vector2(
          balloon.x + balloon.size.x / 2,
          balloon.y + balloon.size.y * 0.40,
        ),
        color: balloon.color,
      ),
    );

    final current = stats.value;

    if (balloon.channel == BalloonChannel.red) {
      stats.value = current.copyWith(redPopped: current.redPopped + 1);
    } else {
      stats.value = current.copyWith(greenPopped: current.greenPopped + 1);
    }

    final reactionTimeMs = ((elapsedSeconds - balloon.spawnedAtSeconds) * 1000)
        .round();

    _events.add(
      BalloonEvent(
        id: balloon.id,
        channel: balloon.channel,
        spawnedAtSeconds: balloon.spawnedAtSeconds,
        completedAtSeconds: elapsedSeconds,
        result: BalloonEventResult.popped,
        reactionTimeMs: reactionTimeMs,
      ),
    );
  }

  void registerEscape(BalloonComponent balloon) {
    if (isSessionFinished) return;

    add(
      BalloonEscapeFeedbackComponent(
        position: Vector2(size.x / 2, escapeBoundaryY + 28),
      ),
    );

    final current = stats.value;

    if (balloon.channel == BalloonChannel.red) {
      stats.value = current.copyWith(redEscaped: current.redEscaped + 1);
    } else {
      stats.value = current.copyWith(greenEscaped: current.greenEscaped + 1);
    }

    _events.add(
      BalloonEvent(
        id: balloon.id,
        channel: balloon.channel,
        spawnedAtSeconds: balloon.spawnedAtSeconds,
        completedAtSeconds: elapsedSeconds,
        result: BalloonEventResult.escaped,
        reactionTimeMs: null,
      ),
    );
  }

  BalloonSessionResult finishSession(BalloonEndReason reason) {
    final existing = _finalResult;

    if (existing != null) {
      return existing;
    }

    isSessionFinished = true;

    GameMusicService.instance.stop();

    for (final balloon in children.whereType<BalloonComponent>().toList()) {
      balloon.removeFromParent();
    }

    pauseEngine();

    final endedAt = DateTime.now();

    final startedAt =
        _startedAt ??
        endedAt.subtract(
          Duration(milliseconds: (elapsedSeconds * 1000).round()),
        );

    final result = BalloonSessionResult(
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: elapsedSeconds,
      endReason: reason,
      stats: stats.value,
      events: List.unmodifiable(List<BalloonEvent>.from(_events)),
    );

    _finalResult = result;

    return result;
  }

  @override
  void onRemove() {
    GameMusicService.instance.stop();

    stats.dispose();
    remainingSeconds.dispose();

    super.onRemove();
  }
}

class BalloonComponent extends PositionComponent
    with TapCallbacks, HasGameReference<BalloonPopGame> {
  BalloonComponent({
    required this.id,
    required this.channel,
    required this.shape,
    required this.speed,
    required this.spawnedAtSeconds,
    required this.color,
    required this.horizontalAmplitude,
    required this.horizontalAngularSpeed,
    required this.horizontalPhase,
    required this.onPop,
    required this.onEscape,
    required super.position,
    required super.size,
  });

  final int id;

  final BalloonChannel channel;
  final BalloonShape shape;

  final double speed;
  final double spawnedAtSeconds;

  final Color color;

  final double horizontalAmplitude;
  final double horizontalAngularSpeed;
  final double horizontalPhase;

  final void Function(BalloonComponent balloon) onPop;
  final void Function(BalloonComponent balloon) onEscape;

  bool wasPopped = false;
  bool wasEscaped = false;

  late final double _baseX;

  double _movementElapsed = 0;

  @override
  void onMount() {
    super.onMount();

    _baseX = x;
  }

  @override
  void update(double dt) {
    super.update(dt);

    y -= speed * game.speedMultiplier * dt;

    _movementElapsed += dt;

    final horizontalOffset =
        sin(horizontalPhase + _movementElapsed * horizontalAngularSpeed) *
        horizontalAmplitude;

    final maxX = max(0.0, game.size.x - size.x);

    x = (_baseX + horizontalOffset).clamp(0.0, maxX).toDouble();

    if (!wasPopped && !wasEscaped && y <= game.escapeBoundaryY) {
      wasEscaped = true;

      onEscape(this);

      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = color;

    final center = Offset(size.x / 2, size.y * 0.40);

    final shapeWidth = size.x * 0.76;
    final shapeHeight = size.y * 0.68;

    switch (shape) {
      case BalloonShape.circle:
        _drawCircle(canvas, paint, center, shapeWidth, shapeHeight);

      case BalloonShape.star:
        _drawStar(canvas, paint, center, shapeWidth * 0.52);

      case BalloonShape.diamond:
        _drawDiamond(canvas, paint, center, shapeWidth, shapeHeight);

      case BalloonShape.triangle:
        _drawTriangle(canvas, paint, center, shapeWidth, shapeHeight);

      case BalloonShape.heart:
        _drawHeart(canvas, paint, center, shapeWidth, shapeHeight);
    }

    _drawString(canvas, center, shapeHeight);
  }

  void _drawCircle(
    Canvas canvas,
    Paint paint,
    Offset center,
    double width,
    double height,
  ) {
    final rect = Rect.fromCenter(center: center, width: width, height: height);

    canvas.drawOval(rect, paint);
  }

  void _drawDiamond(
    Canvas canvas,
    Paint paint,
    Offset center,
    double width,
    double height,
  ) {
    final path = Path()
      ..moveTo(center.dx, center.dy - height / 2)
      ..lineTo(center.dx + width / 2, center.dy)
      ..lineTo(center.dx, center.dy + height / 2)
      ..lineTo(center.dx - width / 2, center.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawTriangle(
    Canvas canvas,
    Paint paint,
    Offset center,
    double width,
    double height,
  ) {
    final path = Path()
      ..moveTo(center.dx, center.dy - height / 2)
      ..lineTo(center.dx + width / 2, center.dy + height / 2)
      ..lineTo(center.dx - width / 2, center.dy + height / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();

    const points = 5;
    final innerRadius = radius * 0.45;

    for (int i = 0; i < points * 2; i++) {
      final currentRadius = i.isEven ? radius : innerRadius;

      final angle = -pi / 2 + i * pi / points;

      final point = Offset(
        center.dx + cos(angle) * currentRadius,
        center.dy + sin(angle) * currentRadius,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawHeart(
    Canvas canvas,
    Paint paint,
    Offset center,
    double width,
    double height,
  ) {
    final path = Path();

    final top = center.dy - height * 0.30;

    final bottom = center.dy + height * 0.48;

    path.moveTo(center.dx, bottom);

    path.cubicTo(
      center.dx - width * 0.60,
      center.dy + height * 0.10,
      center.dx - width * 0.52,
      top,
      center.dx - width * 0.22,
      top,
    );

    path.cubicTo(
      center.dx - width * 0.05,
      top,
      center.dx,
      center.dy - height * 0.08,
      center.dx,
      center.dy - height * 0.02,
    );

    path.cubicTo(
      center.dx,
      center.dy - height * 0.08,
      center.dx + width * 0.05,
      top,
      center.dx + width * 0.22,
      top,
    );

    path.cubicTo(
      center.dx + width * 0.52,
      top,
      center.dx + width * 0.60,
      center.dy + height * 0.10,
      center.dx,
      bottom,
    );

    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawString(Canvas canvas, Offset center, double shapeHeight) {
    final knotY = center.dy + shapeHeight / 2;

    final paint = Paint()..color = color;

    final knot = Path()
      ..moveTo(center.dx, knotY - 2)
      ..lineTo(center.dx - 6, knotY + 9)
      ..lineTo(center.dx + 6, knotY + 9)
      ..close();

    canvas.drawPath(knot, paint);

    final stringPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, knotY + 8),
      Offset(center.dx, size.y),
      stringPaint,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (wasPopped || wasEscaped || game.isSessionFinished) {
      return;
    }

    wasPopped = true;

    onPop(this);

    removeFromParent();
  }
}

class BalloonPopEffectComponent extends PositionComponent {
  BalloonPopEffectComponent({required super.position, required this.color})
    : super(anchor: Anchor.center, priority: 10);

  final Color color;

  static const double duration = 0.24;

  double elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);

    elapsed += dt;

    if (elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (elapsed / duration).clamp(0.0, 1.0);

    final opacity = 1.0 - progress;

    final distance = 8 + progress * 34;

    const particleCount = 8;

    for (int i = 0; i < particleCount; i++) {
      final angle = i * (2 * pi / particleCount);

      final particlePosition = Offset(
        cos(angle) * distance,
        sin(angle) * distance,
      );

      final particlePaint = Paint()..color = color.withValues(alpha: opacity);

      canvas.drawCircle(particlePosition, 5 - progress * 2.5, particlePaint);
    }

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * opacity
      ..color = color.withValues(alpha: opacity * 0.7);

    canvas.drawCircle(Offset.zero, 12 + progress * 25, ringPaint);
  }
}

class BalloonEscapeFeedbackComponent extends PositionComponent {
  BalloonEscapeFeedbackComponent({required super.position})
    : super(anchor: Anchor.center, priority: 10);

  static const double duration = 0.65;

  double elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);

    elapsed += dt;

    y -= 20 * dt;

    if (elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final opacity = (1 - elapsed / duration).clamp(0.0, 1.0);

    final painter = TextPainter(
      text: TextSpan(
        text: 'Ups',
        style: TextStyle(
          color: Colors.orange.withValues(alpha: opacity),
          fontSize: 23,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();

    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
  }
}
