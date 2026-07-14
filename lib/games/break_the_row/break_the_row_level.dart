enum BreakTheRowDifficulty { basic, medium, hard }

class BreakTheRowLevelConfig {
  const BreakTheRowLevelConfig({
    required this.name,
    required this.description,
    required this.targetLines,
    required this.maxLives,
    required this.boardColumns,
    required this.boardRows,
    required this.maxActivePieces,
    required this.spawnIntervalSeconds,
    required this.fallStepSeconds,
    required this.blockFillFactor,
    required this.contrastMultiplier,
  });

  final String name;
  final String description;

  final int targetLines;
  final int maxLives;

  final int boardColumns;
  final int boardRows;

  /// Cantidad máxima de piezas activas al tiempo.
  final int maxActivePieces;

  /// Cada cuánto puede aparecer una nueva ficha.
  /// En nivel 1 no se usa mucho porque solo hay una activa.
  final double spawnIntervalSeconds;

  /// Cada cuánto baja una pieza una fila.
  /// Menor valor = más rápido.
  final double fallStepSeconds;

  /// Qué tanto llena el bloque cada celda del tablero.
  /// Mayor valor = bloque más grande.
  final double blockFillFactor;

  /// Modifica la intensidad del rojo/verde según dificultad.
  final double contrastMultiplier;
}

extension BreakTheRowDifficultyConfig on BreakTheRowDifficulty {
  BreakTheRowLevelConfig get config {
    return switch (this) {
      BreakTheRowDifficulty.basic => const BreakTheRowLevelConfig(
        name: 'Nivel 1 — Básico',
        description: 'Piezas grandes · baja velocidad · una ficha a la vez',
        targetLines: 10,
        maxLives: 3,
        boardColumns: 6,
        boardRows: 12,
        maxActivePieces: 1,
        spawnIntervalSeconds: 999,
        fallStepSeconds: 0.85,
        blockFillFactor: 0.92,
        contrastMultiplier: 1.0,
      ),
      BreakTheRowDifficulty.medium => const BreakTheRowLevelConfig(
        name: 'Nivel 2 — Medio',
        description: 'Piezas medianas · aparece una nueva cada 4 segundos',
        targetLines: 15,
        maxLives: 3,
        boardColumns: 6,
        boardRows: 12,
        maxActivePieces: 2,
        spawnIntervalSeconds: 4.0,
        fallStepSeconds: 0.65,
        blockFillFactor: 0.82,
        contrastMultiplier: 0.82,
      ),
      BreakTheRowDifficulty.hard => const BreakTheRowLevelConfig(
        name: 'Nivel 3 — Difícil',
        description: 'Piezas pequeñas · aparece una nueva cada 2 segundos',
        targetLines: 25,
        maxLives: 3,
        boardColumns: 6,
        boardRows: 12,
        maxActivePieces: 3,
        spawnIntervalSeconds: 2.0,
        fallStepSeconds: 0.48,
        blockFillFactor: 0.72,
        contrastMultiplier: 0.65,
      ),
    };
  }
}
