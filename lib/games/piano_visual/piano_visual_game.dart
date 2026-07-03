import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

import '../../app/app_theme.dart';
import 'piano_level.dart';
import 'piano_session_result.dart';

class PianoVisualGame extends FlameGame {
  PianoVisualGame({
    required this.redContrast,
    required this.greenContrast,
    required this.difficulty,
    required this.onSessionFinished,
  });

  static const int maxMisses = 3;

  final double redContrast;
  final double greenContrast;
  final PianoDifficulty difficulty;
  final void Function(PianoSessionResult result) onSessionFinished;

  final DateTime startedAt = DateTime.now();
  final Random random = Random();

  final ValueNotifier<PianoStats> stats = ValueNotifier(PianoStats.empty());

  final List<PianoStimulusEvent> _events = [];

  PianoSessionResult? _finalResult;

  double spawnTimer = 0;
  double elapsedSeconds = 0;
  int nextTileId = 1;

  bool hasStarted = false;
  bool isSessionFinished = false;

  double get hitZoneTop => size.y * 0.70;
  double get hitZoneBottom => size.y * 0.88;

  @override
  Color backgroundColor() {
    return const Color(0xFF111827);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await FlameAudio.audioCache.loadAll(['piano_hit.wav', 'piano_miss.wav']);

    addLanes();
    addHitZone();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!hasStarted || isSessionFinished) return;

    elapsedSeconds += dt;
    spawnTimer += dt;

