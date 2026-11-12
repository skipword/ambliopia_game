import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/clinical_session_summary.dart';
import '../models/patient.dart';

class ProfessionalSupabaseService {
  ProfessionalSupabaseService._() {
    const url = String.fromEnvironment('SUPABASE_URL');

    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

    if (url.isEmpty || key.isEmpty) {
      throw StateError('Faltan SUPABASE_URL o SUPABASE_PUBLISHABLE_KEY.');
    }

    _supabaseUrl = url;
    _publishableKey = key;

    _client = SupabaseClient(url, key, accessToken: _getAccessToken);
  }

  static final ProfessionalSupabaseService instance =
      ProfessionalSupabaseService._();

  late final String _supabaseUrl;
  late final String _publishableKey;

  late final SupabaseClient _client;

  String? _accessToken;
  String? _refreshToken;

  DateTime? _expiresAt;

  bool get isAuthenticated => _accessToken != null;

  Future<void> signIn({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$_supabaseUrl/auth/v1/token?grant_type=password'),
      headers: {'apikey': _publishableKey, 'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AuthException('Correo o contraseña incorrectos.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    _applyTokenResponse(data);
  }

  Future<String?> _getAccessToken() async {
    if (_accessToken == null) {
      return null;
    }

    final expiresAt = _expiresAt;

    if (expiresAt != null &&
        DateTime.now().isAfter(
          expiresAt.subtract(const Duration(minutes: 1)),
        )) {
      await _refreshSession();
    }

    return _accessToken;
  }

  Future<void> _refreshSession() async {
    final refreshToken = _refreshToken;

    if (refreshToken == null) {
      _clearSession();
      return;
    }

    final response = await http.post(
      Uri.parse('$_supabaseUrl/auth/v1/token?grant_type=refresh_token'),
      headers: {'apikey': _publishableKey, 'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _clearSession();

      throw const AuthException('La sesión profesional expiró.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    _applyTokenResponse(data);
  }

  void _applyTokenResponse(Map<String, dynamic> data) {
    _accessToken = data['access_token'] as String?;

    _refreshToken = data['refresh_token'] as String?;

    final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 3600;

    _expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    if (_accessToken == null) {
      throw const AuthException('Supabase no devolvió un token válido.');
    }
  }

  Future<void> signOut() async {
    _clearSession();
  }

  void _clearSession() {
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;
  }

  Future<List<Patient>> getPatients() async {
    final data = await _client
        .from('patients')
        .select('code, name, age')
        .order('code', ascending: true);

    return data.map<Patient>((row) {
      return Patient(
        code: row['code'] as String,
        name: row['name'] as String,
        age: row['age'] as int,
      );
    }).toList();
  }

  Future<List<ClinicalSessionSummary>> getClinicalSessions({
    String? patientCode,
  }) async {
    var query = _client.from('clinical_sessions').select();

    if (patientCode != null) {
      query = query.eq('patient_id', patientCode);
    }

    final data = await query.order('started_at', ascending: false);

    return data.map<ClinicalSessionSummary>(_mapClinicalSession).toList();
  }

  ClinicalSessionSummary _mapClinicalSession(Map<String, dynamic> row) {
    return ClinicalSessionSummary(
      id: row['id'].toString(),
      patientId: row['patient_id'] as String,
      gameType: _parseGameType(row['game_type'] as String),
      gameName: row['game_name'] as String,
      startedAt: DateTime.parse(row['started_at'] as String).toLocal(),
      endedAt: DateTime.parse(row['ended_at'] as String).toLocal(),
      durationSeconds: (row['duration_seconds'] as num).toDouble(),
      score: (row['score'] as num).toInt(),
      objectiveLabel: row['objective_label'] as String,
      completedObjective: (row['completed_objective'] as num).toInt(),
      targetObjective: (row['target_objective'] as num).toInt(),
      redSuccess: (row['red_success'] as num).toInt(),
      redErrors: (row['red_errors'] as num).toInt(),
      greenSuccess: (row['green_success'] as num).toInt(),
      greenErrors: (row['green_errors'] as num).toInt(),
      eventsCount: (row['events_count'] as num).toInt(),
      observation: row['observation'] as String? ?? '',
      averageReactionTimeMs: row['average_reaction_time_ms'] == null
          ? null
          : (row['average_reaction_time_ms'] as num).toDouble(),
    );
  }

  ClinicalGameType _parseGameType(String value) {
    switch (value) {
      case 'pianoVisual':
        return ClinicalGameType.pianoVisual;

      case 'breakTheRow':
        return ClinicalGameType.breakTheRow;

      case 'farmCrossing':
        return ClinicalGameType.farmCrossing;

      default:
        throw FormatException('Tipo de juego desconocido: $value');
    }
  }
}
