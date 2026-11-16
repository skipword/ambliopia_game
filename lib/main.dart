import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/vision_kids_app.dart';
import 'core/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
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

    // Auth no debe impedir que la aplicación arranque.
    await _ensureAnonymousSession();

    final appState = AppState();

    // Si el almacenamiento local presenta un problema,
    // arrancamos con el estado por defecto en lugar de dejar
    // la aplicación en blanco.
    try {
      await appState.loadSavedState();
    } catch (error, stackTrace) {
      debugPrint('No fue posible cargar el estado local: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    runApp(
      ChangeNotifierProvider.value(
        value: appState,
        child: const VisionKidsApp(),
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('Error crítico al iniciar Vision Kids: $error');
    debugPrintStack(stackTrace: stackTrace);

    runApp(const _StartupErrorApp());
  }
}

Future<void> _ensureAnonymousSession() async {
  final supabase = Supabase.instance.client;

  if (supabase.auth.currentUser != null) {
    debugPrint(
      'Usuario Supabase existente: '
      '${supabase.auth.currentUser?.id}',
    );
    return;
  }

  try {
    final response = await supabase.auth.signInAnonymously();

    debugPrint('Usuario anónimo creado: ${response.user?.id}');
  } on AuthException catch (error, stackTrace) {
    debugPrint(
      'No fue posible iniciar sesión anónima: '
      '${error.message}',
    );
    debugPrintStack(stackTrace: stackTrace);

    // Importante:
    // No lanzamos nuevamente la excepción.
    // Vision Kids puede continuar funcionando localmente.
  } catch (error, stackTrace) {
    debugPrint('Error inesperado al iniciar sesión anónima: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vision Kids',
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 64,
                      color: Color(0xFF5B57D1),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'No pudimos iniciar Vision Kids',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15162E),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Verifica tu conexión a internet y vuelve a abrir '
                      'la aplicación. Tus datos no serán eliminados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: Color(0xFF666A7D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
