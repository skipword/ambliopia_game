import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../../core/services/game_music_service.dart';
import 'road_visual_level.dart';
import 'road_visual_session_result.dart';

class RoadVisualGame extends FlameGame {
  RoadVisualGame({
    required this.redContrast,
    required this.greenContrast,
    required this.difficulty,
    required this.onSessionFinished,
  }) : config = difficulty.config,
       currentLane = difficulty.config.laneCount ~/ 2 {
    _lastSpawnTimeByLane = List<double>.filled(config.laneCount, -100);
  }

  static const String collectSound = 'farm_objective.wav';

  static const String collisionSound = 'farm_collision_crush.mp3';

  final double redContrast;
  final double greenContrast;

  final RoadVisualDifficulty difficulty;
  final RoadVisualLevelConfig config;

  final void Function(RoadVisualSessionResult result) onSessionFinished;

  final Random random = Random();

  final ValueNotifier<RoadVisualStats> stats = ValueNotifier(
    RoadVisualStats.empty(),
  );

  final ValueNotifier<double> remainingSeconds = ValueNotifier(
    RoadVisualLevelConfig.sessionDurationSeconds,
  );

  final ValueNotifier<int> livesLeft = ValueNotifier(
    RoadVisualLevelConfig.maxLives,
  );

  final List<RoadVisualEvent> _events = [];
  late final List<double> _lastSpawnTimeByLane;

  PlayerCarComponent? player;

  DateTime? _startedAt;

  RoadVisualSessionResult? _finalResult;

  RoadVisualSessionResult? get finalResult => _finalResult;

  bool hasStarted = false;
  bool isSessionFinished = false;

  double elapsedSeconds = 0;

  double obstacleSpawnTimer = 0;
  double objectiveSpawnTimer = 0;

  double collisionCooldown = 0;

  int currentLane;

  int nextEntityId = 1;

  double get speedMultiplier {
    if (elapsedSeconds < 20) {
      return 1.00;
    }

    if (elapsedSeconds < 40) {
      return 1.10;
    }

    return 1.20;
  }

  double get roadWidth {
    return min(size.x * 0.92, 520.0).toDouble();
  }

  double get roadLeft {
    return (size.x - roadWidth) / 2;
  }

  double get laneWidth {
    return roadWidth / config.laneCount;
  }

  double laneCenterX(int lane) {
    return roadLeft + laneWidth * lane + laneWidth / 2;
  }

  double get playerWidth {
    return min(laneWidth * 0.56, 58.0).toDouble();
  }

  double get playerHeight {
    return playerWidth * 1.55;
  }

  double get playerY {
    return max(30.0, size.y - playerHeight - 105);
  }

  Color get redStimulusColor {
    final value = (255 * redContrast.clamp(0.3, 1.0)).round();

    return Color.fromARGB(255, value, 0, 0);
  }

  Color get greenStimulusColor {
    final value = (255 * greenContrast.clamp(0.3, 1.0)).round();

    return Color.fromARGB(255, 0, value, 0);
  }

  @override
  Color backgroundColor() {
    return const Color(0xFFE7E9ED);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await FlameAudio.audioCache.load(collectSound);

    await FlameAudio.audioCache.load(collisionSound);

    add(RoadBackgroundComponent());

    _createPlayer();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    final currentPlayer = player;

    if (currentPlayer != null) {
      currentPlayer.size.setValues(playerWidth, playerHeight);

      currentPlayer.position.setValues(
        laneCenterX(currentLane) - playerWidth / 2,
        playerY,
      );
    }
  }

  void _createPlayer() {
    final newPlayer = PlayerCarComponent(
      position: Vector2(laneCenterX(currentLane) - playerWidth / 2, playerY),
      size: Vector2(playerWidth, playerHeight),
      color: redStimulusColor,
    );

    player = newPlayer;

    add(newPlayer);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!hasStarted || isSessionFinished) {
      return;
    }

    elapsedSeconds += dt;

    obstacleSpawnTimer += dt;
    objectiveSpawnTimer += dt;

    if (collisionCooldown > 0) {
      collisionCooldown -= dt;
    }

    final remaining =
        RoadVisualLevelConfig.sessionDurationSeconds - elapsedSeconds;

    remainingSeconds.value = remaining.clamp(
      0,
      RoadVisualLevelConfig.sessionDurationSeconds,
    );

