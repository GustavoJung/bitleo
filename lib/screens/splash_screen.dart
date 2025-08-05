import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import '../services/firestore_service.dart';
import 'game_screen.dart';
import 'name_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  double _progress = 0.1;
  int _loadingStep = 0;
  Timer? _timer;
  late List<String> loadingTexts;

  @override
  void initState() {
    super.initState();

    loadingTexts = [
      'Iniciando motor do jogo...',
      'Sincronizando banco de dados...',
      'Carregando conquistas...',
      'Consultando Oráculo de LEOs...',
      'Afiando garras de liderança...',
      'Preparando café virtual...',
      'Carregando dados do jogador...',
      'Quase lá...',
    ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _startFakeLoading();
    _navigate();
  }

  void _startFakeLoading() {
    _timer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (_loadingStep < loadingTexts.length - 1) {
        setState(() {
          _loadingStep++;
          _progress += 0.12 + (0.08 * (_loadingStep / loadingTexts.length));
          if (_progress > 1.0) _progress = 1.0;
        });
      }
    });
  }

  Future<void> _navigate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await Future.delayed(const Duration(seconds: 2));
      _finishLoading();
      return;
    }
    final uid = user.uid;
    await Future.delayed(const Duration(milliseconds: 1900));
    await FirestoreService.verificarInicializacao(uid);

    setState(() {
      _loadingStep = loadingTexts.length - 2;
      _progress = 0.92;
    });

    final nome = await FirestoreService.carregarNomeJogador(uid);

    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _loadingStep = loadingTexts.length - 1;
      _progress = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    _finishLoading(
      goTo: nome != null && nome.isNotEmpty
          ? GameScreen(nome: nome)
          : const NameScreen(),
    );
  }

  void _finishLoading({Widget? goTo}) {
    _timer?.cancel();
    if (goTo != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => goTo),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NameScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadingText =
        loadingTexts[_loadingStep.clamp(0, loadingTexts.length - 1)];

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
            particleCount: 50,
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
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo limpa, sem firula
                  Image.asset('assets/images/logo.png', width: 180),
                  const SizedBox(height: 28),
                  const Text(
                    'Vida de LEO Clube',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.purple,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Loading Text que troca
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Text(
                      loadingText,
                      key: ValueKey(loadingText),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Barra de progresso estilosa
                  Container(
                    width: 240,
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white12,
                      border: Border.all(
                        color: Colors.amberAccent.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 240 * _progress,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amberAccent,
                                Colors.orangeAccent,
                                Colors.purple.shade200,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 38),
                  // Mensagem nerdzinha
                  const Text(
                    'Pressione qualquer botão pra começar (mentira, espera aí mesmo 😜)',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
