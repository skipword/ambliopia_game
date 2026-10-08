import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/vision_kids_app.dart';
import 'core/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    throw StateError('Faltan SUPABASE_URL o SUPABASE_PUBLISHABLE_KEY.');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  final supabase = Supabase.instance.client;

  if (supabase.auth.currentUser == null) {
    final response = await supabase.auth.signInAnonymously();

    debugPrint('Usuario anónimo creado: ${response.user?.id}');
  } else {
    debugPrint('Usuario Supabase existente: ${supabase.auth.currentUser?.id}');
  }

  final appState = AppState();
  await appState.loadSavedState();

  runApp(
    ChangeNotifierProvider.value(value: appState, child: const VisionKidsApp()),
  );
}
