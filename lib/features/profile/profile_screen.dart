import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/models/eye.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/app_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void showEditNameDialog(BuildContext context) {
    final appState = context.read<AppState>();
    final patient = appState.patient;

    if (patient == null) return;

    showDialog<String>(
      context: context,
      builder: (_) {
        return _EditNameDialog(initialName: patient.name);
      },
    ).then((newName) {
      if (newName == null) return;
      if (newName.trim().isEmpty) return;

      appState.setPatient(code: patient.code, name: newName, age: patient.age);
    });
  }

  void recalibrate(BuildContext context) {
    final appState = context.read<AppState>();

    appState.setCalibrationReturnRoute(AppRoutes.profile);
    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final patient = appState.patient;
    final redEye = appState.redLensEye?.label ?? 'No configurado';
    final greenEye = appState.greenLensEye?.label ?? 'No configurado';

    final redContrast = (appState.redContrast * 100).round();
    final greenContrast = (appState.greenContrast * 100).round();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            Text('Perfil', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Información del paciente y configuración visual.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Datos del paciente
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    patient?.name ?? 'Paciente',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    patient == null
                        ? 'Sin datos registrados'
                        : '${patient.code} · ${patient.age} años',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: patient == null
                          ? null
                          : () {
                              showEditNameDialog(context);
                            },
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'Editar nombre',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _SectionTitle(title: 'Configuración ocular'),
            const SizedBox(height: 14),
            _InfoCard(
              icon: Icons.visibility,
              title: 'Gafas rojo-verde',
              children: [
                _InfoRow(
                  color: AppColors.red,
                  label: 'Lente rojo',
                  value: redEye,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  color: AppColors.green,
                  label: 'Lente verde',
                  value: greenEye,
                ),
              ],
            ),

            const SizedBox(height: 18),

            _InfoCard(
              icon: appState.hasCompletedCalibration
                  ? Icons.check_circle
                  : Icons.warning_amber_rounded,
              iconColor: appState.hasCompletedCalibration
                  ? AppColors.green
                  : Colors.orange,
              title: 'Estado de calibración',
              children: [
                Text(
                  appState.hasCompletedCalibration
                      ? 'La calibración está completada.'
                      : 'La calibración aún no está completada.',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      recalibrate(context);
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text(
                      'Recalibrar gafas',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _InfoCard(
              icon: Icons.tune,
              title: 'Contraste actual',
              children: [
                _ContrastRow(
                  color: AppColors.red,
                  label: 'Rojo',
                  value: '$redContrast%',
                ),
                const SizedBox(height: 12),
                _ContrastRow(
                  color: AppColors.green,
                  label: 'Verde',
                  value: '$greenContrast%',
                ),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.cyan, size: 30),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Más adelante aquí podremos agregar historial de sesiones y resultados técnicos para el adulto responsable.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
    this.iconColor = AppColors.cyan,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label → $value',
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContrastRow extends StatelessWidget {
  const _ContrastRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void save() {
    final newName = controller.text.trim();

    if (newName.isEmpty) return;

    Navigator.of(context).pop(newName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar nombre'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nombre del paciente'),
        onSubmitted: (_) {
          save();
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: save, child: const Text('Guardar')),
      ],
    );
  }
}
