import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../../core/services/game_music_service.dart';
import 'balloon_level.dart';
import 'balloon_session_result.dart';

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

  DateTime? _startedAt;

  BalloonSessionResult? _finalResult;
  BalloonSessionResult? get finalResult => _finalResult;

  double elapsedSeconds = 0;
  double spawnTimer = 0;

  int nextBalloonId = 1;

  bool hasStarted = false;
  bool isSessionFinished = false;

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

    if (spawnTimer >= config.spawnIntervalSeconds) {
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

    spawnBalloon();
  }

  List<BalloonComponent> get activeBalloons {
    return children
        .whereType<BalloonComponent>()
        .where((balloon) => !balloon.wasPopped && !balloon.wasEscaped)
        .toList();
  }

  void spawnBalloon() {
    if (isSessionFinished) return;

    if (activeBalloons.length >= config.maxActiveBalloons) {
      return;
    }

    final channel = random.nextBool()
        ? BalloonChannel.red
        : BalloonChannel.green;

    final balloonSize =
        config.minSize +
        random.nextDouble() * (config.maxSize - config.minSize);

    final speed =
        config.minSpeed +
        random.nextDouble() * (config.maxSpeed - config.minSpeed);

    final horizontalMargin = balloonSize * 0.60;

    final availableWidth = max(1.0, size.x - horizontalMargin * 2);

    final centerX = horizontalMargin + random.nextDouble() * availableWidth;

    final balloon = BalloonComponent(
      id: nextBalloonId,
      channel: channel,
      speed: speed,
      spawnedAtSeconds: elapsedSeconds,
      color: colorForChannel(channel),
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
    required this.speed,
    required this.spawnedAtSeconds,
    required this.color,
    required this.onPop,
    required this.onEscape,
    required super.position,
    required super.size,
  });

  final int id;

  final BalloonChannel channel;

  final double speed;
  final double spawnedAtSeconds;

  final Color color;

  final void Function(BalloonComponent balloon) onPop;

  final void Function(BalloonComponent balloon) onEscape;

  bool wasPopped = false;
  bool wasEscaped = false;

  @override
  void update(double dt) {
    super.update(dt);

    y -= speed * dt;

    if (!wasPopped && !wasEscaped && y + size.y < 0) {
      wasEscaped = true;

      onEscape(this);

      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final balloonWidth = size.x * 0.82;

    final balloonHeight = size.y * 0.78;

    final balloonRect = Rect.fromCenter(
      center: Offset(size.x / 2, balloonHeight / 2),
      width: balloonWidth,
      height: balloonHeight,
    );

    final paint = Paint()..color = color;

    canvas.drawOval(balloonRect, paint);

    final knot = Path()
      ..moveTo(size.x / 2, balloonRect.bottom - 2)
      ..lineTo(size.x / 2 - 7, balloonRect.bottom + 12)
      ..lineTo(size.x / 2 + 7, balloonRect.bottom + 12)
      ..close();

    canvas.drawPath(knot, paint);

    final stringPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.x / 2, balloonRect.bottom + 10),
      Offset(size.x / 2, size.y),
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
