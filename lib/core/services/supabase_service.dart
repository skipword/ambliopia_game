import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/clinical_session_summary.dart';
import '../models/patient.dart';

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<User> _ensureAuthenticatedUser() async {
    final existingUser = _client.auth.currentUser;

    if (existingUser != null) {
      return existingUser;
    }

    try {
      final response = await _client.auth.signInAnonymously();

      final user = response.user ?? _client.auth.currentUser;

      if (user == null) {
        throw StateError(
          'Supabase no devolvió un usuario después del inicio anónimo.',
        );
      }

      return user;
    } on AuthException catch (error) {
      throw StateError(
        'No fue posible iniciar sesión en Supabase: ${error.message}',
      );
    } catch (error) {
      throw StateError('No fue posible iniciar sesión en Supabase: $error');
    }
  }

  Future<Patient> registerPatient({
    required String name,
    required int age,
  }) async {
    final user = await _ensureAuthenticatedUser();

    final normalizedName = name.trim().isEmpty ? 'Paciente' : name.trim();

    final existing = await _client
        .from('patients')
        .select('code, name, age')
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (existing != null) {
      final data = await _client
          .from('patients')
          .update({'name': normalizedName, 'age': age})
          .eq('auth_user_id', user.id)
          .select('code, name, age')
          .single();

      return Patient(
        code: data['code'] as String,
        name: data['name'] as String,
        age: data['age'] as int,
      );
    }

    final data = await _client
        .from('patients')
        .insert({'name': normalizedName, 'age': age, 'auth_user_id': user.id})
        .select('code, name, age')
        .single();

    return Patient(
      code: data['code'] as String,
      name: data['name'] as String,
      age: data['age'] as int,
    );
  }

  Future<void> updatePatientConfiguration({
    required String patientCode,
    required String amblyopicEye,
    required double redContrast,
    required double greenContrast,
    required bool calibrationCompleted,
  }) async {
    final user = await _ensureAuthenticatedUser();

    await _client
        .from('patients')
        .update({
          'amblyopic_eye': amblyopicEye,
          'red_contrast': redContrast,
          'green_contrast': greenContrast,
          'calibration_completed': calibrationCompleted,
        })
        .eq('code', patientCode)
        .eq('auth_user_id', user.id);
  }

  Future<void> updatePatientName({
    required String patientCode,
    required String name,
  }) async {
    final user = await _ensureAuthenticatedUser();

    await _client
        .from('patients')
        .update({'name': name.trim()})
        .eq('code', patientCode)
        .eq('auth_user_id', user.id);
  }

  Future<void> saveClinicalSession(ClinicalSessionSummary session) async {
    await _ensureAuthenticatedUser();

    try {
      await _client.from('clinical_sessions').insert({
        'id': session.id,
        'patient_id': session.patientId,
        'game_type': session.gameType.name,
        'game_name': session.gameName,
        'started_at': session.startedAt.toUtc().toIso8601String(),
        'ended_at': session.endedAt.toUtc().toIso8601String(),
        'duration_seconds': session.durationSeconds,
        'score': session.score,
        'objective_label': session.objectiveLabel,
        'completed_objective': session.completedObjective,
        'target_objective': session.targetObjective,
        'red_success': session.redSuccess,
        'red_errors': session.redErrors,
        'green_success': session.greenSuccess,
        'green_errors': session.greenErrors,
        'events_count': session.eventsCount,
        'observation': session.observation,
        'average_reaction_time_ms': session.averageReactionTimeMs,
      });
    } on PostgrestException catch (error) {
      // Si ya existe, una sincronización anterior sí llegó.
      if (error.code == '23505') {
        return;
      }

      rethrow;
    }
  }
}
