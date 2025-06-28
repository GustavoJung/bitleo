import 'package:bitleo/services/conquistas_service.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import '../services/atributos_storage.dart';
import 'package:animated_background/animated_background.dart';
import 'dart:ui';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ConquistaService.marcarTelaVisitada('name');
    return Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: Colors.white24,
            spawnOpacity: 0.0,
            opacityChangeRate: 0.25,
            minOpacity: 0.1,
            maxOpacity: 0.4,
            spawnMinSpeed: 30.0,
            spawnMaxSpeed: 70.0,
            spawnMinRadius: 1.0,
            spawnMaxRadius: 4.0,
            particleCount: 40,
          ),
        ),
        vsync: this,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6A1B9A), Color(0xFF121212)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/Logo_rgb_Leo_2C.png',
                          width: 140,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Simulador de Vida de LEO Clube',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _controller,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Digite seu nome',
                            hintStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white54,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () async {
                              String nome = _controller.text.trim();
                              if (nome.isNotEmpty) {
                                await AtributosStorage.salvarNomeJogador(nome);
                                await AtributosStorage.salvarPontos(3);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SplashScreen(),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Começar',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
