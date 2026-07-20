import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'break_the_row_level.dart';
import 'break_the_row_session_result.dart';

class BreakTheRowGame extends FlameGame {
  BreakTheRowGame({
    required this.difficulty,
    required this.redContrast,
    required this.greenContrast,
    required this.onSessionFinished,
  });

  final BreakTheRowDifficulty difficulty;
  final double redContrast;
  final double greenContrast;
  final void Function(BreakTheRowSessionResult result) onSessionFinished;

  late final BreakTheRowLevelConfig config = difficulty.config;

  final Random random = Random();
  final DateTime startedAt = DateTime.now();

  final ValueNotifier<BreakTheRowStats> stats = ValueNotifier(
    BreakTheRowStats.empty(),
  );

  final List<BreakTheRowPieceEvent> _events = [];

  late final List<List<BreakTheRowChannel?>> board = List.generate(
    config.boardRows,
    (_) => List<BreakTheRowChannel?>.filled(config.boardColumns, null),
  );

  final List<FallingPiece> activePieces = [];

  int nextPieceId = 1;
  double elapsedSeconds = 0;
  double spawnTimer = 0;

  bool hasStarted = false;
  bool isSessionFinished = false;
  BreakTheRowSessionResult? _finalResult;

  Rect get boardRect {
    const topReserved = 130.0;
    const bottomReserved = 145.0;

    final maxWidth = size.x * 0.82;
    final maxHeight = max(120.0, size.y - topReserved - bottomReserved);

    final cellSize = min(
      maxWidth / config.boardColumns,
      maxHeight / config.boardRows,
    );

    final boardWidth = cellSize * config.boardColumns;
    final boardHeight = cellSize * config.boardRows;

    final left = (size.x - boardWidth) / 2;
    final top = topReserved + (maxHeight - boardHeight) / 2;

    return Rect.fromLTWH(left, top, boardWidth, boardHeight);
  }

  double get cellSize => boardRect.width / config.boardColumns;

  FallingPiece? get currentPiece {
    if (activePieces.isEmpty) return null;
    return activePieces.first;
  }

  @override
  Color backgroundColor() {
    return const Color(0xFFBFEFFF);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!hasStarted || isSessionFinished) return;

    elapsedSeconds += dt;
    spawnTimer += dt;

    if (activePieces.isEmpty) {
      spawnPiece();
      spawnTimer = 0;
    } else if (activePieces.length < config.maxActivePieces &&
        spawnTimer >= config.spawnIntervalSeconds) {
      spawnPiece();
      spawnTimer = 0;
    }

