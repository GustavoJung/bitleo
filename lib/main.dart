import 'package:flutter/material.dart';
import 'screens/main_menu.dart';

void main() {
  runApp(const LEOGame());
}

class LEOGame extends StatelessWidget {
  const LEOGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vida de LEO Clube',
      theme: ThemeData.dark(),
      home: const MainMenu(),
    );
  }
}
