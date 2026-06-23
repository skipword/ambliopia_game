import 'package:flutter/material.dart';

class PianoVisualScreen extends StatelessWidget {
  const PianoVisualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Piano Visual')),
      body: const Center(child: Text('Aquí conectaremos el juego con Flame')),
    );
  }
}