    if (spawnTimer >= 1.0) {
      spawnTimer = 0;
      spawnTile();
    }
  }

  void startGame() {
    if (hasStarted) return;

    hasStarted = true;

    spawnTile();
    spawnTile();
  }

  void addLanes() {
    const columns = 4;
    final columnWidth = size.x / columns;

    for (int i = 0; i < columns; i++) {
      final x = i * columnWidth;

      add(
        RectangleComponent(
          position: Vector2(x, 0),
          size: Vector2(columnWidth, size.y),
          paint: Paint()
            ..color = i.isEven
                ? Colors.white.withValues(alpha: 0.035)
                : Colors.white.withValues(alpha: 0.015),
          priority: -3,
        ),
      );
    }

    for (int i = 1; i < columns; i++) {
      final x = i * columnWidth;

      add(
        RectangleComponent(
          position: Vector2(x - 1, 0),
          size: Vector2(2, size.y),
          paint: Paint()..color = Colors.white.withValues(alpha: 0.18),
          priority: -2,
        ),
      );
    }
  }

  void addHitZone() {
    add(
      HitZoneComponent(
        top: hitZoneTop,
        bottom: hitZoneBottom,
        gameWidth: size.x,
      )..priority = -1,
    );
  }

  bool isTileInsideHitZone(PianoTileComponent tile) {
    final tileTop = tile.y;
    final tileBottom = tile.y + tile.size.y;

    return tileBottom >= hitZoneTop && tileTop <= hitZoneBottom;
  }

  void showFeedback({
    required String text,
    required Vector2 position,
    required Color color,
  }) {
    add(
      FloatingFeedbackComponent(text: text, color: color, position: position)
        ..priority = 5,
    );
  }

  void spawnTile() {
    if (isSessionFinished) return;

    final levelConfig = difficulty.config;

    final channel = random.nextBool() ? VisualChannel.red : VisualChannel.green;

    final kind = random.nextDouble() < levelConfig.holdTileProbability
        ? PianoTileKind.hold
        : PianoTileKind.tap;

    const columns = 4;
    final columnWidth = size.x / columns;
    final laneIndex = random.nextInt(columns);

    final requiredHoldSeconds = kind == PianoTileKind.hold
        ? levelConfig.randomHoldSeconds(random)
        : 0.0;

    final tileWidth = columnWidth * levelConfig.tileWidthFactor;

    final tileHeight = kind == PianoTileKind.hold
        ? 190.0 + requiredHoldSeconds * 80
        : 120.0;

    final x = laneIndex * columnWidth + (columnWidth - tileWidth) / 2;

    final tile = PianoTileComponent(
      id: nextTileId,
      channel: channel,
      kind: kind,
      laneIndex: laneIndex,
      speed: 120 + random.nextDouble() * 45,
      createdAtSeconds: elapsedSeconds,
      requiredHoldSeconds: requiredHoldSeconds,
      color: _colorForChannel(channel),
      position: Vector2(x, -tileHeight),
      size: Vector2(tileWidth, tileHeight),
      onHit: registerHit,
      onMiss: registerMiss,
    )..priority = 1;

    nextTileId++;
    add(tile);
  }

  Color _colorForChannel(VisualChannel channel) {
    final levelMultiplier = difficulty.config.contrastMultiplier;

    if (channel == VisualChannel.red) {
      final alpha = (redContrast * levelMultiplier).clamp(0.25, 1.0);
      return AppColors.red.withValues(alpha: alpha);
    }

    final alpha = (greenContrast * levelMultiplier).clamp(0.25, 1.0);
    return AppColors.green.withValues(alpha: alpha);
  }

  void registerHit(PianoTileComponent tile) {
    if (isSessionFinished) return;

    FlameAudio.play('piano_hit.wav', volume: 0.55);

    final current = stats.value;

    stats.value = current.copyWith(
      hits: current.hits + 1,
      redHits: tile.channel == VisualChannel.red
          ? current.redHits + 1
          : current.redHits,
      greenHits: tile.channel == VisualChannel.green
          ? current.greenHits + 1
          : current.greenHits,
    );

    final reactionBase = tile.firstPressedAtSeconds ?? elapsedSeconds;

    final reactionTimeMs = ((reactionBase - tile.createdAtSeconds) * 1000)
        .round();

    _events.add(
      PianoStimulusEvent(
        id: tile.id,
        channel: tile.channel,
        tileKind: tile.kind,
        laneIndex: tile.laneIndex,
        createdAtSeconds: tile.createdAtSeconds,
        completedAtSeconds: elapsedSeconds,
        result: StimulusResult.hit,
        reactionTimeMs: reactionTimeMs,
        requiredHoldMs: tile.kind == PianoTileKind.hold
            ? (tile.requiredHoldSeconds * 1000).round()
            : null,
        actualHoldMs: tile.kind == PianoTileKind.hold
            ? (tile.holdElapsedSeconds * 1000).round()
            : null,
      ),
    );

    showFeedback(
      text: '¡Bien!',
      position: Vector2(tile.x + tile.size.x / 2, tile.y + tile.size.y / 2),
      color: Colors.white,
    );

    debugPrint(
      'HIT | id=${tile.id} | channel=${tile.channel.name} | kind=${tile.kind.name} | lane=${tile.laneIndex} | reaction=${reactionTimeMs}ms',
    );
  }

  void registerMiss(PianoTileComponent tile) {
    if (isSessionFinished) return;

    FlameAudio.play('piano_miss.wav', volume: 0.45);

    final current = stats.value;

    final updated = current.copyWith(
      misses: current.misses + 1,
      redMisses: tile.channel == VisualChannel.red
          ? current.redMisses + 1
          : current.redMisses,
      greenMisses: tile.channel == VisualChannel.green
          ? current.greenMisses + 1
          : current.greenMisses,
    );

    stats.value = updated;

    _events.add(
      PianoStimulusEvent(
        id: tile.id,
        channel: tile.channel,
        tileKind: tile.kind,
        laneIndex: tile.laneIndex,
        createdAtSeconds: tile.createdAtSeconds,
        completedAtSeconds: elapsedSeconds,
        result: StimulusResult.miss,
        reactionTimeMs: null,
        requiredHoldMs: tile.kind == PianoTileKind.hold
            ? (tile.requiredHoldSeconds * 1000).round()
            : null,
        actualHoldMs: tile.kind == PianoTileKind.hold
            ? (tile.holdElapsedSeconds * 1000).round()
            : null,
      ),
    );

    showFeedback(
      text: 'Ups',
      position: Vector2(tile.x + tile.size.x / 2, tile.y + tile.size.y / 2),
      color: AppColors.yellow,
    );

    debugPrint(
      'MISS | id=${tile.id} | channel=${tile.channel.name} | kind=${tile.kind.name} | lane=${tile.laneIndex}',
    );

    if (updated.misses >= maxMisses) {
      final result = finishSession(PianoEndReason.maxMisses);
      onSessionFinished(result);
    }
  }

  PianoSessionResult finishSession(PianoEndReason endReason) {
    if (_finalResult != null) return _finalResult!;

    isSessionFinished = true;

    for (final tile in children.whereType<PianoTileComponent>().toList()) {
      tile.removeFromParent();
    }

    pauseEngine();

    _finalResult = PianoSessionResult(
      startedAt: startedAt,
      endedAt: DateTime.now(),
      durationSeconds: elapsedSeconds,
      endReason: endReason,
      stats: stats.value,
      events: List.unmodifiable(_events),
    );

    return _finalResult!;
  }
}

