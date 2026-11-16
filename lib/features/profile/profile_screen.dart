import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/services/supabase_service.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/models/eye.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> showEditNameDialog(BuildContext context) async {
    final appState = context.read<AppState>();

    final patient = appState.patient;

    if (patient == null) {
      return;
    }

    final newName = await showDialog<String>(
      context: context,
      builder: (_) {
        return _EditNameDialog(initialName: patient.name);
      },
    );

    if (newName == null || newName.trim().isEmpty) {
      return;
    }

    try {
      await SupabaseService.instance.updatePatientName(
        patientCode: patient.code,
        name: newName.trim(),
      );

      appState.setPatient(
        code: patient.code,
        name: newName.trim(),
        age: patient.age,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nombre actualizado')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible actualizar el nombre.')),
      );
    }
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

    final redEye = appState.redLensEye?.label ?? 'Sin configurar';

    final greenEye = appState.greenLensEye?.label ?? 'Sin configurar';

    final redContrast = (appState.redContrast * 100).round();

    final greenContrast = (appState.greenContrast * 100).round();

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              children: [
                Text(
                  'Perfil',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 5),

                const Text(
                  'Datos y configuración visual.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                _PatientCard(
                  name: patient?.name ?? 'Paciente',
                  subtitle: patient == null
                      ? 'Sin datos registrados'
                      : '${patient.code} · '
                            '${patient.age} años',
                  onEdit: patient == null
                      ? null
                      : () {
                          showEditNameDialog(context);
                        },
                ),

                const SizedBox(height: 22),

                const _SectionTitle(
                  title: 'Configuración visual',
                  icon: Icons.visibility_rounded,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _EyeCard(
                        title: 'Lente rojo',
                        value: redEye,
                        color: AppColors.red,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _EyeCard(
                        title: 'Lente verde',
                        value: greenEye,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _ContrastCard(
                  redContrast: redContrast,
                  greenContrast: greenContrast,
                ),

                const SizedBox(height: 22),

                const _SectionTitle(
                  title: 'Calibración',
                  icon: Icons.tune_rounded,
                ),

                const SizedBox(height: 12),

                _CalibrationCard(
                  calibrated: appState.hasCompletedCalibration,
                  onRecalibrate: () {
                    recalibrate(context);
                  },
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: AppColors.cyan,
                        size: 22,
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Los cambios de configuración visual deben realizarse con acompañamiento de un adulto.',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 12.5,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({
    required this.name,
    required this.subtitle,
    required this.onEdit,
  });

  final String name;
  final String subtitle;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 35,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.13),
                foregroundColor: Colors.white,
              ),
              tooltip: 'Editar nombre',
              icon: const Icon(Icons.edit_rounded, size: 21),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.cyan, size: 22),

        const SizedBox(width: 8),

        Text(
          title,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _EyeCard extends StatelessWidget {
  const _EyeCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 108),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContrastCard extends StatelessWidget {
  const _ContrastCard({required this.redContrast, required this.greenContrast});

  final int redContrast;
  final int greenContrast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contraste actual',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 14),

          _ContrastLine(
            label: 'Rojo',
            value: redContrast,
            color: AppColors.red,
          ),

          const SizedBox(height: 12),

          _ContrastLine(
            label: 'Verde',
            value: greenContrast,
            color: AppColors.green,
          ),
        ],
      ),
    );
  }
}

class _ContrastLine extends StatelessWidget {
  const _ContrastLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),

        const SizedBox(width: 12),

        SizedBox(
          width: 38,
          child: Text(
            '$value%',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _CalibrationCard extends StatelessWidget {
  const _CalibrationCard({
    required this.calibrated,
    required this.onRecalibrate,
  });

  final bool calibrated;
  final VoidCallback onRecalibrate;

  @override
  Widget build(BuildContext context) {
    final accent = calibrated
        ? const Color(0xFF4CAF75)
        : const Color(0xFFE99A50);

    final background = calibrated ? AppColors.softGreen : AppColors.softOrange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              calibrated ? Icons.check_rounded : Icons.warning_amber_rounded,
              color: accent,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  calibrated ? 'Gafas calibradas' : 'Calibración pendiente',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  calibrated ? 'Listas para jugar' : 'Calibra antes de jugar',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: onRecalibrate,
            child: Text(calibrated ? 'Recalibrar' : 'Calibrar'),
          ),
        ],
      ),
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

    if (newName.isEmpty) {
      return;
    }

    Navigator.of(context).pop(newName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar nombre'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
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
