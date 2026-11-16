enum BalloonDifficulty { basic, medium, hard }

class BalloonLevelConfig {
  const BalloonLevelConfig({
    required this.name,
    required this.description,
    required this.spawnIntervalSeconds,
    required this.minSpeed,
    required this.maxSpeed,
    required this.maxActiveBalloons,
    required this.minSize,
    required this.maxSize,
  });

  final String name;
  final String description;

  final double spawnIntervalSeconds;

  final double minSpeed;
  final double maxSpeed;

  final int maxActiveBalloons;

  final double minSize;
  final double maxSize;

  static const double sessionDurationSeconds = 60;
}

extension BalloonDifficultyConfig on BalloonDifficulty {
  BalloonLevelConfig get config {
    switch (this) {
      case BalloonDifficulty.basic:
        return const BalloonLevelConfig(
          name: 'Nivel 1',
          description: 'Globos grandes y movimiento tranquilo.',
          spawnIntervalSeconds: 1.25,
          minSpeed: 65,
          maxSpeed: 85,
          maxActiveBalloons: 5,
          minSize: 72,
          maxSize: 88,
        );

      case BalloonDifficulty.medium:
        return const BalloonLevelConfig(
          name: 'Nivel 2',
          description: 'Aparecen más globos y se mueven un poco más rápido.',
          spawnIntervalSeconds: 1.00,
          minSpeed: 78,
          maxSpeed: 102,
          maxActiveBalloons: 7,
          minSize: 64,
          maxSize: 82,
        );

      case BalloonDifficulty.hard:
        return const BalloonLevelConfig(
          name: 'Nivel 3',
          description: 'Mayor cantidad de globos y velocidad.',
          spawnIntervalSeconds: 0.78,
          minSpeed: 92,
          maxSpeed: 120,
          maxActiveBalloons: 9,
          minSize: 58,
          maxSize: 76,
        );
    }
  }
}
