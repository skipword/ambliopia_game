import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

class GameResultsScaffold extends StatelessWidget {
  const GameResultsScaffold({
    super.key,
    required this.title,
    required this.message,
    required this.stars,
    required this.icon,
    required this.accentColor,
    required this.statusTitle,
    required this.statusMessage,
    required this.onPlayAgain,
    required this.onHome,
  });

  final String title;
  final String message;

  final int stars;

  final IconData icon;
  final Color accentColor;

  final String statusTitle;
  final String statusMessage;

  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              children: [
                _ResultHero(
                  title: title,
                  message: message,
                  stars: stars,
                  icon: icon,
                  accentColor: accentColor,
                ),

                const SizedBox(height: 18),

                _StatusCard(
                  title: statusTitle,
                  message: statusMessage,
                  accentColor: accentColor,
                ),

                const SizedBox(height: 14),

                const _RestCard(),

                const SizedBox(height: 24),

                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: onPlayAgain,
                    icon: const Icon(Icons.replay_rounded, size: 24),
                    label: const Text('JUGAR OTRA VEZ'),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: onHome,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Volver a jugar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({
    required this.title,
    required this.message,
    required this.stars,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String message;

  final int stars;

  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 48),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final earned = index < stars;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Icon(
                  earned ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: earned ? AppColors.yellow : Colors.white30,
                  size: 46,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.message,
    required this.accentColor,
  });

  final String title;
  final String message;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: accentColor, size: 27),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class _RestCard extends StatelessWidget {
  const _RestCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.visibility_outlined, color: AppColors.cyan, size: 24),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'Mantén tus ojos alerta para el siguiente reto.',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
