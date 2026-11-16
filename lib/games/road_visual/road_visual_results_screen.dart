import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import 'road_visual_session_result.dart';

class RoadVisualResultsScreen extends StatelessWidget {
  const RoadVisualResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result =
        ModalRoute.of(context)?.settings.arguments as RoadVisualSessionResult?;

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No hay resultados disponibles.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Resultados'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.directions_car, color: AppColors.cyan, size: 72),

            const SizedBox(height: 16),

            const Text(
              '¡Ruta terminada!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              result.endReasonLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 24),

            _ResultCard(label: 'Puntuación', value: '${result.score}'),

            const SizedBox(height: 12),

            _ResultCard(
              label: 'Objetivos rojos',
              value:
                  '${result.stats.objectivesCollected}'
                  '/'
                  '${result.stats.redTotal}',
            ),

            const SizedBox(height: 12),

            _ResultCard(
              label: 'Vehículos evitados',
              value: '${result.stats.obstaclesAvoided}',
            ),

            const SizedBox(height: 12),

            _ResultCard(
              label: 'Colisiones',
              value: '${result.stats.collisions}',
            ),

            const SizedBox(height: 12),

            _ResultCard(
              label: 'Cambios de carril',
              value: '${result.stats.laneChanges}',
            ),

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
                  ).pushReplacementNamed(AppRoutes.roadVisualPreparation);
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
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
