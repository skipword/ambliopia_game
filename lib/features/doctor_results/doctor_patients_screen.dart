import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'doctor_results_screen.dart';
import '../../app/app_theme.dart';
import '../../app/app_routes.dart';
import '../../core/state/app_state.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final patients = appState.doctorPatients;

    final normalizedQuery = searchQuery.trim().toLowerCase();

    final filteredPatients = patients.where((patient) {
      if (normalizedQuery.isEmpty) return true;

      return patient.name.toLowerCase().contains(normalizedQuery) ||
          patient.code.toLowerCase().contains(normalizedQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis pacientes'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
            },
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
        child: ListView(
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

            if (patients.isEmpty)
              const _EmptyPatientsCard()
            else if (filteredPatients.isEmpty)
              const _NoSearchResultsCard()
            else
              ...filteredPatients.map((patient) {
                final sessionsCount = appState.clinicalSessions
                    .where((session) => session.patientId == patient.code)
                    .length;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _PatientCard(
                    name: patient.name,
                    subtitle: '${patient.code} · ${patient.age} años',
                    sessionsCount: sessionsCount,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DoctorResultsScreen(patient: patient),
                        ),
                      );
                    },
                  ),
                );
              }),
          ],
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
                      '$sessionsCount partidas registradas',
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
