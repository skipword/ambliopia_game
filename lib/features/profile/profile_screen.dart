import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    showDialog<void>(
      context: context,
      builder: (_) {
        return _EditNameDialog(
          initialName: patient.name,
          onSave: (newName) {
            appState.setPatient(
              code: patient.code,
              name: newName,
              age: patient.age,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final patient = appState.patient;
    final redEye = appState.redLensEye?.shortLabel ?? 'no configurado';
    final greenEye = appState.greenLensEye?.shortLabel ?? 'no configurado';

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Perfil', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Información del paciente y configuración visual.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 54),
                  const SizedBox(height: 18),
                  Text(
                    patient?.name ?? 'Paciente sin registrar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    patient == null
                        ? 'Sin código asignado'
                        : '${patient.code} · ${patient.age} años',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: patient == null
                          ? null
                          : () {
                              showEditNameDialog(context);
                            },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar nombre'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _InfoCard(
              title: 'Configuración de gafas',
              children: [
                _InfoRow(
                  icon: Icons.circle,
                  iconColor: AppColors.red,
                  label: 'Lente rojo',
                  value: 'Ojo $redEye',
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.circle,
                  iconColor: AppColors.green,
                  label: 'Lente verde',
                  value: 'Ojo $greenEye',
                ),
              ],
            ),
            const SizedBox(height: 18),
            _InfoCard(
              title: 'Estado de calibración',
              children: [
                _InfoRow(
                  icon: appState.hasCompletedCalibration
                      ? Icons.check_circle
                      : Icons.warning_amber_rounded,
                  iconColor: appState.hasCompletedCalibration
                      ? AppColors.green
                      : Colors.orange,
                  label: 'Gafas',
                  value: appState.hasCompletedCalibration
                      ? 'Calibradas'
                      : 'Pendiente',
                ),
              ],
            ),
            const SizedBox(height: 18),
            _InfoCard(
              title: 'Contraste configurado',
              children: [
                _InfoRow(
                  icon: Icons.tune,
                  iconColor: AppColors.red,
                  label: 'Rojo',
                  value: '${(appState.redContrast * 100).round()}%',
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.tune,
                  iconColor: AppColors.green,
                  label: 'Verde',
                  value: '${(appState.greenContrast * 100).round()}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialName, required this.onSave});

  final String initialName;
  final void Function(String newName) onSave;

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

    widget.onSave(newName);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar nombre'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Nombre del paciente',
          hintText: 'Ej: Sofía',
        ),
        onSubmitted: (_) => save(),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Text(
            title,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
