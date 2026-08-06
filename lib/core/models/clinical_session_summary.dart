enum ClinicalGameType { pianoVisual, breakTheRow }

class ClinicalSessionSummary {
  const ClinicalSessionSummary({
    required this.id,
    required this.gameType,
    required this.gameName,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.score,
    required this.objectiveLabel,
    required this.completedObjective,
    required this.targetObjective,
    required this.redSuccess,
    required this.redErrors,
    required this.greenSuccess,
    required this.greenErrors,
    required this.eventsCount,
    required this.observation,
    this.averageReactionTimeMs,
  });

  final String id;
  final ClinicalGameType gameType;
  final String gameName;

  final DateTime startedAt;
  final DateTime endedAt;
  final double durationSeconds;

  final int score;

  final String objectiveLabel;
  final int completedObjective;
  final int targetObjective;

  final int redSuccess;
  final int redErrors;
  final int greenSuccess;
  final int greenErrors;

  final int eventsCount;
  final String observation;
  final double? averageReactionTimeMs;

  int get redTotal => redSuccess + redErrors;

  int get greenTotal => greenSuccess + greenErrors;

  int get totalActions => redTotal + greenTotal;

  double get redSuccessRate {
    if (redTotal == 0) return 0;
    return redSuccess / redTotal;
  }

  double get greenSuccessRate {
    if (greenTotal == 0) return 0;
    return greenSuccess / greenTotal;
  }

  double get performanceDifference {
    return (redSuccessRate - greenSuccessRate).abs();
  }

  bool get hasEnoughData {
    return redTotal >= 3 && greenTotal >= 3;
  }

  String get weakerStimulusLabel {
    if (!hasEnoughData) return 'Datos insuficientes';

    if (performanceDifference < 0.10) {
      return 'Rendimiento similar';
    }

    if (redSuccessRate < greenSuccessRate) {
      return 'Mayor dificultad en estímulo rojo';
    }

    return 'Mayor dificultad en estímulo verde';
  }
}
