import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../core/models/clinical_session_summary.dart';
import '../../core/state/app_state.dart';

class DoctorResultsScreen extends StatelessWidget {
  const DoctorResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sessions = appState.clinicalSessions;
    final groupedSessions = _groupSessionsByDateAndGame(sessions);
    final weeklySummary = _buildWeeklySummary(sessions);

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados clínicos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          children: [
            _PatientHeader(
              patientName: appState.patient?.name ?? 'Paciente sin registrar',
              patientSubtitle: appState.patientSubtitle,
            ),
            const SizedBox(height: 20),
            if (sessions.isEmpty)
              const _EmptyResultsCard()
            else ...[
              _WeeklySummaryCard(summary: weeklySummary),
              const SizedBox(height: 20),
              Text(
                'Detalle por juego',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ...groupedSessions.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _GameSessionCard(group: group),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<_GroupedGameSession> _groupSessionsByDateAndGame(
    List<ClinicalSessionSummary> sessions,
  ) {
    final groups = <String, _GroupedGameSession>{};

    for (final session in sessions) {
      final dateKey = _dateKey(session.startedAt);
      final key = '$dateKey-${session.gameName}';

      final current = groups[key];

      if (current == null) {
        groups[key] = _GroupedGameSession(
          date: DateTime(
            session.startedAt.year,
            session.startedAt.month,
            session.startedAt.day,
          ),
          gameName: session.gameName,
          totalDurationSeconds: session.durationSeconds,
          playedRounds: 1,
          redSuccess: session.redSuccess,
          redErrors: session.redErrors,
          greenSuccess: session.greenSuccess,
          greenErrors: session.greenErrors,
          averageReactionTimeMs: session.averageReactionTimeMs,
          observation: session.observation,
        );
      } else {
        final currentReaction = current.averageReactionTimeMs;
        final newReaction = session.averageReactionTimeMs;

        double? averageReaction;

        if (currentReaction == null && newReaction == null) {
          averageReaction = null;
        } else if (currentReaction == null) {
          averageReaction = newReaction;
        } else if (newReaction == null) {
          averageReaction = currentReaction;
        } else {
          averageReaction =
              ((currentReaction * current.playedRounds) + newReaction) /
              (current.playedRounds + 1);
        }

        groups[key] = current.copyWith(
          totalDurationSeconds:
              current.totalDurationSeconds + session.durationSeconds,
          playedRounds: current.playedRounds + 1,
          redSuccess: current.redSuccess + session.redSuccess,
          redErrors: current.redErrors + session.redErrors,
          greenSuccess: current.greenSuccess + session.greenSuccess,
          greenErrors: current.greenErrors + session.greenErrors,
          averageReactionTimeMs: averageReaction,
          observation: session.observation,
        );
      }
    }

    final result = groups.values.toList();

    result.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return a.gameName.compareTo(b.gameName);
    });

    return result;
  }

  _WeeklySummary _buildWeeklySummary(List<ClinicalSessionSummary> sessions) {
    final now = DateTime.now();

    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final weekSessions = sessions.where((session) {
      return session.startedAt.isAfter(
            startOfWeek.subtract(const Duration(seconds: 1)),
          ) &&
          session.startedAt.isBefore(endOfWeek);
    }).toList();

    final groupedByDay = <String>{};

    for (final session in weekSessions) {
      groupedByDay.add(_dateKey(session.startedAt));
    }

    final totalSeconds = weekSessions.fold<double>(
      0,
      (sum, session) => sum + session.durationSeconds,
    );

    final gamesCount = <String, int>{};

    for (final session in weekSessions) {
      gamesCount.update(
        session.gameName,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    final therapySessionsCount = groupedByDay.length;
    final averageSeconds = therapySessionsCount == 0
        ? 0.0
        : totalSeconds / therapySessionsCount;

    return _WeeklySummary(
      therapySessionsCount: therapySessionsCount,
      totalDurationSeconds: totalSeconds,
      averageDurationSeconds: averageSeconds,
      gamesCount: gamesCount,
    );
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({
    required this.patientName,
    required this.patientSubtitle,
  });

  final String patientName;
  final String patientSubtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.monitor_heart_outlined,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  patientSubtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.summary});

  final _WeeklySummary summary;

  @override
  Widget build(BuildContext context) {
    final gamesText = summary.gamesCount.entries
        .map((entry) {
          return '${entry.key} (${entry.value} partidas)';
        })
        .join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de la semana',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _SummaryRow(
            icon: Icons.event_available,
            label: 'Sesiones realizadas',
            value: '${summary.therapySessionsCount}',
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.timer,
            label: 'Tiempo total de terapia',
            value: _formatDuration(summary.totalDurationSeconds),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.av_timer,
            label: 'Tiempo promedio por sesión',
            value: _formatDuration(summary.averageDurationSeconds),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.sports_esports,
            label: 'Juegos utilizados',
            value: gamesText.isEmpty ? 'Sin datos' : gamesText,
          ),
        ],
      ),
    );
  }
}

