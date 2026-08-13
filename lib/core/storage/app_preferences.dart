import 'package:shared_preferences/shared_preferences.dart';

import '../models/eye.dart';
import '../models/patient.dart';

class SavedAppData {
  const SavedAppData({
    required this.patient,
    required this.amblyopicEye,
    required this.hasCompletedCalibration,
    required this.redContrast,
    required this.greenContrast,
  });

  final Patient? patient;
  final Eye? amblyopicEye;

  final bool hasCompletedCalibration;

  final double redContrast;
  final double greenContrast;
}

class AppPreferences {
  AppPreferences({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _patientCodeKey = 'patient_code';
  static const String _patientNameKey = 'patient_name';
  static const String _patientAgeKey = 'patient_age';

  static const String _amblyopicEyeKey = 'amblyopic_eye';

  static const String _completedCalibrationKey = 'completed_calibration';

  static const String _redContrastKey = 'red_contrast';
  static const String _greenContrastKey = 'green_contrast';

  Future<void> save({
    required Patient? patient,
    required Eye? amblyopicEye,
    required bool hasCompletedCalibration,
    required double redContrast,
    required double greenContrast,
  }) async {
    if (patient == null) {
      await _preferences.remove(_patientCodeKey);
      await _preferences.remove(_patientNameKey);
      await _preferences.remove(_patientAgeKey);
    } else {
      await _preferences.setString(_patientCodeKey, patient.code);

      await _preferences.setString(_patientNameKey, patient.name);

      await _preferences.setInt(_patientAgeKey, patient.age);
    }

    if (amblyopicEye == null) {
      await _preferences.remove(_amblyopicEyeKey);
    } else {
      await _preferences.setString(_amblyopicEyeKey, amblyopicEye.name);
    }

    await _preferences.setBool(
      _completedCalibrationKey,
      hasCompletedCalibration,
    );

    await _preferences.setDouble(_redContrastKey, redContrast);

    await _preferences.setDouble(_greenContrastKey, greenContrast);
  }

  Future<SavedAppData> load() async {
    final patientCode = await _preferences.getString(_patientCodeKey);

    final patientName = await _preferences.getString(_patientNameKey);

    final patientAge = await _preferences.getInt(_patientAgeKey);

    Patient? patient;

    if (patientCode != null && patientName != null && patientAge != null) {
      patient = Patient(code: patientCode, name: patientName, age: patientAge);
    }

    final savedEye = await _preferences.getString(_amblyopicEyeKey);

    Eye? amblyopicEye;

    if (savedEye == Eye.left.name) {
      amblyopicEye = Eye.left;
    } else if (savedEye == Eye.right.name) {
      amblyopicEye = Eye.right;
    }

    final completedCalibration =
        await _preferences.getBool(_completedCalibrationKey) ?? false;

    final savedRedContrast =
        await _preferences.getDouble(_redContrastKey) ?? 0.7;

    final savedGreenContrast =
        await _preferences.getDouble(_greenContrastKey) ?? 0.7;

    return SavedAppData(
      patient: patient,
      amblyopicEye: amblyopicEye,
      hasCompletedCalibration: completedCalibration,
      redContrast: savedRedContrast.clamp(0.3, 1.0).toDouble(),
      greenContrast: savedGreenContrast.clamp(0.3, 1.0).toDouble(),
    );
  }

  Future<void> clear() async {
    await _preferences.remove(_patientCodeKey);
    await _preferences.remove(_patientNameKey);
    await _preferences.remove(_patientAgeKey);
    await _preferences.remove(_amblyopicEyeKey);
    await _preferences.remove(_completedCalibrationKey);
    await _preferences.remove(_redContrastKey);
    await _preferences.remove(_greenContrastKey);
  }
}
