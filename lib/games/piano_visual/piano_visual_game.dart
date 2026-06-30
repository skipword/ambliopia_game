import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

class PianoVisualGame extends FlameGame {
  PianoVisualGame({required this.redContrast, required this.greenContrast});

  final double redContrast;
  final double greenContrast;

  final Random random = Random();

  final ValueNotifier<PianoStats> stats = ValueNotifier(PianoStats.empty());

  double spawnTimer = 0;
  double elapsedSeconds = 0;
  int nextTileId = 1;

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

    elapsedSeconds += dt;
    spawnTimer += dt;

    if (spawnTimer >= 0.75) {
      spawnTimer = 0;
      spawnTile();
    }
  }

  void addLanes() {
    const columns = 4;
    final columnWidth = size.x / columns;

    // Fondos suaves por carril
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

    // Separadores verticales
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
    final channel = random.nextBool() ? VisualChannel.red : VisualChannel.green;

    const columns = 4;
    final columnWidth = size.x / columns;
    final column = random.nextInt(columns);

    final tileWidth = columnWidth * 0.82;
    const tileHeight = 120.0;

    final x = column * columnWidth + (columnWidth - tileWidth) / 2;

    final tile = PianoTileComponent(
      id: nextTileId,
      channel: channel,
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

    debugPrint(
      'HIT | id=${tile.id} | channel=${tile.channel.name} | reaction=${reactionTimeMs}ms',
    );
  }

  void registerMiss(PianoTileComponent tile) {
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

    debugPrint('MISS | id=${tile.id} | channel=${tile.channel.name}');
  }
}

class PianoTileComponent extends RectangleComponent
    with TapCallbacks, HasGameReference<PianoVisualGame> {
  PianoTileComponent({
    required this.id,
    required this.channel,
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

enum VisualChannel { red, green }

class PianoStats {
  const PianoStats({
    required this.hits,
    required this.misses,
    required this.redHits,
    required this.greenHits,
    required this.redMisses,
    required this.greenMisses,
  });

  factory PianoStats.empty() {
    return const PianoStats(
      hits: 0,
      misses: 0,
      redHits: 0,
      greenHits: 0,
      redMisses: 0,
      greenMisses: 0,
    );
  }

  final int hits;
  final int misses;
  final int redHits;
  final int greenHits;
  final int redMisses;
  final int greenMisses;

  PianoStats copyWith({
    int? hits,
    int? misses,
    int? redHits,
    int? greenHits,
    int? redMisses,
    int? greenMisses,
  }) {
    return PianoStats(
      hits: hits ?? this.hits,
      misses: misses ?? this.misses,
      redHits: redHits ?? this.redHits,
      greenHits: greenHits ?? this.greenHits,
      redMisses: redMisses ?? this.redMisses,
      greenMisses: greenMisses ?? this.greenMisses,
    );
  }
}
