enum VisualChannel { red, green }

enum StimulusResult { hit, miss }

class PianoStimulusEvent {
  const PianoStimulusEvent({
    required this.id,
    required this.channel,
    required this.laneIndex,
    required this.createdAtSeconds,
    required this.completedAtSeconds,
    required this.result,
    required this.reactionTimeMs,
  });

  final int id;
  final VisualChannel channel;
  final int laneIndex;
  final double createdAtSeconds;
  final double completedAtSeconds;
  final StimulusResult result;
  final int? reactionTimeMs;
}

class PianoStats {
  const PianoStats({
    required this.hits,
    required this.misses,
    required this.redHits,
    required this.greenHits,
    required this.redMisses,
    required this.greenMisses,
  });

  factory PianoStats.empty() {
    return const PianoStats(
      hits: 0,
      misses: 0,
      redHits: 0,
      greenHits: 0,
      redMisses: 0,
      greenMisses: 0,
    );
  }

  final int hits;
  final int misses;
  final int redHits;
  final int greenHits;
  final int redMisses;
  final int greenMisses;

  int get total => hits + misses;

  int get redTotal => redHits + redMisses;

  int get greenTotal => greenHits + greenMisses;

  double get redAccuracy {
    if (redTotal == 0) return 0;
    return redHits / redTotal;
  }

  double get greenAccuracy {
    if (greenTotal == 0) return 0;
    return greenHits / greenTotal;
  }

  PianoStats copyWith({
    int? hits,
    int? misses,
    int? redHits,
    int? greenHits,
    int? redMisses,
    int? greenMisses,
  }) {
    return PianoStats(
      hits: hits ?? this.hits,
      misses: misses ?? this.misses,
      redHits: redHits ?? this.redHits,
      greenHits: greenHits ?? this.greenHits,
      redMisses: redMisses ?? this.redMisses,
      greenMisses: greenMisses ?? this.greenMisses,
    );
  }
}

class PianoSessionResult {
  const PianoSessionResult({
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.stats,
    required this.events,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final double durationSeconds;
  final PianoStats stats;
  final List<PianoStimulusEvent> events;

  double? get averageReactionTimeMs {
    final reactionTimes = events
        .where((event) => event.reactionTimeMs != null)
        .map((event) => event.reactionTimeMs!)
        .toList();

    if (reactionTimes.isEmpty) return null;

    final sum = reactionTimes.reduce((a, b) => a + b);
    return sum / reactionTimes.length;
  }

  String get mainObservation {
    if (stats.redTotal == 0 || stats.greenTotal == 0) {
      return 'Aún no hay suficientes datos para comparar ambos canales.';
    }

    final redDifference = stats.greenAccuracy - stats.redAccuracy;
    final greenDifference = stats.redAccuracy - stats.greenAccuracy;

    if (redDifference > 0.15) {
      return 'El canal rojo tuvo menor precisión durante esta sesión.';
    }

    if (greenDifference > 0.15) {
      return 'El canal verde tuvo menor precisión durante esta sesión.';
    }

    return 'El rendimiento entre los canales rojo y verde fue similar.';
  }
}
