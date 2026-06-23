import 'package:flutter/material.dart';

import '../../app/app_routes.dart';

class PatientDataScreen extends StatelessWidget {
  const PatientDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderScreen(
      title: 'Registro de paciente',
      subtitle: 'Datos personales',
      buttonText: 'Continuar',
      nextRoute: AppRoutes.ocularConfig,
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.nextRoute,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final String nextRoute;

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
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(nextRoute);
                  },
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
