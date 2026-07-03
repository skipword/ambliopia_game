import 'package:flutter/material.dart';

import '../../app/app_routes.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.currentIndex, super.key});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: NavigationBar(
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index == currentIndex) return;

          if (index == 0) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          }

          if (index == 1) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.games);
          }

          if (index == 2) {
            Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
          }

          if (index == 3) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Juegos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Calibrar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
