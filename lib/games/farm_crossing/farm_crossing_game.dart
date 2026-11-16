import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../../core/services/game_music_service.dart';
import 'farm_crossing_level.dart';
import 'farm_crossing_session_result.dart';

class FarmCrossingPosition {
  const FarmCrossingPosition({required this.column, required this.row});

  final int column;
  final int row;
}

enum _FarmVehicleType { car, van, bus }

class _FarmVehicle {
  _FarmVehicle({
    required this.lane,
    required this.progress,
    required this.direction,
    required this.speed,
    required this.type,
  });

  final int lane;
  double progress;
  final int direction;
  final double speed;
  final _FarmVehicleType type;
}

class FarmCrossingGame extends FlameGame {
  FarmCrossingGame({
    required this.difficulty,
    required this.redContrast,
    required this.greenContrast,
    this.onSessionFinished,
  }) : config = difficulty.config;

  final FarmCrossingDifficulty difficulty;
  final FarmCrossingConfig config;

  final double redContrast;
  final double greenContrast;

  final void Function(FarmCrossingSessionResult result)? onSessionFinished;

  static const int columnCount = 5;
  static const int maxLives = 3;

  static const String objectiveSound = 'farm_objective.wav';

  static const String collisionSound = 'farm_collision_crush.mp3';

  static const String goalSound = 'farm_goal.wav';

  final math.Random _random = math.Random();

  final ValueNotifier<FarmCrossingPosition> position =
      ValueNotifier<FarmCrossingPosition>(
        const FarmCrossingPosition(column: 2, row: 0),
      );

  final ValueNotifier<int> livesLeft = ValueNotifier<int>(maxLives);

  final ValueNotifier<int> collisions = ValueNotifier<int>(0);

  final ValueNotifier<int> roundsCompleted = ValueNotifier<int>(0);

  final ValueNotifier<int> objectivesCollected = ValueNotifier<int>(0);

  final ValueNotifier<int> objectivesMissed = ValueNotifier<int>(0);

  final ValueNotifier<bool> objectiveCollected = ValueNotifier<bool>(false);

  final ValueNotifier<bool> roundCompleted = ValueNotifier<bool>(false);

  final ValueNotifier<bool> sessionCompleted = ValueNotifier<bool>(false);

  final ValueNotifier<bool> gameOver = ValueNotifier<bool>(false);

  final List<_FarmVehicle> _vehicles = [];

  final List<FarmCrossingEvent> _events = [];

  bool _vehiclesInitialized = false;
  bool _sessionFinished = false;

  double _collisionCooldown = 0;
  double _elapsedSeconds = 0;

  int _eventId = 0;

  int _objectiveColumn = 2;
  int _objectiveRow = 1;

  int? _activeLaneIndex;
  double? _activeLaneEnteredAtSeconds;

  DateTime? _startedAt;
  FarmCrossingSessionResult? _finalResult;

  int get totalRows => config.laneCount + 2;

  bool get reachedGoal => position.value.row == totalRows - 1;

  bool get hasStarted => _startedAt != null;

  List<FarmCrossingEvent> get events => List.unmodifiable(_events);

  FarmCrossingSessionResult? get finalResult => _finalResult;

  bool get _canMove =>
      !gameOver.value &&
      !sessionCompleted.value &&
      !roundCompleted.value &&
      !_sessionFinished;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await FlameAudio.audioCache.loadAll([
      objectiveSound,
      collisionSound,
      goalSound,
    ]);

    GameMusicService.instance.playRandom(
      moods: {GameMusicMood.playful},
      volume: 0.24,
    );

