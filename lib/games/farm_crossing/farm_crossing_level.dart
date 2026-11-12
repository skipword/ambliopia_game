class FarmCrossingConfig {
  const FarmCrossingConfig({
    required this.name,
    required this.description,
    required this.laneCount,
    required this.targetCrossings,
    required this.vehicleSpeedMultiplier,
  });

  final String name;
  final String description;
  final int laneCount;
  final int targetCrossings;
  final double vehicleSpeedMultiplier;
}

enum FarmCrossingDifficulty { basic, intermediate, advanced }

extension FarmCrossingDifficultyConfig on FarmCrossingDifficulty {
  FarmCrossingConfig get config {
    switch (this) {
      case FarmCrossingDifficulty.basic:
        return const FarmCrossingConfig(
          name: 'Nivel 1',
          description: '3 carriles y vehículos lentos.',
          laneCount: 3,
          targetCrossings: 5,
          vehicleSpeedMultiplier: 1.0,
        );

      case FarmCrossingDifficulty.intermediate:
        return const FarmCrossingConfig(
          name: 'Nivel 2',
          description: '4 carriles y mayor movimiento.',
          laneCount: 4,
          targetCrossings: 5,
          vehicleSpeedMultiplier: 1.25,
        );

      case FarmCrossingDifficulty.advanced:
        return const FarmCrossingConfig(
          name: 'Nivel 3',
          description: '5 carriles y tráfico más rápido.',
          laneCount: 5,
          targetCrossings: 5,
          vehicleSpeedMultiplier: 1.5,
        );
    }
  }
}