    if (obstacleSpawnTimer >= config.obstacleSpawnInterval) {
      obstacleSpawnTimer = 0;

      spawnObstacle();
    }

    if (objectiveSpawnTimer >= config.objectiveSpawnInterval) {
      objectiveSpawnTimer = 0;

      spawnObjective();
    }

    _checkInteractions();

    if (elapsedSeconds >= RoadVisualLevelConfig.sessionDurationSeconds) {
      _finishAndNotify(RoadVisualEndReason.timeCompleted);
    }
  }

  void startGame() {
    if (hasStarted) {
      return;
    }

    hasStarted = true;

    _startedAt = DateTime.now();

    GameMusicService.instance.playRandom(
      moods: {GameMusicMood.playful, GameMusicMood.energetic},
      volume: 0.24,
    );

    spawnObstacle();
    spawnObjective();
  }

  void moveLeft() {
    if (!hasStarted || isSessionFinished) {
      return;
    }

    if (currentLane <= 0) {
      return;
    }

    currentLane--;

    final current = stats.value;

    stats.value = current.copyWith(laneChanges: current.laneChanges + 1);
  }

  void moveRight() {
    if (!hasStarted || isSessionFinished) {
      return;
    }

    if (currentLane >= config.laneCount - 1) {
      return;
    }

    currentLane++;

    final current = stats.value;

    stats.value = current.copyWith(laneChanges: current.laneChanges + 1);
  }

  List<TrafficCarComponent> get activeTraffic {
    return children
        .whereType<TrafficCarComponent>()
        .where((component) => !component.resolved)
        .toList();
  }

  List<RoadObjectiveComponent> get activeObjectives {
    return children
        .whereType<RoadObjectiveComponent>()
        .where((component) => !component.resolved)
        .toList();
  }

  bool _laneHasRecentEntity(int lane) {
    // Evita que dos elementos nazcan demasiado
    // cerca aunque Flame todavía no haya agregado
    // el componente anterior a children.
    const minimumSpawnGapSeconds = 1.10;

    final timeSinceLastSpawn = elapsedSeconds - _lastSpawnTimeByLane[lane];

    if (timeSinceLastSpawn < minimumSpawnGapSeconds) {
      return true;
    }

    const safeSpawnZone = 220.0;

    for (final obstacle in activeTraffic) {
      if (obstacle.laneIndex == lane && obstacle.y < safeSpawnZone) {
        return true;
      }
    }

    for (final objective in activeObjectives) {
      if (objective.laneIndex == lane && objective.y < safeSpawnZone) {
        return true;
      }
    }

    return false;
  }

  int? _chooseSafeLane({required bool obstacle}) {
    final lanes = List<int>.generate(config.laneCount, (index) => index);

    lanes.shuffle(random);

    if (obstacle) {
      final topObstacleLanes = activeTraffic
          .where((car) => car.y < 260)
          .map((car) => car.laneIndex)
          .toSet();

      // Nunca bloqueamos todos los
      // carriles simultáneamente.
      if (topObstacleLanes.length >= config.laneCount - 1) {
        return null;
      }
    }

    for (final lane in lanes) {
      if (!_laneHasRecentEntity(lane)) {
        return lane;
      }
    }

    return null;
  }

  void spawnObstacle() {
    if (isSessionFinished) {
      return;
    }

    if (activeTraffic.length >= config.maxActiveObstacles) {
      return;
    }

    final lane = _chooseSafeLane(obstacle: true);

    if (lane == null) {
      return;
    }

    final width = min(laneWidth * 0.53, 55.0).toDouble();

    final height = width * 1.55;

    final car = TrafficCarComponent(
      id: nextEntityId++,
      laneIndex: lane,
      spawnedAtSeconds: elapsedSeconds,
      color: greenStimulusColor,
      vehicleVariant: random.nextInt(3),
      position: Vector2(laneCenterX(lane) - width / 2, -height - 8),
      size: Vector2(width, height),
    );

    _lastSpawnTimeByLane[lane] = elapsedSeconds;

    add(car);
  }

  void spawnObjective() {
    if (isSessionFinished) {
      return;
    }

    if (activeObjectives.length >= config.maxActiveObjectives) {
      return;
    }

    final lane = _chooseSafeLane(obstacle: false);

    if (lane == null) {
      return;
    }

    final sizeValue = min(laneWidth * 0.34, 34.0).clamp(20.0, 34.0).toDouble();

    final objective = RoadObjectiveComponent(
      id: nextEntityId++,
      laneIndex: lane,
      spawnedAtSeconds: elapsedSeconds,
      color: redStimulusColor,
      position: Vector2(laneCenterX(lane) - sizeValue / 2, -sizeValue - 20),
      size: Vector2.all(sizeValue),
    );

    _lastSpawnTimeByLane[lane] = elapsedSeconds;

    add(objective);
  }

  void _checkInteractions() {
    final currentPlayer = player;

    if (currentPlayer == null) {
      return;
    }

    final playerRect = _rectFor(currentPlayer);

    for (final obstacle in activeTraffic.toList()) {
      if (!_rectFor(obstacle).overlaps(playerRect)) {
        continue;
      }

      if (collisionCooldown > 0) {
        continue;
      }

      registerCollision(obstacle);

      break;
    }

    if (isSessionFinished) {
      return;
    }

    for (final objective in activeObjectives.toList()) {
      if (_rectFor(objective).overlaps(playerRect)) {
        registerObjectiveCollected(objective);
      }
    }
  }

  Rect _rectFor(PositionComponent component) {
    return Rect.fromLTWH(
      component.x,
      component.y,
      component.size.x,
      component.size.y,
    );
  }

  void registerObjectiveCollected(RoadObjectiveComponent objective) {
    if (isSessionFinished || objective.resolved) {
      return;
    }

    objective.resolved = true;

    FlameAudio.play(collectSound, volume: 0.72);

    final current = stats.value;

    stats.value = current.copyWith(
      objectivesCollected: current.objectivesCollected + 1,
    );

    _events.add(
      RoadVisualEvent(
        id: objective.id,
        type: RoadVisualEventType.objectiveCollected,
        laneIndex: objective.laneIndex,
        spawnedAtSeconds: objective.spawnedAtSeconds,
        resolvedAtSeconds: elapsedSeconds,
      ),
    );

    add(
      RoadCollectEffectComponent(
        position: Vector2(
          objective.x + objective.size.x / 2,
          objective.y + objective.size.y / 2,
        ),
        color: redStimulusColor,
      ),
    );

    objective.removeFromParent();
  }

  void registerObjectiveMissed(RoadObjectiveComponent objective) {
    if (isSessionFinished || objective.resolved) {
      return;
    }

    objective.resolved = true;

    final current = stats.value;

    stats.value = current.copyWith(
      objectivesMissed: current.objectivesMissed + 1,
    );

    _events.add(
      RoadVisualEvent(
        id: objective.id,
        type: RoadVisualEventType.objectiveMissed,
        laneIndex: objective.laneIndex,
        spawnedAtSeconds: objective.spawnedAtSeconds,
        resolvedAtSeconds: elapsedSeconds,
      ),
    );

    objective.removeFromParent();
  }

  void registerObstacleAvoided(TrafficCarComponent obstacle) {
    if (isSessionFinished || obstacle.resolved) {
      return;
    }

    obstacle.resolved = true;

    final current = stats.value;

    stats.value = current.copyWith(
      obstaclesAvoided: current.obstaclesAvoided + 1,
    );

    _events.add(
      RoadVisualEvent(
        id: obstacle.id,
        type: RoadVisualEventType.obstacleAvoided,
        laneIndex: obstacle.laneIndex,
        spawnedAtSeconds: obstacle.spawnedAtSeconds,
        resolvedAtSeconds: elapsedSeconds,
      ),
    );

    obstacle.removeFromParent();
  }

  void registerCollision(TrafficCarComponent obstacle) {
    if (isSessionFinished || obstacle.resolved || collisionCooldown > 0) {
      return;
    }

    obstacle.resolved = true;

    collisionCooldown = 0.75;

    FlameAudio.play(collisionSound, volume: 1.0);

    final current = stats.value;

    stats.value = current.copyWith(collisions: current.collisions + 1);

    _events.add(
      RoadVisualEvent(
        id: obstacle.id,
        type: RoadVisualEventType.collision,
        laneIndex: obstacle.laneIndex,
        spawnedAtSeconds: obstacle.spawnedAtSeconds,
        resolvedAtSeconds: elapsedSeconds,
      ),
    );

    obstacle.removeFromParent();

    player?.flash();

    livesLeft.value = max(0, livesLeft.value - 1);

    if (livesLeft.value <= 0) {
      _finishAndNotify(RoadVisualEndReason.livesLost);
    }
  }

  void _finishAndNotify(RoadVisualEndReason reason) {
    if (isSessionFinished) {
      return;
    }

    final result = finishSession(reason);

    onSessionFinished(result);
  }

  RoadVisualSessionResult finishSession(RoadVisualEndReason reason) {
    final existing = _finalResult;

    if (existing != null) {
      return existing;
    }

    isSessionFinished = true;

    GameMusicService.instance.stop();

    for (final obstacle in children.whereType<TrafficCarComponent>().toList()) {
      obstacle.removeFromParent();
    }

    for (final objective
        in children.whereType<RoadObjectiveComponent>().toList()) {
      objective.removeFromParent();
    }

    final endedAt = DateTime.now();

    final startedAt =
        _startedAt ??
        endedAt.subtract(
          Duration(milliseconds: (elapsedSeconds * 1000).round()),
        );

    final result = RoadVisualSessionResult(
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: elapsedSeconds,
      difficulty: difficulty,
      endReason: reason,
      stats: stats.value,
      events: List.unmodifiable(List<RoadVisualEvent>.from(_events)),
    );

    _finalResult = result;

    pauseEngine();

    return result;
  }

  @override
  void onRemove() {
    GameMusicService.instance.stop();

    stats.dispose();
    remainingSeconds.dispose();
    livesLeft.dispose();

    super.onRemove();
  }
}

