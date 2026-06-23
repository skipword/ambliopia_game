import 'package:flutter/material.dart';

import '../../app/app_routes.dart';

class OcularConfigurationScreen extends StatelessWidget {
  const OcularConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registro de paciente',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Configuración ocular',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              const Text(
                '¿Cuál es el ojo con ambliopía?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _EyeOption(title: 'Ojo izquierdo', selected: true),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _EyeOption(title: 'Ojo derecho', selected: false),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.home);
                  },
                  child: const Text('¡Listo!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EyeOption extends StatelessWidget {
  const _EyeOption({required this.title, required this.selected});

  final String title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFEEF1) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? const Color(0xFFFF3B3B) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
