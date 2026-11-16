enum BalloonChannel { red, green }

enum BalloonEventResult { popped, escaped }

enum BalloonEndReason { manual, timeCompleted }

class BalloonEvent {
  const BalloonEvent({
    required this.id,
    required this.channel,
    required this.spawnedAtSeconds,
    required this.completedAtSeconds,
    required this.result,
    required this.reactionTimeMs,
  });

  final int id;
  final BalloonChannel channel;

  final double spawnedAtSeconds;
  final double completedAtSeconds;

  final BalloonEventResult result;

  final int? reactionTimeMs;
}

class BalloonStats {
  const BalloonStats({
    required this.redPopped,
    required this.greenPopped,
    required this.redEscaped,
    required this.greenEscaped,
  });

  factory BalloonStats.empty() {
    return const BalloonStats(
      redPopped: 0,
      greenPopped: 0,
      redEscaped: 0,
      greenEscaped: 0,
    );
  }

  final int redPopped;
  final int greenPopped;

  final int redEscaped;
  final int greenEscaped;

  int get popped => redPopped + greenPopped;

  int get escaped => redEscaped + greenEscaped;

  int get total => popped + escaped;

  int get redTotal => redPopped + redEscaped;

  int get greenTotal => greenPopped + greenEscaped;

  double get redAccuracy {
    if (redTotal == 0) return 0;

    return redPopped / redTotal;
  }

  double get greenAccuracy {
    if (greenTotal == 0) return 0;

    return greenPopped / greenTotal;
  }

  BalloonStats copyWith({
    int? redPopped,
    int? greenPopped,
    int? redEscaped,
    int? greenEscaped,
  }) {
    return BalloonStats(
      redPopped: redPopped ?? this.redPopped,
      greenPopped: greenPopped ?? this.greenPopped,
      redEscaped: redEscaped ?? this.redEscaped,
      greenEscaped: greenEscaped ?? this.greenEscaped,
    );
  }
}

class BalloonSessionResult {
  const BalloonSessionResult({
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.endReason,
    required this.stats,
    required this.events,
  });

  final DateTime startedAt;
  final DateTime endedAt;

  final double durationSeconds;

  final BalloonEndReason endReason;

  final BalloonStats stats;

  final List<BalloonEvent> events;

  double? get averageReactionTimeMs {
    final values = events
        .where(
          (event) =>
              event.result == BalloonEventResult.popped &&
              event.reactionTimeMs != null,
        )
        .map((event) => event.reactionTimeMs!)
        .toList();

    if (values.isEmpty) {
      return null;
    }

    final total = values.fold<int>(0, (sum, value) => sum + value);

    return total / values.length;
  }

  String get mainObservation {
    if (stats.redTotal < 3 || stats.greenTotal < 3) {
      return 'Aún no hay suficientes datos para comparar ambos canales.';
    }

    final difference = stats.redAccuracy - stats.greenAccuracy;

    if (difference.abs() < 0.15) {
      return 'El rendimiento entre los canales rojo y verde fue similar.';
    }

    if (difference < 0) {
      return 'El canal rojo presentó una menor proporción de globos explotados.';
    }

    return 'El canal verde presentó una menor proporción de globos explotados.';
  }
}
