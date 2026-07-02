import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

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
  bool isSessionFinished = false;

  @override
  Color backgroundColor() {
    return const Color(0xFF111827);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    addLanes();

    spawnTile();
    spawnTile();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isSessionFinished) return;

    elapsedSeconds += dt;
    spawnTimer += dt;

    if (spawnTimer >= 1.0) {
      spawnTimer = 0;
      spawnTile();
    }
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
          priority: -2,
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
          priority: -1,
        ),
      );
    }
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

    final tileWidth = columnWidth * levelConfig.tileWidthFactor;
    final tileHeight = kind == PianoTileKind.hold ? 230.0 : 120.0;

    final x = laneIndex * columnWidth + (columnWidth - tileWidth) / 2;

    final tile = PianoTileComponent(
      id: nextTileId,
      channel: channel,
      kind: kind,
      laneIndex: laneIndex,
      speed: 120 + random.nextDouble() * 45,
      createdAtSeconds: elapsedSeconds,
      requiredHoldSeconds: levelConfig.requiredHoldSeconds,
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

    final reactionTimeMs = ((elapsedSeconds - tile.createdAtSeconds) * 1000)
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

    debugPrint(
      'HIT | id=${tile.id} | channel=${tile.channel.name} | kind=${tile.kind.name} | lane=${tile.laneIndex} | reaction=${reactionTimeMs}ms',
    );
  }

  void registerMiss(PianoTileComponent tile) {
    if (isSessionFinished) return;

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

class PianoTileComponent extends RectangleComponent
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
  }) : baseColor = color,
       super(paint: Paint()..color = color);

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

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (kind == PianoTileKind.hold) {
      add(
        TextComponent(
          text: 'MANTÉN',
          anchor: Anchor.center,
          position: size / 2,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    y += speed * dt;

    if (kind == PianoTileKind.hold && isHolding && !wasTouched && !wasMissed) {
      holdElapsedSeconds += dt;

      final progress = (holdElapsedSeconds / requiredHoldSeconds).clamp(
        0.0,
        1.0,
      );

      paint.color = Color.lerp(baseColor, Colors.white, progress * 0.25)!;

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
  void onTapDown(TapDownEvent event) {
    if (wasTouched || wasMissed) return;

    if (kind == PianoTileKind.tap) {
      wasTouched = true;
      onHit(this);
      removeFromParent();
      return;
    }

    isHolding = true;
    paint.color = Colors.white.withValues(alpha: 0.85);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (kind != PianoTileKind.hold) return;
    if (wasTouched || wasMissed) return;

    if (holdElapsedSeconds < requiredHoldSeconds) {
      wasMissed = true;
      onMiss(this);
      removeFromParent();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    if (kind != PianoTileKind.hold) return;
    if (wasTouched || wasMissed) return;

    wasMissed = true;
    onMiss(this);
    removeFromParent();
  }
}
