import 'package:flutter/material.dart';

import '../features/calibration/calibration_step_1_screen.dart';
import '../features/calibration/calibration_step_2_screen.dart';
import '../features/calibration/calibration_step_3_screen.dart';
import '../features/games_menu/games_menu_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/patient_registration/ocular_configuration_screen.dart';
import '../features/patient_registration/patient_data_screen.dart';
import '../features/profile/profile_screen.dart';
import '../games/piano_visual/piano_visual_screen.dart';
import '../games/piano_visual/piano_preparation_screen.dart';
import '../games/piano_visual/piano_results_screen.dart';
import 'app_routes.dart';
import 'app_theme.dart';

class VisionKidsApp extends StatelessWidget {
  const VisionKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision Kids',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.welcome,
      routes: {
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.patientData: (_) => const PatientDataScreen(),
        AppRoutes.ocularConfig: (_) => const OcularConfigurationScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.games: (_) => const GamesMenuScreen(),
        AppRoutes.calibrationStep1: (_) => const CalibrationStep1Screen(),
        AppRoutes.calibrationStep2: (_) => const CalibrationStep2Screen(),
        AppRoutes.calibrationStep3: (_) => const CalibrationStep3Screen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.pianoVisual: (_) => const PianoVisualScreen(),
        AppRoutes.pianoPreparation: (_) => const PianoPreparationScreen(),
        AppRoutes.pianoResults: (_) => const PianoResultsScreen(),
      },
    );
  }
}
