import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/models/clinical_session_summary.dart';
import '../../core/models/patient.dart';
import '../../core/services/professional_supabase_service.dart';

class DoctorResultsScreen extends StatefulWidget {
  const DoctorResultsScreen({super.key, required this.patient});

  final Patient patient;

  @override
  State<DoctorResultsScreen> createState() => _DoctorResultsScreenState();
}

class _DoctorResultsScreenState extends State<DoctorResultsScreen> {
  final ProfessionalSupabaseService _service =
      ProfessionalSupabaseService.instance;

  bool isLoading = true;
  String? errorMessage;

  List<ClinicalSessionSummary> sessions = [];

  @override
  void initState() {
    super.initState();

    loadSessions();
  }

  Future<void> loadSessions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedSessions = await _service.getClinicalSessions(
        patientCode: widget.patient.code,
      );

      if (!mounted) return;

      setState(() {
        sessions = loadedSessions;
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Error cargando resultados profesionales: $error');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'No fue posible cargar los resultados. '
            'Verifica la conexión e inténtalo nuevamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final periodStart = DateTime(now.year, now.month - 3, now.day);

    final weeklyGroups = _buildWeeklyGroups(
      sessions: sessions,
      periodStart: periodStart,
      periodEnd: now,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados clínicos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: isLoading ? null : loadSessions,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadSessions,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            children: [
              _PatientHeader(
                patientName: widget.patient.name,
                patientSubtitle:
                    '${widget.patient.code} · '
                    '${widget.patient.age} años',
              ),

              const SizedBox(height: 20),

              _PeriodCard(startDate: periodStart, endDate: now),

              const SizedBox(height: 20),

              if (isLoading)
                const _LoadingResultsCard()
              else if (errorMessage != null)
                _ErrorResultsCard(message: errorMessage!, onRetry: loadSessions)
              else if (sessions.isEmpty)
                const _EmptyResultsCard()
              else ...[
                _GeneralSummaryCard(sessions: sessions),

                const SizedBox(height: 24),

                Text(
                  'Evolución semanal',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Información agrupada por semanas durante los últimos 3 meses.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                ...weeklyGroups.map(
                  (week) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _WeeklyClinicalCard(group: week),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<_WeeklyClinicalGroup> _buildWeeklyGroups({
    required List<ClinicalSessionSummary> sessions,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    final cleanPeriodStart = DateTime(
      periodStart.year,
      periodStart.month,
      periodStart.day,
    );

    final cleanPeriodEnd = DateTime(
      periodEnd.year,
      periodEnd.month,
      periodEnd.day,
    );

    final firstWeekStart = _startOfWeek(cleanPeriodStart);

    final lastWeekStart = _startOfWeek(cleanPeriodEnd);

    final result = <_WeeklyClinicalGroup>[];

    var currentWeekStart = lastWeekStart;

    while (!currentWeekStart.isBefore(firstWeekStart)) {
      final currentWeekEnd = currentWeekStart.add(const Duration(days: 6));

      final weekSessions = sessions.where((session) {
        final sessionDate = DateTime(
          session.startedAt.year,
          session.startedAt.month,
          session.startedAt.day,
        );

        return !sessionDate.isBefore(currentWeekStart) &&
            !sessionDate.isAfter(currentWeekEnd) &&
            !sessionDate.isBefore(cleanPeriodStart) &&
            !sessionDate.isAfter(cleanPeriodEnd);
      }).toList();

      result.add(
        _WeeklyClinicalGroup(
          startDate: currentWeekStart,
          endDate: currentWeekEnd,
          sessions: weekSessions,
        ),
      );

      currentWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    }

    return result;
  }

  DateTime _startOfWeek(DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);

    return cleanDate.subtract(
      Duration(days: cleanDate.weekday - DateTime.monday),
    );
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

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.startDate, required this.endDate});

  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.date_range_outlined, color: AppColors.cyan),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Periodo analizado',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${_formatLongDate(startDate)} - '
                  '${_formatLongDate(endDate)}',
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
      ),
    );
  }
}

class _GeneralSummaryCard extends StatelessWidget {
  const _GeneralSummaryCard({required this.sessions});

  final List<ClinicalSessionSummary> sessions;

  @override
  Widget build(BuildContext context) {
    final totalDuration = sessions.fold<double>(
      0,
      (sum, session) => sum + session.durationSeconds,
    );

    final games = sessions.map((session) => session.gameType).toSet().length;

    final activeDays = sessions
        .map(
          (session) => DateTime(
            session.startedAt.year,
            session.startedAt.month,
            session.startedAt.day,
          ),
        )
        .toSet()
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.sports_esports,
            label: 'Partidas registradas',
            value: '${sessions.length}',
          ),

          const SizedBox(height: 14),

          _SummaryRow(
            icon: Icons.calendar_month,
            label: 'Días con actividad',
            value: '$activeDays',
          ),

          const SizedBox(height: 14),

          _SummaryRow(
            icon: Icons.timer_outlined,
            label: 'Tiempo total',
            value: _formatDuration(totalDuration),
          ),

          const SizedBox(height: 14),

          _SummaryRow(
            icon: Icons.grid_view_rounded,
            label: 'Juegos utilizados',
            value: '$games de 5',
          ),
        ],
      ),
    );
  }
}

