import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../state/app_state.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.currentIndex, super.key});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: NavigationBar(
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index == currentIndex) {
            return;
          }

          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              break;

            case 1:
              final appState = context.read<AppState>();

              appState.setCalibrationReturnRoute(AppRoutes.home);

              Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
              break;

            case 2:
              Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports_rounded),
            label: 'Jugar',
          ),
          NavigationDestination(
            icon: Icon(Icons.visibility_outlined),
            selectedIcon: Icon(Icons.visibility_rounded),
            label: 'Calibrar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