    for (final piece in activePieces.toList()) {
      piece.updateVisualPosition(dt);

      piece.fallAccumulator += dt;

      if (piece.fallAccumulator >= config.fallStepSeconds) {
        piece.fallAccumulator = 0;
        movePieceDown(piece);
      }
    }
  }

  void startGame() {
    if (hasStarted) return;

    hasStarted = true;
    spawnPiece();
  }

  void spawnPiece() {
    if (isSessionFinished) return;
    if (activePieces.length >= config.maxActivePieces) return;

    final channel = random.nextBool()
        ? BreakTheRowChannel.red
        : BreakTheRowChannel.green;

    final shape = _randomShape();
    final width = _shapeWidth(shape);

    final piece = FallingPiece(
      id: nextPieceId,
      channel: channel,
      shape: shape,
      row: 0,
      column: ((config.boardColumns - width) / 2).floor(),
      spawnedAtSeconds: elapsedSeconds,
    );

    nextPieceId++;

    if (!canPlace(piece, piece.row, piece.column, piece.shape)) {
      registerPieceFailed(piece);
      return;
    }

    activePieces.add(piece);
  }

  List<GridCell> _randomShape() {
    final shapes = <List<GridCell>>[
      // bloque 2x2
      const [GridCell(0, 0), GridCell(1, 0), GridCell(0, 1), GridCell(1, 1)],

      // línea de 3
      const [GridCell(0, 0), GridCell(1, 0), GridCell(2, 0)],

      // línea de 4
      const [GridCell(0, 0), GridCell(1, 0), GridCell(2, 0), GridCell(3, 0)],

      // L
      const [GridCell(0, 0), GridCell(0, 1), GridCell(1, 1), GridCell(2, 1)],

      // T
      const [GridCell(0, 0), GridCell(1, 0), GridCell(2, 0), GridCell(1, 1)],

      // Z
      const [GridCell(0, 0), GridCell(1, 0), GridCell(1, 1), GridCell(2, 1)],
    ];

    if (difficulty == BreakTheRowDifficulty.basic) {
      return shapes[random.nextInt(3)];
    }

    return shapes[random.nextInt(shapes.length)];
  }

  int _shapeWidth(List<GridCell> shape) {
    final maxX = shape.map((cell) => cell.x).reduce(max);
    return maxX + 1;
  }

  int _shapeHeight(List<GridCell> shape) {
    final maxY = shape.map((cell) => cell.y).reduce(max);
    return maxY + 1;
  }

  bool canPlace(
    FallingPiece piece,
    int targetRow,
    int targetColumn,
    List<GridCell> targetShape,
  ) {
    for (final cell in targetShape) {
      final row = targetRow + cell.y;
      final column = targetColumn + cell.x;

      if (column < 0 || column >= config.boardColumns) return false;
      if (row < 0 || row >= config.boardRows) return false;

      if (board[row][column] != null) return false;

      for (final otherPiece in activePieces) {
        if (otherPiece == piece) continue;

        for (final otherBlock in otherPiece.absoluteCells) {
          if (otherBlock.x == column && otherBlock.y == row) {
            return false;
          }
        }
      }
    }

    return true;
  }

  void moveLeft() {
    final piece = currentPiece;
    if (piece == null) return;

    final newColumn = piece.column - 1;

    if (canPlace(piece, piece.row, newColumn, piece.shape)) {
      piece.column = newColumn;
      piece.movements++;
    }
  }

  void moveRight() {
    final piece = currentPiece;
    if (piece == null) return;

    final newColumn = piece.column + 1;

    if (canPlace(piece, piece.row, newColumn, piece.shape)) {
      piece.column = newColumn;
      piece.movements++;
    }
  }

  void rotateCurrentPiece() {
    final piece = currentPiece;
    if (piece == null) return;

    final rotated = _normalizeShape(
      piece.shape.map((cell) {
        return GridCell(_shapeHeight(piece.shape) - 1 - cell.y, cell.x);
      }).toList(),
    );

    if (canPlace(piece, piece.row, piece.column, rotated)) {
      piece.shape = rotated;
      piece.rotations++;
      return;
    }

    // Intento suave de rotación con desplazamiento lateral.
    for (final offset in [-1, 1, -2, 2]) {
      final newColumn = piece.column + offset;

      if (canPlace(piece, piece.row, newColumn, rotated)) {
        piece.column = newColumn;
        piece.shape = rotated;
        piece.rotations++;
        return;
      }
    }
  }

  List<GridCell> _normalizeShape(List<GridCell> shape) {
    final minX = shape.map((cell) => cell.x).reduce(min);
    final minY = shape.map((cell) => cell.y).reduce(min);

    return shape.map((cell) => GridCell(cell.x - minX, cell.y - minY)).toList();
  }

  void fastDrop() {
    final piece = currentPiece;
    if (piece == null) return;

    piece.usedFastDrop = true;

    while (canPlace(piece, piece.row + 1, piece.column, piece.shape)) {
      piece.row++;
    }

    piece.snapVisualPosition();
    lockPiece(piece);
  }

  void movePieceDown(FallingPiece piece) {
    if (canPlace(piece, piece.row + 1, piece.column, piece.shape)) {
      piece.row++;
      return;
    }

    lockPiece(piece);
  }

  void lockPiece(FallingPiece piece) {
    if (!activePieces.contains(piece)) return;

    for (final block in piece.absoluteCells) {
      if (block.y >= 0 &&
          block.y < config.boardRows &&
          block.x >= 0 &&
          block.x < config.boardColumns) {
        board[block.y][block.x] = piece.channel;
      }
    }

    activePieces.remove(piece);

    final completedLines = clearCompletedLines();

    final current = stats.value;
    final updated = current.copyWith(
      score: current.score + 10 + completedLines * 100,
      linesCompleted: current.linesCompleted + completedLines,
      piecesPlaced: current.piecesPlaced + 1,
      redPiecesPlaced: piece.channel == BreakTheRowChannel.red
          ? current.redPiecesPlaced + 1
          : current.redPiecesPlaced,
      greenPiecesPlaced: piece.channel == BreakTheRowChannel.green
          ? current.greenPiecesPlaced + 1
          : current.greenPiecesPlaced,
    );

    stats.value = updated;

    _events.add(
      BreakTheRowPieceEvent(
        id: piece.id,
        channel: piece.channel,
        spawnedAtSeconds: piece.spawnedAtSeconds,
        completedAtSeconds: elapsedSeconds,
        result: BreakTheRowPieceResult.placed,
        movements: piece.movements,
        rotations: piece.rotations,
        usedFastDrop: piece.usedFastDrop,
        completedLines: completedLines,
      ),
    );

    if (updated.linesCompleted >= config.targetLines) {
      final result = finishSession(BreakTheRowEndReason.targetCompleted);
      onSessionFinished(result);
    }
  }

  int clearCompletedLines() {
    var completed = 0;

    for (int row = config.boardRows - 1; row >= 0; row--) {
      final isFull = board[row].every((cell) => cell != null);

      if (isFull) {
        completed++;

        board.removeAt(row);
        board.insert(
          0,
          List<BreakTheRowChannel?>.filled(config.boardColumns, null),
        );

        row++;
      }
    }

    return completed;
  }

  void registerPieceFailed(FallingPiece piece) {
    final current = stats.value;

    final updated = current.copyWith(
      livesLost: current.livesLost + 1,
      piecesFailed: current.piecesFailed + 1,
      redPiecesFailed: piece.channel == BreakTheRowChannel.red
          ? current.redPiecesFailed + 1
          : current.redPiecesFailed,
      greenPiecesFailed: piece.channel == BreakTheRowChannel.green
          ? current.greenPiecesFailed + 1
          : current.greenPiecesFailed,
    );

    stats.value = updated;

    _events.add(
      BreakTheRowPieceEvent(
        id: piece.id,
        channel: piece.channel,
        spawnedAtSeconds: piece.spawnedAtSeconds,
        completedAtSeconds: elapsedSeconds,
        result: BreakTheRowPieceResult.failed,
        movements: piece.movements,
        rotations: piece.rotations,
        usedFastDrop: piece.usedFastDrop,
        completedLines: 0,
      ),
    );

    if (updated.livesLost >= config.maxLives) {
      final result = finishSession(BreakTheRowEndReason.maxLivesLost);
      onSessionFinished(result);
    }
  }

  BreakTheRowSessionResult finishSession(BreakTheRowEndReason endReason) {
    if (_finalResult != null) return _finalResult!;

    isSessionFinished = true;

    pauseEngine();

    _finalResult = BreakTheRowSessionResult(
      startedAt: startedAt,
      endedAt: DateTime.now(),
      durationSeconds: elapsedSeconds,
      endReason: endReason,
      stats: stats.value,
      events: List.unmodifiable(_events),
    );

    return _finalResult!;
  }

  Color colorForChannel(BreakTheRowChannel channel) {
    final multiplier = config.contrastMultiplier;

    if (channel == BreakTheRowChannel.red) {
      final alpha = (redContrast * multiplier).clamp(0.25, 1.0);
      return AppColors.red.withValues(alpha: alpha);
    }

    final alpha = (greenContrast * multiplier).clamp(0.25, 1.0);
    return AppColors.green.withValues(alpha: alpha);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _renderDecorativeBackground(canvas);
    _renderBoard(canvas);
    _renderLockedBlocks(canvas);
    _renderActivePieces(canvas);
  }

  void _renderBoard(Canvas canvas) {
    final rect = boardRect;

    final boardFillPaint = Paint()..color = const Color(0xFF111111);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppColors.cyan.withValues(alpha: 0.85);

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(18));

    canvas.drawRRect(rrect, boardFillPaint);
    canvas.drawRRect(rrect, borderPaint);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1;

    for (int column = 1; column < config.boardColumns; column++) {
      final x = rect.left + column * cellSize;

      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gridPaint);
    }

    for (int row = 1; row < config.boardRows; row++) {
      final y = rect.top + row * cellSize;

      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridPaint);
    }
  }

  void _renderLockedBlocks(Canvas canvas) {
    for (int row = 0; row < config.boardRows; row++) {
      for (int column = 0; column < config.boardColumns; column++) {
        final channel = board[row][column];
        if (channel == null) continue;

        _drawBlock(
          canvas: canvas,
          row: row,
          column: column,
          color: colorForChannel(channel),
          highlighted: false,
        );
      }
    }
  }

  void _renderActivePieces(Canvas canvas) {
    for (final piece in activePieces) {
      final highlighted = piece == currentPiece;

      for (final block in piece.visualCells) {
        _drawVisualBlock(
          canvas: canvas,
          row: block.y,
          column: block.x,
          color: colorForChannel(piece.channel),
          highlighted: highlighted,
        );
      }
    }
  }

  void _renderDecorativeBackground(Canvas canvas) {
    final fullRect = Rect.fromLTWH(0, 0, size.x, size.y);

    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFBFEFFF), Color(0xFFEAFBFF), Color(0xFFFDFEFF)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(fullRect);

    canvas.drawRect(fullRect, skyPaint);

    _drawSun(canvas);
    _drawRainbow(canvas);
    _drawCloud(
      canvas,
      center: Offset(size.x * 0.18, size.y * 0.14),
      scale: 1.0,
    );
    _drawCloud(
      canvas,
      center: Offset(size.x * 0.80, size.y * 0.18),
      scale: 0.9,
    );
    _drawCloud(
      canvas,
      center: Offset(size.x * 0.23, size.y * 0.76),
      scale: 0.85,
    );
    _drawCloud(
      canvas,
      center: Offset(size.x * 0.82, size.y * 0.72),
      scale: 0.95,
    );

    _drawHills(canvas);
  }

  void _drawSun(Canvas canvas) {
    final center = Offset(size.x * 0.88, size.y * 0.11);
    final radius = size.x * 0.065;

    final glowPaint = Paint()
      ..color = const Color(0xFFFFE082).withValues(alpha: 0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    canvas.drawCircle(center, radius + 14, glowPaint);

    final sunPaint = Paint()..color = const Color(0xFFFFE082);

    canvas.drawCircle(center, radius, sunPaint);
  }

  void _drawCloud(
    Canvas canvas, {
    required Offset center,
    required double scale,
  }) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.78);

    canvas.drawCircle(
      Offset(center.dx - 28 * scale, center.dy),
      22 * scale,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy - 8 * scale),
      28 * scale,
      cloudPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + 30 * scale, center.dy),
      22 * scale,
      cloudPaint,
    );

    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 10 * scale),
        width: 92 * scale,
        height: 28 * scale,
      ),
      Radius.circular(16 * scale),
    );

    canvas.drawRRect(baseRect, cloudPaint);
  }

  void _drawRainbow(Canvas canvas) {
    final center = Offset(size.x * 0.12, size.y * 0.02);

    final colors = [
      const Color(0xFFFF8A80),
      const Color(0xFFFFCC80),
      const Color(0xFFFFFF8D),
      const Color(0xFFB9F6CA),
      const Color(0xFF80D8FF),
      const Color(0xFFB388FF),
    ];

    double radius = size.x * 0.28;

    for (final color in colors) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = color.withValues(alpha: 0.30);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        0.15,
        1.15,
        false,
        paint,
      );

      radius -= 11;
    }
  }

  void _drawHills(Canvas canvas) {
    final hillBack = Path()
      ..moveTo(0, size.y * 0.84)
      ..quadraticBezierTo(
        size.x * 0.18,
        size.y * 0.74,
        size.x * 0.40,
        size.y * 0.84,
      )
      ..quadraticBezierTo(size.x * 0.62, size.y * 0.94, size.x, size.y * 0.80)
      ..lineTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..close();

    final backPaint = Paint()
      ..color = const Color(0xFFA5D6A7).withValues(alpha: 0.55);

    canvas.drawPath(hillBack, backPaint);

    final hillFront = Path()
      ..moveTo(0, size.y * 0.90)
      ..quadraticBezierTo(
        size.x * 0.25,
        size.y * 0.79,
        size.x * 0.48,
        size.y * 0.91,
      )
      ..quadraticBezierTo(size.x * 0.76, size.y * 1.00, size.x, size.y * 0.88)
      ..lineTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..close();

    final frontPaint = Paint()
      ..color = const Color(0xFF81C784).withValues(alpha: 0.75);

    canvas.drawPath(hillFront, frontPaint);
  }

  void _drawBlock({
    required Canvas canvas,
    required int row,
    required int column,
    required Color color,
    required bool highlighted,
  }) {
    final rect = boardRect;

    final fill = config.blockFillFactor;
    final blockSize = cellSize * fill;
    final offset = (cellSize - blockSize) / 2;

    final left = rect.left + column * cellSize + offset;
    final top = rect.top + row * cellSize + offset;

    final blockRect = Rect.fromLTWH(left, top, blockSize, blockSize);

    final radius = Radius.circular(cellSize * 0.18);

    final rrect = RRect.fromRectAndRadius(blockRect, radius);

    final paint = Paint()..color = color;
    canvas.drawRRect(rrect, paint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = highlighted ? 3 : 1.5
      ..color = Colors.white.withValues(alpha: highlighted ? 0.85 : 0.35);

    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawVisualBlock({
    required Canvas canvas,
    required double row,
    required double column,
    required Color color,
    required bool highlighted,
  }) {
    final rect = boardRect;

    final fill = config.blockFillFactor;
    final blockSize = cellSize * fill;
    final offset = (cellSize - blockSize) / 2;

    final left = rect.left + column * cellSize + offset;
    final top = rect.top + row * cellSize + offset;

    final blockRect = Rect.fromLTWH(left, top, blockSize, blockSize);

    final radius = Radius.circular(cellSize * 0.18);

    final rrect = RRect.fromRectAndRadius(blockRect, radius);

    final paint = Paint()..color = color;
    canvas.drawRRect(rrect, paint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = highlighted ? 3 : 1.5
      ..color = Colors.white.withValues(alpha: highlighted ? 0.75 : 0.30);

    canvas.drawRRect(rrect, borderPaint);
  }
}

class FallingPiece {
  FallingPiece({
    required this.id,
    required this.channel,
    required this.shape,
    required this.row,
    required this.column,
    required this.spawnedAtSeconds,
  }) : visualRow = row.toDouble(),
       visualColumn = column.toDouble();

  final int id;
  final BreakTheRowChannel channel;
  List<GridCell> shape;

  int row;
  int column;

  double visualRow;
  double visualColumn;

  final double spawnedAtSeconds;

  double fallAccumulator = 0;

  int movements = 0;
  int rotations = 0;
  bool usedFastDrop = false;

  List<GridCell> get absoluteCells {
    return shape.map((cell) {
      return GridCell(column + cell.x, row + cell.y);
    }).toList();
  }

  List<VisualGridCell> get visualCells {
    return shape.map((cell) {
      return VisualGridCell(visualColumn + cell.x, visualRow + cell.y);
    }).toList();
  }

  void updateVisualPosition(double dt) {
    const smoothness = 12.0;

    final factor = (dt * smoothness).clamp(0.0, 1.0);

    visualRow += (row - visualRow) * factor;
    visualColumn += (column - visualColumn) * factor;
  }

  void snapVisualPosition() {
    visualRow = row.toDouble();
    visualColumn = column.toDouble();
  }
}

class GridCell {
  const GridCell(this.x, this.y);

  final int x;
  final int y;
}

class VisualGridCell {
  const VisualGridCell(this.x, this.y);

  final double x;
  final double y;
}
