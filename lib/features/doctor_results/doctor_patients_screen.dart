import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/models/clinical_session_summary.dart';
import '../../core/models/patient.dart';
import '../../core/services/professional_supabase_service.dart';
import 'doctor_results_screen.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  final ProfessionalSupabaseService _service =
      ProfessionalSupabaseService.instance;

  String searchQuery = '';

  bool isLoading = true;
  String? errorMessage;

  List<Patient> patients = [];
  List<ClinicalSessionSummary> sessions = [];

  @override
  void initState() {
    super.initState();

    loadPatients();
  }

  Future<void> loadPatients() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedPatients = await _service.getPatients();

      final loadedSessions = await _service.getClinicalSessions();

      if (!mounted) return;

      setState(() {
        patients = loadedPatients;
        sessions = loadedSessions;
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Error cargando panel profesional: $error');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'No fue posible cargar los pacientes. '
            'Verifica la conexión e inténtalo nuevamente.';
      });
    }
  }

  int sessionsForPatient(String patientCode) {
    return sessions.where((session) => session.patientId == patientCode).length;
  }

  Future<void> signOut() async {
    await _service.signOut();

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = searchQuery.trim().toLowerCase();

    final filteredPatients = patients.where((patient) {
      if (normalizedQuery.isEmpty) {
        return true;
      }

      return patient.name.toLowerCase().contains(normalizedQuery) ||
          patient.code.toLowerCase().contains(normalizedQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis pacientes'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: isLoading ? null : loadPatients,
            icon: const Icon(Icons.refresh_rounded),
          ),
          TextButton.icon(
            onPressed: isLoading ? null : signOut,
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              'Salir',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadPatients,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            children: [
              Text(
                'Panel profesional',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecciona un paciente para consultar su evolución clínica.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o código',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (isLoading)
                const _LoadingPatientsCard()
              else if (errorMessage != null)
                _ErrorPatientsCard(
                  message: errorMessage!,
                  onRetry: loadPatients,
                )
              else if (patients.isEmpty)
                const _EmptyPatientsCard()
              else if (filteredPatients.isEmpty)
                const _NoSearchResultsCard()
              else
                ...filteredPatients.map((patient) {
                  final sessionsCount = sessionsForPatient(patient.code);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _PatientCard(
                      name: patient.name,
                      subtitle:
                          '${patient.code} · '
                          '${patient.age} años',
                      sessionsCount: sessionsCount,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                DoctorResultsScreen(patient: patient),
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({
    required this.name,
    required this.subtitle,
    required this.sessionsCount,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final int sessionsCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.cyan,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$sessionsCount '
                      '${sessionsCount == 1 ? 'partida registrada' : 'partidas registradas'}',
                      style: const TextStyle(
                        color: AppColors.cyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingPatientsCard extends StatelessWidget {
  const _LoadingPatientsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            'Cargando pacientes...',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPatientsCard extends StatelessWidget {
  const _ErrorPatientsCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              fontSize: 15,
              height: 1.4,
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

class _EmptyPatientsCard extends StatelessWidget {
  const _EmptyPatientsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(Icons.people_outline_rounded, color: AppColors.cyan, size: 56),
          SizedBox(height: 14),
          Text(
            'No hay pacientes registrados',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cuando exista un paciente registrado aparecerá en esta sección.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSearchResultsCard extends StatelessWidget {
  const _NoSearchResultsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 48),
          SizedBox(height: 12),
          Text(
            'No se encontraron pacientes',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Prueba con otro nombre o código.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
