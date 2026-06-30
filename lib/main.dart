import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/vision_kids_app.dart';
import 'core/state/app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const VisionKidsApp(),
    ),
  );
}
