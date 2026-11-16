import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import 'balloon_session_result.dart';

class BalloonResultsScreen extends StatelessWidget {
  const BalloonResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result =
        ModalRoute.of(context)?.settings.arguments as BalloonSessionResult?;

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No hay resultados disponibles.')),
      );
    }

    final reaction = result.averageReactionTimeMs;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Resultados'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(
              Icons.celebration_rounded,
              color: AppColors.purple,
              size: 72,
            ),

            const SizedBox(height: 16),

            const Text(
              '¡Sesión terminada!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 24),

            _ResultCard(
              label: 'Globos explotados',
              value: '${result.stats.popped}',
            ),

            const SizedBox(height: 12),

            _ResultCard(
              label: 'Globos que escaparon',
              value: '${result.stats.escaped}',
            ),

            const SizedBox(height: 12),

            _ResultCard(
              label: 'Rojo',
              value:
                  '${result.stats.redPopped} aciertos · '
                  '${result.stats.redEscaped} escaparon',
            ),

            const SizedBox(height: 12),

            _ResultCard(
              label: 'Verde',
              value:
                  '${result.stats.greenPopped} aciertos · '
                  '${result.stats.greenEscaped} escaparon',
            ),

            if (reaction != null) ...[
              const SizedBox(height: 12),
              _ResultCard(
                label: 'Tiempo promedio',
                value: '${reaction.round()} ms',
              ),
            ],

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                result.mainObservation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRoutes.balloonPreparation);
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Jugar otra vez'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).popUntil((route) => route.settings.name == AppRoutes.home);
                },
                child: const Text('Volver al inicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