class PianoTileComponent extends PositionComponent
    with TapCallbacks, HasGameReference<PianoVisualGame> {
  PianoTileComponent({
    required this.id,
    required this.channel,
    required this.kind,
    required this.laneIndex,
    required this.speed,
    required this.createdAtSeconds,
    required this.requiredHoldSeconds,
    required Color color,
    required this.onHit,
    required this.onMiss,
    required super.position,
    required super.size,
  }) : baseColor = color;

  final int id;
  final VisualChannel channel;
  final PianoTileKind kind;
  final int laneIndex;
  final double speed;
  final double createdAtSeconds;
  final double requiredHoldSeconds;
  final Color baseColor;
  final void Function(PianoTileComponent tile) onHit;
  final void Function(PianoTileComponent tile) onMiss;

  bool wasTouched = false;
  bool wasMissed = false;
  bool isHolding = false;

  double holdElapsedSeconds = 0;
  double? firstPressedAtSeconds;

  double get holdProgress {
    if (kind != PianoTileKind.hold || requiredHoldSeconds <= 0) return 0;
    return (holdElapsedSeconds / requiredHoldSeconds).clamp(0.0, 1.0);
  }

  @override
  void update(double dt) {
    super.update(dt);

    y += speed * dt;

    if (kind == PianoTileKind.hold && isHolding && !wasTouched && !wasMissed) {
      holdElapsedSeconds += dt;

      if (holdElapsedSeconds >= requiredHoldSeconds) {
        wasTouched = true;
        onHit(this);
        removeFromParent();
        return;
      }
    }

    if (!wasTouched && !wasMissed && y > game.size.y) {
      wasMissed = true;
      onMiss(this);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final radius = Radius.circular(kind == PianoTileKind.hold ? 26 : 20);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    final glowPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawRRect(rrect.inflate(5), glowPaint);

    final tilePaint = Paint()
      ..color = isHolding
          ? Color.lerp(baseColor, Colors.white, holdProgress * 0.30)!
          : baseColor;

    canvas.drawRRect(rrect, tilePaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: 0.55);

    canvas.drawRRect(rrect, borderPaint);

    if (kind == PianoTileKind.hold) {
      _renderHoldProgress(canvas);
    }
  }

  void _renderHoldProgress(Canvas canvas) {
    final progress = holdProgress;

    final trackX = size.x * 0.18;
    const topPadding = 28.0;
    final bottomPadding = size.y * 0.20;
    final trackTop = topPadding;
    final trackBottom = size.y - bottomPadding;
    final trackHeight = trackBottom - trackTop;

    final trackPaint = Paint()
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.35);

    canvas.drawLine(
      Offset(trackX, trackTop),
      Offset(trackX, trackBottom),
      trackPaint,
    );

    final progressPaint = Paint()
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.95);

    canvas.drawLine(
      Offset(trackX, trackBottom),
      Offset(trackX, trackBottom - trackHeight * progress),
      progressPaint,
    );

    final circleCenter = Offset(size.x * 0.50, size.y - 42);
    const circleRadius = 20.0;

    final circleBackground = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = Colors.white.withValues(alpha: 0.35);

    canvas.drawCircle(circleCenter, circleRadius, circleBackground);

    final circleProgress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    canvas.drawArc(
      Rect.fromCircle(center: circleCenter, radius: circleRadius),
      -pi / 2,
      2 * pi * progress,
      false,
      circleProgress,
    );

    final holdText = TextPainter(
      text: const TextSpan(
        text: 'MANTÉN',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    holdText.layout(maxWidth: size.x);

    holdText.paint(
      canvas,
      Offset((size.x - holdText.width) / 2, size.y * 0.35),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (wasTouched || wasMissed) return;

    if (!game.isTileInsideHitZone(this)) {
      game.showFeedback(
        text: 'Espera',
        position: Vector2(x + size.x / 2, y + size.y / 2),
        color: Colors.white70,
      );

      return;
    }

    if (kind == PianoTileKind.tap) {
      wasTouched = true;
      firstPressedAtSeconds = game.elapsedSeconds;
      onHit(this);
      removeFromParent();
      return;
    }

    isHolding = true;
    firstPressedAtSeconds ??= game.elapsedSeconds;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (kind != PianoTileKind.hold) return;
    if (wasTouched || wasMissed) return;

    if (!isHolding) return;

    if (holdElapsedSeconds < requiredHoldSeconds) {
      wasMissed = true;

      game.showFeedback(
        text: 'Suelta muy pronto',
        position: Vector2(x + size.x / 2, y + size.y / 2),
        color: AppColors.yellow,
      );

      onMiss(this);
      removeFromParent();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    if (kind != PianoTileKind.hold) return;
    if (wasTouched || wasMissed) return;

    if (!isHolding) return;

    wasMissed = true;
    onMiss(this);
    removeFromParent();
  }
}

class HitZoneComponent extends PositionComponent {
  HitZoneComponent({
    required this.top,
    required this.bottom,
    required double gameWidth,
  }) : super(position: Vector2(0, top), size: Vector2(gameWidth, bottom - top));

  final double top;
  final double bottom;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    final zonePaint = Paint()..color = Colors.white.withValues(alpha: 0.06);

    canvas.drawRect(rect, zonePaint);

    final linePaint = Paint()
      ..strokeWidth = 4
      ..color = AppColors.yellow.withValues(alpha: 0.75);

    canvas.drawLine(Offset(0, size.y), Offset(size.x, size.y), linePaint);

    final text = TextPainter(
      text: const TextSpan(
        text: 'TOCA AQUÍ',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    text.layout();

    text.paint(canvas, Offset((size.x - text.width) / 2, size.y - 32));
  }
}

class FloatingFeedbackComponent extends PositionComponent {
  FloatingFeedbackComponent({
    required this.text,
    required this.color,
    required super.position,
  });

  final String text;
  final Color color;

  double life = 0;
  final double maxLife = 0.7;

  @override
  void update(double dt) {
    super.update(dt);

    life += dt;
    y -= 45 * dt;

    if (life >= maxLife) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final opacity = (1 - life / maxLife).clamp(0.0, 1.0);

    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withValues(alpha: opacity),
          fontSize: 22,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: opacity * 0.5),
              blurRadius: 6,
            ),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    painter.layout();

    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
  }
}
