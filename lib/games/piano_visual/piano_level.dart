enum PianoDifficulty { basic, medium, hard }

class PianoLevelConfig {
  const PianoLevelConfig({
    required this.name,
    required this.description,
    required this.tileWidthFactor,
    required this.contrastMultiplier,
    required this.holdTileProbability,
    required this.requiredHoldSeconds,
  });

  final String name;
  final String description;

  /// Qué tan ancha es la ficha dentro del carril.
  /// 1.0 ocupa casi todo el carril.
  /// Valores bajos obligan a tocar con más precisión.
  final double tileWidthFactor;

  /// Multiplicador del contraste configurado en calibración.
  /// Más alto = más visible.
  final double contrastMultiplier;

  /// Probabilidad de que aparezca una ficha larga.
  final double holdTileProbability;

  /// Tiempo que debe mantenerse presionada una ficha larga.
  final double requiredHoldSeconds;
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
        requiredHoldSeconds: 0.50,
      ),
      PianoDifficulty.medium => const PianoLevelConfig(
        name: 'Nivel 2 — Medio',
        description: 'Fichas medianas · contraste medio',
        tileWidthFactor: 0.58,
        contrastMultiplier: 0.80,
        holdTileProbability: 0.22,
        requiredHoldSeconds: 0.70,
      ),
      PianoDifficulty.hard => const PianoLevelConfig(
        name: 'Nivel 3 — Difícil',
        description: 'Fichas delgadas · menor contraste',
        tileWidthFactor: 0.36,
        contrastMultiplier: 0.62,
        holdTileProbability: 0.35,
        requiredHoldSeconds: 0.90,
      ),
    };
  }
}
