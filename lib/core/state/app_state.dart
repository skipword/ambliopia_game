import 'dart:async';

import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../models/clinical_session_summary.dart';
import '../models/eye.dart';
import '../models/patient.dart';
import '../storage/app_preferences.dart';

class AppState extends ChangeNotifier {
  AppState({AppPreferences? preferences, AppDatabase? database})
    : _preferences = preferences ?? AppPreferences(),
      _database = database ?? AppDatabase();

  final AppPreferences _preferences;
  final AppDatabase _database;

  Patient? _patient;
  Eye? _amblyopicEye;

  bool _hasCompletedCalibration = false;

  double _redContrast = 0.7;
  double _greenContrast = 0.7;

  String? _routeAfterCalibration;

  final List<ClinicalSessionSummary> _clinicalSessions = [];

  Patient? get patient => _patient;

  List<Patient> get doctorPatients {
    final currentPatient = _patient;

    if (currentPatient == null) {
      return const [];
    }

    return [currentPatient];
  }

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
    await _loadBasicState();
    await _loadClinicalSessions();
  }

  Future<void> _loadBasicState() async {
    try {
      final savedData = await _preferences.load();

      _patient = savedData.patient;
      _amblyopicEye = savedData.amblyopicEye;

      _hasCompletedCalibration = savedData.hasCompletedCalibration;

      _redContrast = savedData.redContrast;
      _greenContrast = savedData.greenContrast;

      notifyListeners();
    } catch (error) {
      debugPrint('No fue posible cargar los datos básicos guardados: $error');
    }
  }

  Future<void> _loadClinicalSessions() async {
    try {
      final savedSessions = await _database.getClinicalSummaries();

      _clinicalSessions.clear();

      // La base devuelve primero las más recientes.
      // Internamente las guardamos en orden cronológico
      // porque el getter ya las invierte para mostrarlas.
      _clinicalSessions.addAll(savedSessions.reversed);

      notifyListeners();

      debugPrint('Sesiones clínicas cargadas: ${_clinicalSessions.length}');
    } catch (error) {
      debugPrint('No fue posible cargar las sesiones clínicas: $error');
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
      debugPrint('No fue posible guardar los datos básicos: $error');
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

    // Si cambia el ojo configurado,
    // debe repetirse la calibración.
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

    unawaited(_saveClinicalSession(summary));
  }

  Future<void> _saveClinicalSession(ClinicalSessionSummary summary) async {
    try {
      await _database.saveClinicalSummary(summary);

      debugPrint('Sesión clínica guardada: ${summary.gameName}');
    } catch (error) {
      debugPrint('No fue posible guardar la sesión clínica: $error');
    }
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

  Future<void> clearClinicalSessions() async {
    await _database.deleteAllClinicalSessions();

    _clinicalSessions.clear();

    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_database.close());

    super.dispose();
  }
}
