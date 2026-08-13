import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/clinical_session_summary.dart';
import '../models/eye.dart';
import '../models/patient.dart';
import '../storage/app_preferences.dart';

class AppState extends ChangeNotifier {
  AppState({AppPreferences? preferences})
    : _preferences = preferences ?? AppPreferences();

  final AppPreferences _preferences;

  Patient? _patient;
  Eye? _amblyopicEye;

  bool _hasCompletedCalibration = false;

  double _redContrast = 0.7;
  double _greenContrast = 0.7;

  String? _routeAfterCalibration;

  final List<ClinicalSessionSummary> _clinicalSessions = [];

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

  List<ClinicalSessionSummary> get clinicalSessions {
    return List.unmodifiable(_clinicalSessions.reversed);
  }

  ClinicalSessionSummary? get latestClinicalSession {
    if (_clinicalSessions.isEmpty) return null;

    return _clinicalSessions.last;
  }

  Future<void> loadSavedState() async {
    try {
      final savedData = await _preferences.load();

      _patient = savedData.patient;
      _amblyopicEye = savedData.amblyopicEye;

      _hasCompletedCalibration = savedData.hasCompletedCalibration;

      _redContrast = savedData.redContrast;
      _greenContrast = savedData.greenContrast;

      notifyListeners();
    } catch (error) {
      debugPrint('No fue posible cargar los datos guardados: $error');
    }
  }

  Future<void> _saveBasicState() async {
    try {
      await _preferences.save(
        patient: _patient,
        amblyopicEye: _amblyopicEye,
        hasCompletedCalibration: _hasCompletedCalibration,
        redContrast: _redContrast,
        greenContrast: _greenContrast,
      );
    } catch (error) {
      debugPrint('No fue posible guardar los datos: $error');
    }
  }

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

    unawaited(_saveBasicState());
  }

  void setAmblyopicEye(Eye eye) {
    _amblyopicEye = eye;

    // Si cambia el ojo configurado, debe repetirse la calibración.
    _hasCompletedCalibration = false;

    notifyListeners();

    unawaited(_saveBasicState());
  }

  void setRedContrast(double value) {
    _redContrast = value.clamp(0.3, 1.0).toDouble();

    notifyListeners();
  }

  void setGreenContrast(double value) {
    _greenContrast = value.clamp(0.3, 1.0).toDouble();

    notifyListeners();
  }

  void setCalibrationReturnRoute(String route) {
    _routeAfterCalibration = route;
  }

  void markCalibrationCompleted() {
    _hasCompletedCalibration = true;

    notifyListeners();

    // Aquí se guardan también los contrastes definitivos.
    unawaited(_saveBasicState());
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

  void addClinicalSession(ClinicalSessionSummary summary) {
    _clinicalSessions.add(summary);

    notifyListeners();
  }

  Future<void> clearSavedBasicData() async {
    await _preferences.clear();

    _patient = null;
    _amblyopicEye = null;

    _hasCompletedCalibration = false;

    _redContrast = 0.7;
    _greenContrast = 0.7;

    notifyListeners();
  }
}