class RoadBackgroundComponent extends PositionComponent
    with HasGameReference<RoadVisualGame> {
  double scrollOffset = 0;

  RoadBackgroundComponent() : super(position: Vector2.zero(), priority: -100);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    this.size = size;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!game.hasStarted || game.isSessionFinished) {
      return;
    }

    scrollOffset += game.config.baseSpeed * game.speedMultiplier * dt;

    const cycle = 66.0;

    if (scrollOffset >= cycle) {
      scrollOffset %= cycle;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final backgroundPaint = Paint()..color = const Color(0xFFE7E9ED);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), backgroundPaint);

    final roadRect = Rect.fromLTWH(game.roadLeft, 0, game.roadWidth, size.y);

    canvas.drawRect(roadRect, Paint()..color = const Color(0xFF34383E));

    const shoulderWidth = 7.0;

    final shoulderPaint = Paint()..color = const Color(0xFF9CA3AF);

    canvas.drawRect(
      Rect.fromLTWH(game.roadLeft, 0, shoulderWidth, size.y),
      shoulderPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        game.roadLeft + game.roadWidth - shoulderWidth,
        0,
        shoulderWidth,
        size.y,
      ),
      shoulderPaint,
    );

    final linePaint = Paint()
      ..color = const Color(0xFFB7BCC5)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const dashHeight = 34.0;
    const dashGap = 32.0;
    const cycle = dashHeight + dashGap;

    for (int lane = 1; lane < game.config.laneCount; lane++) {
      final x = game.roadLeft + game.laneWidth * lane;

      var y = -cycle + scrollOffset;

      while (y < size.y) {
        canvas.drawLine(Offset(x, y), Offset(x, y + dashHeight), linePaint);

        y += cycle;
      }
    }
  }
}

