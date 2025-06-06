import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/atributos_storage.dart';
import 'game_screen.dart';
import 'name_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    _navigate();
  }

  Future<void> _navigate() async {
    debugPrint('🟡 Entrou no _navigate');
    await Future.delayed(const Duration(seconds: 2));
    final nome = await AtributosStorage.carregarNomeJogador();
    debugPrint('🔵 Nome carregado: $nome');

    if (nome != null && nome.isNotEmpty) {
      var pontos = await AtributosStorage.carregarPontos();
      debugPrint('🟢 Pontos carregados inicialmente: $pontos');

      final prefs = await SharedPreferences.getInstance();
      final jaIniciou = prefs.getBool('atributosIniciaisSalvos') ?? false;

      if (!jaIniciou) {
        await AtributosStorage.salvarPontos(3);
        await AtributosStorage.salvar({
          'Oratória': 0,
          'Liderança': 0,
          'Empatia': 0,
          'Organização': 0,
        });
        await prefs.setBool('atributosIniciaisSalvos', true);
        pontos = 3;
      }

      final confirmPontos = await AtributosStorage.carregarPontos();
      debugPrint('✅ Pontos confirmados: $confirmPontos');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GameScreen(nome: nome)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NameScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF203A43),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/Logo_rgb_Leo_2C.png', width: 180),
              const SizedBox(height: 20),
              const Text(
                'Vida de LEO Clube',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Carregando...',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
