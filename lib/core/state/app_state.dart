import 'package:flutter/foundation.dart';

import '../models/eye.dart';
import '../models/patient.dart';

class AppState extends ChangeNotifier {
  Patient? _patient;
  Eye? _amblyopicEye;

  bool _hasCompletedCalibration = false;

  double _redContrast = 0.7;
  double _greenContrast = 0.7;

  String? _routeAfterCalibration;

  Patient? get patient => _patient;

  Eye? get amblyopicEye => _amblyopicEye;

  Eye? get dominantEye => _amblyopicEye?.opposite;

  Eye? get redLensEye => _amblyopicEye;

  Eye? get greenLensEye => dominantEye;

  bool get hasCompletedCalibration => _hasCompletedCalibration;

  double get redContrast => _redContrast;

  double get greenContrast => _greenContrast;

  bool get hasPatientData => _patient != null;

  bool get hasOcularConfiguration => _amblyopicEye != null;

  void setPatient({
    required String code,
    required String name,
    required int age,
  }) {
    _patient = Patient(
      code: code,
      name: name.trim().isEmpty ? 'Paciente' : name.trim(),
      age: age,
    );

    notifyListeners();
  }

  void setAmblyopicEye(Eye eye) {
    _amblyopicEye = eye;

    // Si se cambia el ojo configurado, la calibración anterior ya no es confiable.
    _hasCompletedCalibration = false;

    notifyListeners();
  }

  void setRedContrast(double value) {
    _redContrast = value.clamp(0.3, 1.0);
    notifyListeners();
  }

  void setGreenContrast(double value) {
    _greenContrast = value.clamp(0.3, 1.0);
    notifyListeners();
  }

  void setCalibrationReturnRoute(String route) {
    _routeAfterCalibration = route;
  }

  void markCalibrationCompleted() {
    _hasCompletedCalibration = true;
    notifyListeners();
  }

  String consumeCalibrationReturnRoute({required String defaultRoute}) {
    final route = _routeAfterCalibration ?? defaultRoute;
    _routeAfterCalibration = null;
    return route;
  }

  String get patientDisplayName {
    return _patient?.name ?? 'paciente';
  }

  String get patientSubtitle {
    final currentPatient = _patient;

    if (currentPatient == null) {
      return 'Sin registrar';
    }

    return '${currentPatient.code} · ${currentPatient.age} años';
  }
}