class PlayerCarComponent extends PositionComponent
    with HasGameReference<RoadVisualGame> {
  PlayerCarComponent({
    required Vector2 position,
    required Vector2 size,
    required this.color,
  }) : super(position: position, size: size, priority: 10);

  final Color color;

  double flashSeconds = 0;

  void flash() {
    flashSeconds = 0.32;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (flashSeconds > 0) {
      flashSeconds -= dt;
    }

    final targetX = game.laneCenterX(game.currentLane) - size.x / 2;

    final interpolation = min(1.0, dt * 12).toDouble();

    x += (targetX - x) * interpolation;

    y = game.playerY;
  }

  @override
  void render(Canvas canvas) {
    if (flashSeconds > 0) {
      final phase = (flashSeconds * 30).floor();

      if (phase.isEven) {
        return;
      }
    }

    _drawCar(canvas, color, size, 0);
  }
}

class TrafficCarComponent extends PositionComponent
    with HasGameReference<RoadVisualGame> {
  TrafficCarComponent({
    required this.id,
    required this.laneIndex,
    required this.spawnedAtSeconds,
    required this.color,
    required this.vehicleVariant,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, priority: 4);

  final int id;

  final int laneIndex;

  final double spawnedAtSeconds;

  final Color color;

  final int vehicleVariant;

  bool resolved = false;

  @override
  void update(double dt) {
    super.update(dt);

    if (!game.hasStarted || game.isSessionFinished || resolved) {
      return;
    }

    y += game.config.baseSpeed * game.speedMultiplier * dt;

    x = game.laneCenterX(laneIndex) - size.x / 2;

    if (y > game.size.y + 10) {
      game.registerObstacleAvoided(this);
    }
  }

  @override
  void render(Canvas canvas) {
    _drawCar(canvas, color, size, vehicleVariant);
  }
}

class RoadObjectiveComponent extends PositionComponent
    with HasGameReference<RoadVisualGame> {
  RoadObjectiveComponent({
    required this.id,
    required this.laneIndex,
    required this.spawnedAtSeconds,
    required this.color,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, priority: 5);

  final int id;

  final int laneIndex;

  final double spawnedAtSeconds;

  final Color color;

  bool resolved = false;

  double animationTime = 0;

  @override
  void update(double dt) {
    super.update(dt);

    if (!game.hasStarted || game.isSessionFinished || resolved) {
      return;
    }

    animationTime += dt;

    y += game.config.baseSpeed * game.speedMultiplier * dt;

    x = game.laneCenterX(laneIndex) - size.x / 2;

    if (y > game.size.y + 10) {
      game.registerObjectiveMissed(this);
    }
  }

  @override
  void render(Canvas canvas) {
    final pulse = 0.92 + sin(animationTime * 5) * 0.08;

    canvas.save();

    canvas.translate(size.x / 2, size.y / 2);

    canvas.scale(pulse, pulse);

    final half = size.x * 0.48;

    final path = Path()
      ..moveTo(0, -half)
      ..lineTo(half, 0)
      ..lineTo(0, half)
      ..lineTo(-half, 0)
      ..close();

    canvas.drawPath(path, Paint()..color = color);

    canvas.restore();
  }
}

class RoadCollectEffectComponent extends PositionComponent {
  RoadCollectEffectComponent({required Vector2 position, required this.color})
    : super(position: position, anchor: Anchor.center, priority: 20);

  final Color color;

  double elapsed = 0;

  static const double duration = 0.28;

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
    final progress = (elapsed / duration).clamp(0.0, 1.0);

    final opacity = 1.0 - progress;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * opacity
      ..color = color.withValues(alpha: opacity);

    canvas.drawCircle(Offset.zero, 12 + 24 * progress, paint);
  }
}

void _drawCar(Canvas canvas, Color color, Vector2 size, int variant) {
  final paint = Paint()..color = color;

  final width = size.x;
  final height = size.y;

  Rect body;

  switch (variant) {
    case 1:
      body = Rect.fromLTWH(
        width * 0.12,
        height * 0.08,
        width * 0.76,
        height * 0.84,
      );

    case 2:
      body = Rect.fromLTWH(width * 0.18, 0, width * 0.64, height);

    default:
      body = Rect.fromLTWH(
        width * 0.15,
        height * 0.05,
        width * 0.70,
        height * 0.90,
      );
  }

  canvas.drawRRect(
    RRect.fromRectAndRadius(body, Radius.circular(width * 0.18)),
    paint,
  );

  final cabin = Rect.fromLTWH(
    width * 0.24,
    height * 0.24,
    width * 0.52,
    height * 0.32,
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(cabin, Radius.circular(width * 0.12)),
    paint,
  );

  final wheelPaint = Paint()..color = color;

  final wheelWidth = width * 0.12;

  final wheelHeight = height * 0.18;

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(width * 0.03, height * 0.20, wheelWidth, wheelHeight),
      const Radius.circular(3),
    ),
    wheelPaint,
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
        width - width * 0.03 - wheelWidth,
        height * 0.20,
        wheelWidth,
        wheelHeight,
      ),
      const Radius.circular(3),
    ),
    wheelPaint,
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(width * 0.03, height * 0.63, wheelWidth, wheelHeight),
      const Radius.circular(3),
    ),
    wheelPaint,
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
        width - width * 0.03 - wheelWidth,
        height * 0.63,
        wheelWidth,
        wheelHeight,
      ),
      const Radius.circular(3),
    ),
    wheelPaint,
  );
}
