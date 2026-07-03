import 'dart:math';

enum PianoDifficulty { basic, medium, hard }

class PianoLevelConfig {
  const PianoLevelConfig({
    required this.name,
    required this.description,
    required this.tileWidthFactor,
    required this.contrastMultiplier,
    required this.holdTileProbability,
    required this.minHoldSeconds,
    required this.maxHoldSeconds,
  });

  final String name;
  final String description;

  /// Qué tan ancha es la ficha dentro del carril.
  /// 1.0 ocupa casi todo el carril.
  /// Valores bajos obligan a tocar con más precisión.
  final double tileWidthFactor;

  /// Multiplicador del contraste configurado en calibración.
  final double contrastMultiplier;

  /// Probabilidad de que aparezca una ficha larga.
  final double holdTileProbability;

  /// Duración mínima de una ficha de mantener.
  final double minHoldSeconds;

  /// Duración máxima de una ficha de mantener.
  final double maxHoldSeconds;

  double randomHoldSeconds(Random random) {
    return minHoldSeconds +
        random.nextDouble() * (maxHoldSeconds - minHoldSeconds);
  }
}

extension PianoDifficultyConfig on PianoDifficulty {
  PianoLevelConfig get config {
    return switch (this) {
      PianoDifficulty.basic => const PianoLevelConfig(
        name: 'Nivel 1 — Básico',
        description: 'Fichas anchas · alto contraste',
        tileWidthFactor: 0.88,
        contrastMultiplier: 1.0,
        holdTileProbability: 0.10,
        minHoldSeconds: 0.45,
        maxHoldSeconds: 0.75,
      ),
      PianoDifficulty.medium => const PianoLevelConfig(
        name: 'Nivel 2 — Medio',
        description: 'Fichas medianas · contraste medio',
        tileWidthFactor: 0.58,
        contrastMultiplier: 0.80,
        holdTileProbability: 0.22,
        minHoldSeconds: 0.65,
        maxHoldSeconds: 1.05,
      ),
      PianoDifficulty.hard => const PianoLevelConfig(
        name: 'Nivel 3 — Difícil',
        description: 'Fichas delgadas · menor contraste',
        tileWidthFactor: 0.36,
        contrastMultiplier: 0.62,
        holdTileProbability: 0.35,
        minHoldSeconds: 0.85,
        maxHoldSeconds: 1.35,
      ),
    };
  }
}
