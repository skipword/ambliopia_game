import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/patient.dart';

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<void> savePatient(Patient patient) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError('No existe un usuario autenticado en Supabase.');
    }

    await _client.from('patients').upsert({
      'code': patient.code,
      'name': patient.name,
      'age': patient.age,
      'auth_user_id': user.id,
    });
  }
}