class _WeeklyClinicalCard extends StatelessWidget {
  const _WeeklyClinicalCard({required this.group});

  final _WeeklyClinicalGroup group;

  @override
  Widget build(BuildContext context) {
    if (!group.hasActivity) {
      return _EmptyWeekCard(group: group);
    }

    final gamesText = group.gamesCount.entries
        .map(
          (entry) =>
              '${entry.key} '
              '(${entry.value})',
        )
        .join(', ');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Text(
            _formatWeekRange(group.startDate, group.endDate),
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${group.activeDays} días con actividad · '
              '${group.playedRounds} partidas',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          children: [
            const Divider(),
            const SizedBox(height: 12),

            _SummaryRow(
              icon: Icons.event_available,
              label: 'Días con actividad',
              value: '${group.activeDays}',
            ),

            const SizedBox(height: 12),

            _SummaryRow(
              icon: Icons.sports_esports,
              label: 'Partidas realizadas',
              value: '${group.playedRounds}',
            ),

            const SizedBox(height: 12),

            _SummaryRow(
              icon: Icons.timer_outlined,
              label: 'Tiempo total de terapia',
              value: _formatDuration(group.totalDurationSeconds),
            ),

            const SizedBox(height: 12),

            _SummaryRow(
              icon: Icons.grid_view_rounded,
              label: 'Juegos utilizados',
              value: gamesText,
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Detalle por juego',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 12),

            ...group.gameGroups.map(
              (gameGroup) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WeeklyGameCard(group: gameGroup),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyGameCard extends StatelessWidget {
  const _WeeklyGameCard({required this.group});

  final _WeeklyGameGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.gameName,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          _DetailRow(label: 'Partidas', value: '${group.playedRounds}'),

          const SizedBox(height: 8),

          _DetailRow(
            label: 'Tiempo total',
            value: _formatDuration(group.totalDurationSeconds),
          ),

          const SizedBox(height: 8),

          _DetailRow(
            label: group.objectiveLabel,
            value:
                '${group.completedObjective}'
                '/'
                '${group.targetObjective}',
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),

          ..._buildGameMetrics(),

          if (group.averageReactionTimeMs != null) ...[
            const SizedBox(height: 10),
            _DetailRow(
              label: 'Reacción promedio',
              value: '${group.averageReactionTimeMs!.round()} ms',
            ),
          ],

          if (group.observation.isNotEmpty) ...[
            const SizedBox(height: 14),
            _ObservationBox(text: group.observation),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildGameMetrics() {
    switch (group.gameType) {
      case ClinicalGameType.pianoVisual:
        return [
          const Text(
            'Piano Visual',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: 'Aciertos rojo', value: '${group.redSuccess}'),
          const SizedBox(height: 8),
          _DetailRow(label: 'Errores rojo', value: '${group.redErrors}'),
          const SizedBox(height: 8),
          _DetailRow(label: 'Aciertos verde', value: '${group.greenSuccess}'),
          const SizedBox(height: 8),
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
        ];

      case ClinicalGameType.breakTheRow:
        return [
          const Text(
            'Rompe la Fila',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Piezas rojas correctas',
            value: '${group.redSuccess}',
          ),
          const SizedBox(height: 8),
          _DetailRow(
            label: 'Errores piezas rojas',
            value: '${group.redErrors}',
          ),
          const SizedBox(height: 8),
          _DetailRow(
            label: 'Piezas verdes correctas',
            value: '${group.greenSuccess}',
          ),
          const SizedBox(height: 8),
          _DetailRow(
            label: 'Errores piezas verdes',
            value: '${group.greenErrors}',
          ),
          const SizedBox(height: 14),
          _AccuracyBar(
            label: 'Éxito estímulo rojo',
            value: group.redAccuracy,
            color: AppColors.red,
          ),
          const SizedBox(height: 12),
          _AccuracyBar(
            label: 'Éxito estímulo verde',
            value: group.greenAccuracy,
            color: AppColors.green,
          ),
        ];

      case ClinicalGameType.farmCrossing:
        return [
          const Text(
            'Cruza la Granja',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Objetivos recogidos',
            value: '${group.redSuccess}',
          ),
          const SizedBox(height: 8),
          _DetailRow(label: 'Objetivos perdidos', value: '${group.redErrors}'),
          const SizedBox(height: 8),
          _DetailRow(
            label: 'Carriles cruzados',
            value: '${group.greenSuccess}',
          ),
          const SizedBox(height: 8),
          _DetailRow(label: 'Colisiones', value: '${group.greenErrors}'),
        ];

      case ClinicalGameType.balloonPop:
        return [
          const Text(
            'Explota los Globos',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),

          _DetailRow(
            label: 'Globos rojos explotados',
            value: '${group.redSuccess}',
          ),

          const SizedBox(height: 8),

          _DetailRow(
            label: 'Globos rojos escapados',
            value: '${group.redErrors}',
          ),

          const SizedBox(height: 8),

          _DetailRow(
            label: 'Globos verdes explotados',
            value: '${group.greenSuccess}',
          ),

          const SizedBox(height: 8),

          _DetailRow(
            label: 'Globos verdes escapados',
            value: '${group.greenErrors}',
          ),

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
        ];

      case ClinicalGameType.roadVisual:
        return [
          const Text(
            'Ruta Visual',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          _DetailRow(
            label: 'Objetivos rojos recogidos',
            value: '${group.redSuccess}',
          ),

          const SizedBox(height: 8),

          _DetailRow(
            label: 'Objetivos rojos perdidos',
            value: '${group.redErrors}',
          ),

          const SizedBox(height: 8),

          _DetailRow(
            label: 'Vehículos verdes evitados',
            value: '${group.greenSuccess}',
          ),

          const SizedBox(height: 8),

          _DetailRow(label: 'Colisiones', value: '${group.greenErrors}'),

          const SizedBox(height: 14),

          _AccuracyBar(
            label: 'Éxito estímulo rojo',
            value: group.redAccuracy,
            color: AppColors.red,
          ),

          const SizedBox(height: 12),

          _AccuracyBar(
            label: 'Éxito estímulo verde',
            value: group.greenAccuracy,
            color: AppColors.green,
          ),
        ];
    }
  }
}

class _WeeklyClinicalGroup {
  const _WeeklyClinicalGroup({
    required this.startDate,
    required this.endDate,
    required this.sessions,
  });

  final DateTime startDate;
  final DateTime endDate;

  final List<ClinicalSessionSummary> sessions;

  bool get hasActivity => sessions.isNotEmpty;

  int get playedRounds => sessions.length;

  int get activeDays {
    return sessions
        .map(
          (session) => DateTime(
            session.startedAt.year,
            session.startedAt.month,
            session.startedAt.day,
          ),
        )
        .toSet()
        .length;
  }

  double get totalDurationSeconds {
    return sessions.fold<double>(
      0,
      (sum, session) => sum + session.durationSeconds,
    );
  }

  Map<String, int> get gamesCount {
    final result = <String, int>{};

    for (final session in sessions) {
      result.update(session.gameName, (value) => value + 1, ifAbsent: () => 1);
    }

    return result;
  }

  List<_WeeklyGameGroup> get gameGroups {
    final groups = <ClinicalGameType, List<ClinicalSessionSummary>>{};

    for (final session in sessions) {
      groups.putIfAbsent(session.gameType, () => []);

      groups[session.gameType]!.add(session);
    }

    final result = groups.entries.map((entry) {
      return _WeeklyGameGroup(gameType: entry.key, sessions: entry.value);
    }).toList();

    result.sort((a, b) => a.gameName.compareTo(b.gameName));

    return result;
  }
}

class _WeeklyGameGroup {
  const _WeeklyGameGroup({required this.gameType, required this.sessions});

  final ClinicalGameType gameType;

  final List<ClinicalSessionSummary> sessions;

  String get gameName {
    if (sessions.isEmpty) {
      return '';
    }

    return sessions.first.gameName;
  }

  int get playedRounds => sessions.length;

  double get totalDurationSeconds {
    return sessions.fold<double>(
      0,
      (sum, session) => sum + session.durationSeconds,
    );
  }

  String get objectiveLabel {
    if (sessions.isEmpty) {
      return 'Objetivo';
    }

    return sessions.first.objectiveLabel;
  }

  int get completedObjective {
    return sessions.fold<int>(
      0,
      (sum, session) => sum + session.completedObjective,
    );
  }

  int get targetObjective {
    return sessions.fold<int>(
      0,
      (sum, session) => sum + session.targetObjective,
    );
  }

  int get redSuccess {
    return sessions.fold<int>(0, (sum, session) => sum + session.redSuccess);
  }

  int get redErrors {
    return sessions.fold<int>(0, (sum, session) => sum + session.redErrors);
  }

  int get greenSuccess {
    return sessions.fold<int>(0, (sum, session) => sum + session.greenSuccess);
  }

  int get greenErrors {
    return sessions.fold<int>(0, (sum, session) => sum + session.greenErrors);
  }

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

  double? get averageReactionTimeMs {
    final reactionTimes = sessions
        .map((session) => session.averageReactionTimeMs)
        .whereType<double>()
        .toList();

    if (reactionTimes.isEmpty) {
      return null;
    }

    final total = reactionTimes.fold<double>(0, (sum, value) => sum + value);

    return total / reactionTimes.length;
  }

  String get observation {
    if (sessions.isEmpty) {
      return '';
    }

    for (final session in sessions) {
      if (session.observation.trim().isNotEmpty) {
        return session.observation;
      }
    }

    return '';
  }
}

class _LoadingResultsCard extends StatelessWidget {
  const _LoadingResultsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Cargando resultados...',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorResultsCard extends StatelessWidget {
  const _ErrorResultsCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppColors.red, size: 52),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
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

class _EmptyWeekCard extends StatelessWidget {
  const _EmptyWeekCard({required this.group});

  final _WeeklyClinicalGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.remove_circle_outline, color: AppColors.textMuted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatWeekRange(group.startDate, group.endDate),
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sin actividad registrada',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
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
          width: 170,
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
          const Icon(Icons.visibility_outlined, color: Colors.orange),
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

String _formatWeekRange(DateTime start, DateTime end) {
  if (start.month == end.month) {
    return 'Semana '
        '${start.day} - '
        '${end.day} '
        '${_monthName(end.month)}';
  }

  return 'Semana '
      '${start.day} '
      '${_monthName(start.month)} - '
      '${end.day} '
      '${_monthName(end.month)}';
}

String _formatLongDate(DateTime date) {
  return '${date.day} '
      '${_monthName(date.month)} '
      '${date.year}';
}

String _monthName(int month) {
  const months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  return months[month - 1];
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
