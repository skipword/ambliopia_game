import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/vision_kids_app.dart';
import 'core/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();

  await appState.loadSavedState();

  runApp(
    ChangeNotifierProvider.value(value: appState, child: const VisionKidsApp()),
  );
}