    _startNewSession();
    _spawnObjective();
  }

  void _startNewSession() {
    _startedAt = DateTime.now();
    _elapsedSeconds = 0;

    _eventId = 0;
    _events.clear();

    _sessionFinished = false;
    _finalResult = null;

    _activeLaneIndex = null;
    _activeLaneEnteredAtSeconds = null;
  }

  void _initializeVehicles() {
    if (_vehiclesInitialized) return;

    final types = _FarmVehicleType.values;

    for (var lane = 0; lane < config.laneCount; lane++) {
      final direction = lane.isEven ? 1 : -1;

      final baseSpeed = (0.13 + lane * 0.015) * config.vehicleSpeedMultiplier;

      _vehicles.add(
        _FarmVehicle(
          lane: lane,
          progress: lane.isEven ? 0.10 : 0.85,
          direction: direction,
          speed: baseSpeed,
          type: types[lane % types.length],
        ),
      );

      _vehicles.add(
        _FarmVehicle(
          lane: lane,
          progress: lane.isEven ? 0.62 : 0.35,
          direction: direction,
          speed: baseSpeed,
          type: types[(lane + 1) % types.length],
        ),
      );
    }

    _vehiclesInitialized = true;
  }

  void _spawnObjective() {
    _objectiveColumn = _random.nextInt(columnCount);

    _objectiveRow = 1 + _random.nextInt(config.laneCount);

    objectiveCollected.value = false;
  }

  void moveUp() {
    if (!_canMove) return;

    final previous = position.value;

    if (previous.row >= totalRows - 1) return;

    position.value = FarmCrossingPosition(
      column: previous.column,
      row: previous.row + 1,
    );

    _afterMovement(previous);
  }

  void moveDown() {
    if (!_canMove) return;

    final previous = position.value;

    if (previous.row <= 0) return;

    position.value = FarmCrossingPosition(
      column: previous.column,
      row: previous.row - 1,
    );

    _afterMovement(previous);
  }

  void moveLeft() {
    if (!_canMove) return;

    final previous = position.value;

    if (previous.column <= 0) return;

    position.value = FarmCrossingPosition(
      column: previous.column - 1,
      row: previous.row,
    );

    _afterMovement(previous);
  }

  void moveRight() {
    if (!_canMove) return;

    final previous = position.value;

    if (previous.column >= columnCount - 1) return;

    position.value = FarmCrossingPosition(
      column: previous.column + 1,
      row: previous.row,
    );

    _afterMovement(previous);
  }

  void _afterMovement(FarmCrossingPosition previous) {
    final current = position.value;

    _checkObjectiveCollection();

    if (current.row != previous.row) {
      final previousWasLane =
          previous.row >= 1 && previous.row <= config.laneCount;

      final movingForward = current.row > previous.row;

      if (previousWasLane && movingForward) {
        _registerLaneCrossed(previous.row - 1);
      }

      final currentIsLane = current.row >= 1 && current.row <= config.laneCount;

      if (currentIsLane) {
        _activeLaneIndex = current.row - 1;

        _activeLaneEnteredAtSeconds = _elapsedSeconds;
      } else {
        _activeLaneIndex = null;
        _activeLaneEnteredAtSeconds = null;
      }
    }

    if (reachedGoal) {
      _completeRound();
    }
  }

  void _checkObjectiveCollection() {
    if (objectiveCollected.value) return;

    final current = position.value;

    if (current.column != _objectiveColumn || current.row != _objectiveRow) {
      return;
    }

    objectiveCollected.value = true;
    objectivesCollected.value++;

    FlameAudio.play(objectiveSound, volume: 0.60);

    _recordEvent(type: FarmCrossingEventType.objectiveCollected);
  }

  void _registerLaneCrossed(int laneIndex) {
    int? laneTimeMs;

    if (_activeLaneIndex == laneIndex && _activeLaneEnteredAtSeconds != null) {
      laneTimeMs = ((_elapsedSeconds - _activeLaneEnteredAtSeconds!) * 1000)
          .round();
    }

    _recordEvent(
      type: FarmCrossingEventType.laneCrossed,
      laneIndex: laneIndex,
      laneTimeMs: laneTimeMs,
    );
  }

  void _completeRound() {
    if (roundCompleted.value) return;
    if (_sessionFinished) return;

    final roundNumber = roundsCompleted.value + 1;

    if (!objectiveCollected.value) {
      objectivesMissed.value++;

      _recordEvent(
        type: FarmCrossingEventType.objectiveMissed,
        roundNumber: roundNumber,
      );
    }

    FlameAudio.play(goalSound, volume: 0.65);

    roundsCompleted.value++;

    _recordEvent(
      type: FarmCrossingEventType.roundCompleted,
      roundNumber: roundNumber,
    );

    roundCompleted.value = true;

    _activeLaneIndex = null;
    _activeLaneEnteredAtSeconds = null;

    if (roundsCompleted.value >= config.targetCrossings) {
      sessionCompleted.value = true;

      finishSession(FarmCrossingEndReason.targetCompleted);
    }
  }

  void startNextRound() {
    if (gameOver.value) return;
    if (sessionCompleted.value) return;
    if (!roundCompleted.value) return;

    position.value = const FarmCrossingPosition(column: 2, row: 0);

    roundCompleted.value = false;

    _activeLaneIndex = null;
    _activeLaneEnteredAtSeconds = null;

    _spawnObjective();
  }

  void restartSession() {
    livesLeft.value = maxLives;
    collisions.value = 0;

    roundsCompleted.value = 0;

    objectivesCollected.value = 0;
    objectivesMissed.value = 0;

    objectiveCollected.value = false;

    roundCompleted.value = false;
    sessionCompleted.value = false;
    gameOver.value = false;

    _collisionCooldown = 0;

    position.value = const FarmCrossingPosition(column: 2, row: 0);

    _startNewSession();
    _spawnObjective();

    GameMusicService.instance.playRandom(
      moods: {GameMusicMood.playful},
      volume: 0.24,
    );
  }

  void _recordEvent({
    required FarmCrossingEventType type,
    int? roundNumber,
    int? laneIndex,
    int? laneTimeMs,
  }) {
    _eventId++;

    _events.add(
      FarmCrossingEvent(
        id: _eventId,
        type: type,
        occurredAtSeconds: _elapsedSeconds,
        roundNumber: roundNumber ?? roundsCompleted.value + 1,
        laneIndex: laneIndex,
        laneTimeMs: laneTimeMs,
      ),
    );
  }

  FarmCrossingSessionResult finishSession(FarmCrossingEndReason reason) {
    final existing = _finalResult;

    GameMusicService.instance.stop();

    if (existing != null) {
      return existing;
    }

    _sessionFinished = true;

    final endedAt = DateTime.now();

    final startedAt =
        _startedAt ??
        endedAt.subtract(
          Duration(milliseconds: (_elapsedSeconds * 1000).round()),
        );

    final lanesCrossed = _events
        .where((event) => event.type == FarmCrossingEventType.laneCrossed)
        .length;

    final result = FarmCrossingSessionResult(
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: _elapsedSeconds,
      endReason: reason,
      stats: FarmCrossingStats(
        roundsCompleted: roundsCompleted.value,
        collisions: collisions.value,
        objectivesCollected: objectivesCollected.value,
        objectivesMissed: objectivesMissed.value,
        lanesCrossed: lanesCrossed,
        livesLost: maxLives - livesLeft.value,
      ),
      events: List.unmodifiable(List<FarmCrossingEvent>.from(_events)),
    );

    _finalResult = result;

    onSessionFinished?.call(result);

    return result;
  }

  Rect get boardRect {
    final boardWidth = math.max(0.0, size.x - 24);

    final boardHeight = math.max(100.0, size.y - 210);

    return Rect.fromLTWH(12, 110, boardWidth, boardHeight);
  }

  double get cellWidth => boardRect.width / columnCount;

  double get cellHeight => boardRect.height / totalRows;

  Offset cellCenter({required int column, required int row}) {
    final x = boardRect.left + (column + 0.5) * cellWidth;

    final y = boardRect.bottom - (row + 0.5) * cellHeight;

    return Offset(x, y);
  }

  Rect _vehicleRect(_FarmVehicle vehicle) {
    final board = boardRect;

    final laneRow = vehicle.lane + 1;

    final centerY = board.bottom - (laneRow + 0.5) * cellHeight;

    final centerX = board.left + vehicle.progress * board.width;

    double widthMultiplier;
    double heightMultiplier;

    switch (vehicle.type) {
      case _FarmVehicleType.car:
        widthMultiplier = 0.68;
        heightMultiplier = 0.40;

      case _FarmVehicleType.van:
        widthMultiplier = 0.78;
        heightMultiplier = 0.46;

      case _FarmVehicleType.bus:
        widthMultiplier = 0.92;
        heightMultiplier = 0.48;
    }

    return Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: cellWidth * widthMultiplier,
      height: cellHeight * heightMultiplier,
    );
  }

  Rect get _chickenCollisionRect {
    final current = position.value;

    final center = cellCenter(column: current.column, row: current.row);

    return Rect.fromCenter(
      center: center,
      width: cellWidth * 0.48,
      height: cellHeight * 0.48,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _initializeVehicles();

    if (!_sessionFinished) {
      _elapsedSeconds += dt;
    }

    if (_collisionCooldown > 0) {
      _collisionCooldown -= dt;
    }

    for (final vehicle in _vehicles) {
      vehicle.progress += vehicle.direction * vehicle.speed * dt;

      if (vehicle.direction > 0 && vehicle.progress > 1.15) {
        vehicle.progress = -0.15;
      }

      if (vehicle.direction < 0 && vehicle.progress < -0.15) {
        vehicle.progress = 1.15;
      }
    }

    _checkCollision();
  }

  void _checkCollision() {
    if (_sessionFinished) return;
    if (gameOver.value) return;
    if (roundCompleted.value) return;
    if (sessionCompleted.value) return;
    if (_collisionCooldown > 0) return;

    final currentRow = position.value.row;

    if (currentRow <= 0 || currentRow >= totalRows - 1) {
      return;
    }

    final currentLane = currentRow - 1;

    final chickenRect = _chickenCollisionRect;

    for (final vehicle in _vehicles) {
      if (vehicle.lane != currentLane) {
        continue;
      }

      if (!chickenRect.overlaps(_vehicleRect(vehicle))) {
        continue;
      }

      _registerCollision(currentLane);

      return;
    }
  }

  void _registerCollision(int laneIndex) {
    collisions.value++;

    FlameAudio.play(collisionSound, volume: 1.0);

    int? laneTimeMs;

    if (_activeLaneIndex == laneIndex && _activeLaneEnteredAtSeconds != null) {
      laneTimeMs = ((_elapsedSeconds - _activeLaneEnteredAtSeconds!) * 1000)
          .round();
    }

    _recordEvent(
      type: FarmCrossingEventType.collision,
      laneIndex: laneIndex,
      laneTimeMs: laneTimeMs,
    );

    livesLeft.value = math.max(0, livesLeft.value - 1);

    _collisionCooldown = 0.8;

    _activeLaneIndex = null;
    _activeLaneEnteredAtSeconds = null;

    if (livesLeft.value <= 0) {
      gameOver.value = true;

      finishSession(FarmCrossingEndReason.maxLivesLost);

      return;
    }

    position.value = const FarmCrossingPosition(column: 2, row: 0);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _initializeVehicles();

    final board = boardRect;

    final safePaint = Paint()..color = const Color(0xFFE4E4E7);

    final roadPaint = Paint()..color = const Color(0xFF303238);

    final roadAltPaint = Paint()..color = const Color(0xFF383A40);

    final borderPaint = Paint()
      ..color = const Color(0xFF18181B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final startArea = Rect.fromLTWH(
      board.left,
      board.bottom - cellHeight,
      board.width,
      cellHeight,
    );

    canvas.drawRect(startArea, safePaint);

    _drawSafeZonePattern(canvas, startArea);

    for (var lane = 0; lane < config.laneCount; lane++) {
      final y = board.bottom - cellHeight * (lane + 2);

      final laneRect = Rect.fromLTWH(board.left, y, board.width, cellHeight);

      canvas.drawRect(laneRect, lane.isEven ? roadPaint : roadAltPaint);

      _drawLaneMarks(canvas, laneRect);
    }

    final goalArea = Rect.fromLTWH(
      board.left,
      board.top,
      board.width,
      cellHeight,
    );

    canvas.drawRect(goalArea, safePaint);

    _drawSafeZonePattern(canvas, goalArea);

    canvas.drawRect(board, borderPaint);

    _drawGoal(canvas);

    if (!objectiveCollected.value && !roundCompleted.value) {
      _drawObjective(canvas);
    }

    for (final vehicle in _vehicles) {
      _drawVehicle(canvas, vehicle);
    }

    _drawChicken(canvas);
  }

  void _drawSafeZonePattern(Canvas canvas, Rect area) {
    final paint = Paint()
      ..color = const Color(0xFF71717A).withValues(alpha: 0.10)
      ..strokeWidth = 1.5;

    const spacing = 28.0;

    var x = area.left - area.height;

    while (x < area.right) {
      canvas.drawLine(
        Offset(x, area.bottom),
        Offset(x + area.height, area.top),
        paint,
      );

      x += spacing;
    }
  }

  void _drawLaneMarks(Canvas canvas, Rect lane) {
    final paint = Paint()
      ..color = const Color(0xFFA1A1AA)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const dashWidth = 22.0;
    const gap = 18.0;

    final y = lane.center.dy;

    var x = lane.left + 12;

    while (x < lane.right) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + dashWidth, lane.right - 8), y),
        paint,
      );

      x += dashWidth + gap;
    }
  }

  void _drawObjective(Canvas canvas) {
    final center = cellCenter(column: _objectiveColumn, row: _objectiveRow);

    final size = math.min(cellWidth, cellHeight);

    final redValue = (255 * redContrast.clamp(0.3, 1.0)).round();

    final paint = Paint()..color = Color.fromARGB(255, redValue, 0, 0);

    final cobRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - size * 0.02),
      width: size * 0.18,
      height: size * 0.44,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(cobRect, Radius.circular(size * 0.09)),
      paint,
    );

    final topTip = Path()
      ..moveTo(center.dx, cobRect.top - size * 0.10)
      ..lineTo(center.dx - size * 0.06, cobRect.top + size * 0.02)
      ..lineTo(center.dx + size * 0.06, cobRect.top + size * 0.02)
      ..close();

    canvas.drawPath(topTip, paint);

    final leftLeaf = Path()
      ..moveTo(center.dx - size * 0.03, cobRect.bottom - size * 0.08)
      ..quadraticBezierTo(
        center.dx - size * 0.22,
        center.dy + size * 0.08,
        center.dx - size * 0.10,
        center.dy + size * 0.20,
      )
      ..quadraticBezierTo(
        center.dx - size * 0.01,
        center.dy + size * 0.12,
        center.dx,
        cobRect.bottom - size * 0.02,
      )
      ..close();

    final rightLeaf = Path()
      ..moveTo(center.dx + size * 0.03, cobRect.bottom - size * 0.08)
      ..quadraticBezierTo(
        center.dx + size * 0.22,
        center.dy + size * 0.08,
        center.dx + size * 0.10,
        center.dy + size * 0.20,
      )
      ..quadraticBezierTo(
        center.dx + size * 0.01,
        center.dy + size * 0.12,
        center.dx,
        cobRect.bottom - size * 0.02,
      )
      ..close();

    canvas.drawPath(leftLeaf, paint);

    canvas.drawPath(rightLeaf, paint);
  }

  void _drawVehicle(Canvas canvas, _FarmVehicle vehicle) {
    final rect = _vehicleRect(vehicle);

    final greenValue = (255 * greenContrast.clamp(0.3, 1.0)).round();

    final paint = Paint()..color = Color.fromARGB(255, 0, greenValue, 0);

    switch (vehicle.type) {
      case _FarmVehicleType.car:
        _drawCar(canvas, rect, paint, vehicle.direction);

      case _FarmVehicleType.van:
        _drawVan(canvas, rect, paint, vehicle.direction);

      case _FarmVehicleType.bus:
        _drawBus(canvas, rect, paint, vehicle.direction);
    }
  }

  void _drawCar(Canvas canvas, Rect rect, Paint paint, int direction) {
    final body = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.center.dy + rect.height * 0.08),
      width: rect.width,
      height: rect.height * 0.55,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(rect.height * 0.15)),
      paint,
    );

    final cabin = Rect.fromCenter(
      center: Offset(
        rect.center.dx - direction * rect.width * 0.08,
        rect.top + rect.height * 0.34,
      ),
      width: rect.width * 0.42,
      height: rect.height * 0.28,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(cabin, Radius.circular(rect.height * 0.12)),
      paint,
    );

    _drawVehicleWheels(canvas, rect, paint, 0.23);
  }

  void _drawVan(Canvas canvas, Rect rect, Paint paint, int direction) {
    final body = Rect.fromCenter(
      center: rect.center,
      width: rect.width,
      height: rect.height * 0.72,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(rect.height * 0.16)),
      paint,
    );

    final roof = Rect.fromLTWH(
      direction > 0
          ? rect.left + rect.width * 0.18
          : rect.left + rect.width * 0.10,
      rect.top + rect.height * 0.08,
      rect.width * 0.62,
      rect.height * 0.30,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(roof, Radius.circular(rect.height * 0.12)),
      paint,
    );

    _drawVehicleWheels(canvas, rect, paint, 0.22);
  }

  void _drawBus(Canvas canvas, Rect rect, Paint paint, int direction) {
    final body = Rect.fromCenter(
      center: rect.center,
      width: rect.width,
      height: rect.height * 0.76,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(rect.height * 0.13)),
      paint,
    );

    final front = Path();

    if (direction > 0) {
      front
        ..moveTo(rect.right - rect.width * 0.10, rect.top + rect.height * 0.12)
        ..lineTo(rect.right, rect.center.dy)
        ..lineTo(
          rect.right - rect.width * 0.10,
          rect.bottom - rect.height * 0.12,
        )
        ..close();
    } else {
      front
        ..moveTo(rect.left + rect.width * 0.10, rect.top + rect.height * 0.12)
        ..lineTo(rect.left, rect.center.dy)
        ..lineTo(
          rect.left + rect.width * 0.10,
          rect.bottom - rect.height * 0.12,
        )
        ..close();
    }

    canvas.drawPath(front, paint);

    _drawVehicleWheels(canvas, rect, paint, 0.18);
  }

  void _drawVehicleWheels(
    Canvas canvas,
    Rect rect,
    Paint paint,
    double horizontalPosition,
  ) {
    final wheelRadius = rect.height * 0.12;

    canvas.drawCircle(
      Offset(
        rect.left + rect.width * horizontalPosition,
        rect.bottom - wheelRadius * 0.10,
      ),
      wheelRadius,
      paint,
    );

    canvas.drawCircle(
      Offset(
        rect.right - rect.width * horizontalPosition,
        rect.bottom - wheelRadius * 0.10,
      ),
      wheelRadius,
      paint,
    );
  }

  void _drawGoal(Canvas canvas) {
    final area = Rect.fromLTWH(
      boardRect.left,
      boardRect.top,
      boardRect.width,
      cellHeight,
    );

    final squareSize = math.max(12.0, cellHeight * 0.18);

    final darkPaint = Paint()
      ..color = const Color(0xFF71717A).withValues(alpha: 0.22);

    var column = 0;

    for (var x = area.left; x < area.right; x += squareSize) {
      if (column.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(
            x,
            area.top,
            math.min(squareSize, area.right - x),
            squareSize * 0.45,
          ),
          darkPaint,
        );
      }

      column++;
    }

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'META',
        style: TextStyle(
          color: Color(0xFF3F3F46),
          fontSize: 19,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        area.center.dx - textPainter.width / 2,
        area.center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawChicken(Canvas canvas) {
    final current = position.value;

    final center = cellCenter(column: current.column, row: current.row);

    final size = math.min(cellWidth, cellHeight);

    final redValue = (255 * redContrast.clamp(0.3, 1.0)).round();

    final paint = Paint()..color = Color.fromARGB(255, redValue, 0, 0);

    final body = Rect.fromCenter(
      center: Offset(center.dx, center.dy + size * 0.02),
      width: size * 0.34,
      height: size * 0.28,
    );

    canvas.drawOval(body, paint);

    final headCenter = Offset(center.dx + size * 0.15, center.dy - size * 0.10);

    canvas.drawCircle(headCenter, size * 0.08, paint);

    final crest1 = Path()
      ..moveTo(headCenter.dx - size * 0.05, headCenter.dy - size * 0.06)
      ..lineTo(headCenter.dx - size * 0.01, headCenter.dy - size * 0.14)
      ..lineTo(headCenter.dx + size * 0.01, headCenter.dy - size * 0.05)
      ..close();

    final crest2 = Path()
      ..moveTo(headCenter.dx - size * 0.01, headCenter.dy - size * 0.06)
      ..lineTo(headCenter.dx + size * 0.04, headCenter.dy - size * 0.15)
      ..lineTo(headCenter.dx + size * 0.05, headCenter.dy - size * 0.04)
      ..close();

    canvas.drawPath(crest1, paint);

    canvas.drawPath(crest2, paint);

    final beak = Path()
      ..moveTo(headCenter.dx + size * 0.07, headCenter.dy)
      ..lineTo(headCenter.dx + size * 0.15, headCenter.dy - size * 0.02)
      ..lineTo(headCenter.dx + size * 0.09, headCenter.dy + size * 0.04)
      ..close();

    canvas.drawPath(beak, paint);

    final tail = Path()
      ..moveTo(body.left + size * 0.02, body.center.dy - size * 0.02)
      ..lineTo(body.left - size * 0.10, body.center.dy - size * 0.12)
      ..lineTo(body.left - size * 0.07, body.center.dy + size * 0.03)
      ..lineTo(body.left - size * 0.15, body.center.dy - size * 0.01)
      ..lineTo(body.left - size * 0.07, body.center.dy + size * 0.10)
      ..close();

    canvas.drawPath(tail, paint);

    final wing = Rect.fromCenter(
      center: Offset(center.dx + size * 0.02, center.dy + size * 0.03),
      width: size * 0.15,
      height: size * 0.10,
    );

    canvas.drawOval(wing, paint);
  }

  @override
  void onRemove() {
    GameMusicService.instance.stop();

    position.dispose();

    livesLeft.dispose();
    collisions.dispose();

    roundsCompleted.dispose();

    objectivesCollected.dispose();
    objectivesMissed.dispose();

    objectiveCollected.dispose();

    roundCompleted.dispose();
    sessionCompleted.dispose();

    gameOver.dispose();

    super.onRemove();
  }
}
