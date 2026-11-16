import 'road_visual_level.dart';

enum RoadVisualEventType {
  objectiveCollected,
  objectiveMissed,
  obstacleAvoided,
  collision,
}

enum RoadVisualEndReason { manual, timeCompleted, livesLost }

class RoadVisualEvent {
  const RoadVisualEvent({
    required this.id,
    required this.type,
    required this.laneIndex,
    required this.spawnedAtSeconds,
    required this.resolvedAtSeconds,
  });

  final int id;
  final RoadVisualEventType type;
  final int laneIndex;

  final double spawnedAtSeconds;
  final double resolvedAtSeconds;
}

class RoadVisualStats {
  const RoadVisualStats({
    required this.objectivesCollected,
    required this.objectivesMissed,
    required this.obstaclesAvoided,
    required this.collisions,
    required this.laneChanges,
  });

  factory RoadVisualStats.empty() {
    return const RoadVisualStats(
      objectivesCollected: 0,
      objectivesMissed: 0,
      obstaclesAvoided: 0,
      collisions: 0,
      laneChanges: 0,
    );
  }

  final int objectivesCollected;
  final int objectivesMissed;

  final int obstaclesAvoided;
  final int collisions;

  final int laneChanges;

  int get redTotal => objectivesCollected + objectivesMissed;

  int get greenTotal => obstaclesAvoided + collisions;

  int get totalEvents => redTotal + greenTotal;

  double get redAccuracy {
    if (redTotal == 0) {
      return 0;
    }

    return objectivesCollected / redTotal;
  }

  double get greenAccuracy {
    if (greenTotal == 0) {
      return 0;
    }

    return obstaclesAvoided / greenTotal;
  }

  RoadVisualStats copyWith({
    int? objectivesCollected,
    int? objectivesMissed,
    int? obstaclesAvoided,
    int? collisions,
    int? laneChanges,
  }) {
    return RoadVisualStats(
      objectivesCollected: objectivesCollected ?? this.objectivesCollected,
      objectivesMissed: objectivesMissed ?? this.objectivesMissed,
      obstaclesAvoided: obstaclesAvoided ?? this.obstaclesAvoided,
      collisions: collisions ?? this.collisions,
      laneChanges: laneChanges ?? this.laneChanges,
    );
  }
}

class RoadVisualSessionResult {
  const RoadVisualSessionResult({
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.difficulty,
    required this.endReason,
    required this.stats,
    required this.events,
  });

  final DateTime startedAt;
  final DateTime endedAt;

  final double durationSeconds;

  final RoadVisualDifficulty difficulty;
  final RoadVisualEndReason endReason;

  final RoadVisualStats stats;

  final List<RoadVisualEvent> events;

  int get score {
    final rawScore =
        stats.objectivesCollected * 100 +
        stats.obstaclesAvoided * 20 -
        stats.collisions * 50;

    if (rawScore < 0) {
      return 0;
    }

    return rawScore;
  }

  String get endReasonLabel {
    switch (endReason) {
      case RoadVisualEndReason.manual:
        return 'Sesión finalizada manualmente';

      case RoadVisualEndReason.timeCompleted:
        return 'Tiempo completado';

      case RoadVisualEndReason.livesLost:
        return 'Se agotaron las vidas';
    }
  }

  String get mainObservation {
    if (stats.redTotal < 3 || stats.greenTotal < 3) {
      return 'Aún no hay suficientes datos para comparar ambos canales.';
    }

    final difference = stats.redAccuracy - stats.greenAccuracy;

    if (difference.abs() < 0.15) {
      return 'El rendimiento entre los estímulos rojo y verde fue similar.';
    }

    if (difference < 0) {
      return 'Se observó una menor proporción de objetivos rojos recogidos.';
    }

    return 'Se observó una mayor dificultad para evitar los vehículos verdes.';
  }
}
