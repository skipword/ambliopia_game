import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'piano_session_result.dart';

class PianoVisualGame extends FlameGame {
  PianoVisualGame({required this.redContrast, required this.greenContrast});

  final double redContrast;
  final double greenContrast;

  final DateTime startedAt = DateTime.now();
  final Random random = Random();

  final ValueNotifier<PianoStats> stats = ValueNotifier(PianoStats.empty());

  final List<PianoStimulusEvent> _events = [];

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

    final channel = random.nextBool() ? VisualChannel.red : VisualChannel.green;

    const columns = 4;
    final columnWidth = size.x / columns;
    final laneIndex = random.nextInt(columns);

    final tileWidth = columnWidth * 0.82;
    const tileHeight = 120.0;

    final x = laneIndex * columnWidth + (columnWidth - tileWidth) / 2;

    final tile = PianoTileComponent(
      id: nextTileId,
      channel: channel,
      laneIndex: laneIndex,
      speed: 120 + random.nextDouble() * 45,
      createdAtSeconds: elapsedSeconds,
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
    if (channel == VisualChannel.red) {
      return AppColors.red.withValues(alpha: redContrast);
    }

    return AppColors.green.withValues(alpha: greenContrast);
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
        laneIndex: tile.laneIndex,
        createdAtSeconds: tile.createdAtSeconds,
        completedAtSeconds: elapsedSeconds,
        result: StimulusResult.hit,
        reactionTimeMs: reactionTimeMs,
      ),
    );

    debugPrint(
      'HIT | id=${tile.id} | channel=${tile.channel.name} | lane=${tile.laneIndex} | reaction=${reactionTimeMs}ms',
    );
  }

  void registerMiss(PianoTileComponent tile) {
    if (isSessionFinished) return;

    final current = stats.value;

    stats.value = current.copyWith(
      misses: current.misses + 1,
      redMisses: tile.channel == VisualChannel.red
          ? current.redMisses + 1
          : current.redMisses,
      greenMisses: tile.channel == VisualChannel.green
          ? current.greenMisses + 1
          : current.greenMisses,
    );

    _events.add(
      PianoStimulusEvent(
        id: tile.id,
        channel: tile.channel,
        laneIndex: tile.laneIndex,
        createdAtSeconds: tile.createdAtSeconds,
        completedAtSeconds: elapsedSeconds,
        result: StimulusResult.miss,
        reactionTimeMs: null,
      ),
    );

    debugPrint(
      'MISS | id=${tile.id} | channel=${tile.channel.name} | lane=${tile.laneIndex}',
    );
  }

  PianoSessionResult finishSession() {
    isSessionFinished = true;

    for (final tile in children.whereType<PianoTileComponent>().toList()) {
      tile.removeFromParent();
    }

    pauseEngine();

    return PianoSessionResult(
      startedAt: startedAt,
      endedAt: DateTime.now(),
      durationSeconds: elapsedSeconds,
      stats: stats.value,
      events: List.unmodifiable(_events),
    );
  }
}

class PianoTileComponent extends RectangleComponent
    with TapCallbacks, HasGameReference<PianoVisualGame> {
  PianoTileComponent({
    required this.id,
    required this.channel,
    required this.laneIndex,
    required this.speed,
    required this.createdAtSeconds,
    required Color color,
    required this.onHit,
    required this.onMiss,
    required super.position,
    required super.size,
  }) : super(paint: Paint()..color = color);

  final int id;
  final VisualChannel channel;
  final int laneIndex;
  final double speed;
  final double createdAtSeconds;
  final void Function(PianoTileComponent tile) onHit;
  final void Function(PianoTileComponent tile) onMiss;

  bool wasTouched = false;
  bool wasMissed = false;

  @override
  void update(double dt) {
    super.update(dt);

    y += speed * dt;

    if (!wasTouched && !wasMissed && y > game.size.y) {
      wasMissed = true;
      onMiss(this);
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (wasTouched || wasMissed) return;

    wasTouched = true;
    onHit(this);
    removeFromParent();
  }
}