class _GameSessionCard extends StatelessWidget {
  const _GameSessionCard({required this.group});

  final _GroupedGameSession group;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(label: 'Fecha', value: _formatDate(group.date)),
          const SizedBox(height: 12),
          _DetailRow(label: 'Juego', value: group.gameName),
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Tiempo de la sesión',
            value: _formatDuration(group.totalDurationSeconds),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Partidas realizadas',
            value: '${group.playedRounds}',
          ),
          if (group.hasPianoStats) ...[
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Estadísticas de Piano Visual',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            _DetailRow(label: 'Aciertos rojo', value: '${group.redSuccess}'),
            const SizedBox(height: 10),
            _DetailRow(label: 'Errores rojo', value: '${group.redErrors}'),
            const SizedBox(height: 10),
            _DetailRow(label: 'Aciertos verde', value: '${group.greenSuccess}'),
            const SizedBox(height: 10),
            _DetailRow(label: 'Errores verde', value: '${group.greenErrors}'),
            const SizedBox(height: 14),
            _AccuracyBar(
              label: 'Precisión estímulo rojo',
              value: group.redAccuracy,
              color: AppColors.red,
            ),
            const SizedBox(height: 12),
            _AccuracyBar(
              label: 'Precisión estímulo verde',
              value: group.greenAccuracy,
              color: AppColors.green,
            ),
            if (group.averageReactionTimeMs != null) ...[
              const SizedBox(height: 14),
              _DetailRow(
                label: 'Reacción promedio',
                value: '${group.averageReactionTimeMs!.round()} ms',
              ),
            ],
            const SizedBox(height: 14),
            _ObservationBox(text: group.observation),
          ],
        ],
      ),
    );
  }
}

class _EmptyResultsCard extends StatelessWidget {
  const _EmptyResultsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Column(
        children: [
          Icon(Icons.analytics_outlined, color: AppColors.cyan, size: 64),
          SizedBox(height: 16),
          Text(
            'Aún no hay sesiones registradas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Cuando el paciente complete una actividad, aquí aparecerá el resumen para revisión del profesional.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.cyan, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 145,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccuracyBar extends StatelessWidget {
  const _AccuracyBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: const Color(0xFFE5E7EB),
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ObservationBox extends StatelessWidget {
  const _ObservationBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.visibility_outlined, color: Colors.orange, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupedGameSession {
  const _GroupedGameSession({
    required this.date,
    required this.gameName,
    required this.totalDurationSeconds,
    required this.playedRounds,
    required this.redSuccess,
    required this.redErrors,
    required this.greenSuccess,
    required this.greenErrors,
    required this.averageReactionTimeMs,
    required this.observation,
  });

  final DateTime date;
  final String gameName;
  final double totalDurationSeconds;
  final int playedRounds;

  final int redSuccess;
  final int redErrors;
  final int greenSuccess;
  final int greenErrors;

  final double? averageReactionTimeMs;
  final String observation;

  int get redTotal => redSuccess + redErrors;

  int get greenTotal => greenSuccess + greenErrors;

  double get redAccuracy {
    if (redTotal == 0) return 0;
    return redSuccess / redTotal;
  }

  double get greenAccuracy {
    if (greenTotal == 0) return 0;
    return greenSuccess / greenTotal;
  }

  bool get hasPianoStats {
    return gameName == 'Piano Visual';
  }

  _GroupedGameSession copyWith({
    double? totalDurationSeconds,
    int? playedRounds,
    int? redSuccess,
    int? redErrors,
    int? greenSuccess,
    int? greenErrors,
    double? averageReactionTimeMs,
    String? observation,
  }) {
    return _GroupedGameSession(
      date: date,
      gameName: gameName,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      playedRounds: playedRounds ?? this.playedRounds,
      redSuccess: redSuccess ?? this.redSuccess,
      redErrors: redErrors ?? this.redErrors,
      greenSuccess: greenSuccess ?? this.greenSuccess,
      greenErrors: greenErrors ?? this.greenErrors,
      averageReactionTimeMs:
          averageReactionTimeMs ?? this.averageReactionTimeMs,
      observation: observation ?? this.observation,
    );
  }
}

class _WeeklySummary {
  const _WeeklySummary({
    required this.therapySessionsCount,
    required this.totalDurationSeconds,
    required this.averageDurationSeconds,
    required this.gamesCount,
  });

  final int therapySessionsCount;
  final double totalDurationSeconds;
  final double averageDurationSeconds;
  final Map<String, int> gamesCount;
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day/$month/$year';
}

String _formatDuration(double seconds) {
  final totalMinutes = (seconds / 60).round();

  if (totalMinutes <= 0) {
    return '< 1 min';
  }

  if (totalMinutes < 60) {
    return '$totalMinutes min';
  }

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  if (minutes == 0) {
    return '$hours h';
  }

  return '$hours h $minutes min';
}
