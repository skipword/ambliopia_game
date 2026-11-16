enum RoadVisualDifficulty { basic, medium, hard }

class RoadVisualLevelConfig {
  const RoadVisualLevelConfig({
    required this.name,
    required this.description,
    required this.laneCount,
    required this.baseSpeed,
    required this.obstacleSpawnInterval,
    required this.objectiveSpawnInterval,
    required this.maxActiveObstacles,
    required this.maxActiveObjectives,
  });

  final String name;
  final String description;

  final int laneCount;

  final double baseSpeed;

  final double obstacleSpawnInterval;
  final double objectiveSpawnInterval;

  final int maxActiveObstacles;
  final int maxActiveObjectives;

  static const double sessionDurationSeconds = 60;
  static const int maxLives = 3;
}

extension RoadVisualDifficultyConfig on RoadVisualDifficulty {
  RoadVisualLevelConfig get config {
    switch (this) {
      case RoadVisualDifficulty.basic:
        return const RoadVisualLevelConfig(
          name: 'Nivel 1',
          description:
              'Tres carriles, vehículos espaciados y velocidad tranquila.',
          laneCount: 3,
          baseSpeed: 125,
          obstacleSpawnInterval: 1.45,
          objectiveSpawnInterval: 2.30,
          maxActiveObstacles: 3,
          maxActiveObjectives: 1,
        );

      case RoadVisualDifficulty.medium:
        return const RoadVisualLevelConfig(
          name: 'Nivel 2',
          description: 'Cuatro carriles, más vehículos y mayor velocidad.',
          laneCount: 4,
          baseSpeed: 150,
          obstacleSpawnInterval: 1.15,
          objectiveSpawnInterval: 2.00,
          maxActiveObstacles: 4,
          maxActiveObjectives: 2,
        );

      case RoadVisualDifficulty.hard:
        return const RoadVisualLevelConfig(
          name: 'Nivel 3',
          description: 'Cinco carriles, tráfico frecuente y velocidad elevada.',
          laneCount: 5,
          baseSpeed: 175,
          obstacleSpawnInterval: 0.90,
          objectiveSpawnInterval: 1.70,
          maxActiveObstacles: 5,
          maxActiveObjectives: 2,
        );
    }
  }
}
