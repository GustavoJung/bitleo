import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'actions_screen.dart';
import 'profile_screen.dart';
import 'conquistas_screen.dart';
import '../widgets/custom_appbar.dart';

class GameScreen extends StatefulWidget {
  final String nome;

  const GameScreen({super.key, required this.nome});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  List<String> story = ["${DateTime.now().year}: ${"Você ingressou no LEO Clube!"}"];

  int dinheiro = 100;
  int inteligencia = 5;
  int felicidade = 50;
  int saude = 50;
  double idade = 18;
  int xp = 0;
  String cargo = 'Pré-LEO';

  final random = Random();
  final ScrollController _scrollController = ScrollController();
  List<String> conquistas = [];

  late AnimationController _colorController;
  late Animation<Color?> colorAnimation1;
  late Animation<Color?> colorAnimation2;
  late ConfettiController _confettiController;

  late Map<String, AnimationController> statusControllers;
  late Map<String, Animation<double>> statusAnimations;
  String animatedStatus = '';

  @override
  void initState() {
    super.initState();

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    colorAnimation1 = ColorTween(
      begin: const Color(0xFF0F2027),
      end: const Color(0xFF203A43),
    ).animate(_colorController);

    colorAnimation2 = ColorTween(
      begin: const Color(0xFF203A43),
      end: const Color(0xFF2C5364),
    ).animate(_colorController);

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    statusControllers = {
      'dinheiro': AnimationController(vsync: this, duration: const Duration(milliseconds: 500)),
      'inteligencia': AnimationController(vsync: this, duration: const Duration(milliseconds: 500)),
      'felicidade': AnimationController(vsync: this, duration: const Duration(milliseconds: 500)),
      'saude': AnimationController(vsync: this, duration: const Duration(milliseconds: 500)),
      'xp': AnimationController(vsync: this, duration: const Duration(milliseconds: 500)),
    };

    statusAnimations = {
      for (var key in statusControllers.keys)
        key: TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
        ]).chain(CurveTween(curve: Curves.easeInOut)).animate(statusControllers[key]!)
    };
  }

  @override
  void dispose() {
    _colorController.dispose();
    _confettiController.dispose();
    for (var controller in statusControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }


  void navigateWithTransition(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
          return FadeTransition(
            opacity: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void showAnimatedDialog(String title, String message) {
    _confettiController.play();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ScaleTransition(
            scale:
                CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Ok'),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }

  void applyChanges(Map<String, dynamic> selected, String description) {
    int gasto = ((selected['dinheiro'] ?? 0) as num).toInt();
    if (dinheiro + gasto < 0) {
      showDialogMessage('💸 Sem grana!', 'Você não tem dinheiro suficiente para essa atividade.');
      return;
    }

    setState(() {
      dinheiro += gasto;
      if (gasto != 0) triggerStatusAnim('dinheiro');

      final intel = ((selected['inteligencia'] ?? 0) as num).toInt();
      inteligencia += intel;
      if (intel != 0) triggerStatusAnim('inteligencia');

      final feliz = ((selected['felicidade'] ?? 0) as num).toInt();
      felicidade += feliz;
      if (feliz != 0) triggerStatusAnim('felicidade');

      final vida = ((selected['saude'] ?? 0) as num).toInt();
      saude += vida;
      if (vida != 0) triggerStatusAnim('saude');

      final pontos = ((selected['xp'] ?? 0) as num).toInt();
      xp += pontos;
      if (pontos != 0) triggerStatusAnim('xp');

      idade += 0.05;

      story.add("${DateTime.now().year + idade.floor() - 18}: $description");

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );

      checkConsequences();
      updateCargo();
      checkRandomEvent();
    });
  }

  void triggerStatusAnim(String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    statusControllers[status]?.forward(from: 0);
  }

void checkConsequences() {
  if (felicidade <= 0) {
    showDialogMessage('😢 Tristeza!',
        'Sua felicidade está muito baixa. Cuide do seu bem-estar!');
  }
  if (saude <= 0) {
    showDialogMessage('🏥 Problema de Saúde!',
        'Sua saúde está crítica. Você precisa descansar e se cuidar!');
  }
  if (dinheiro <= 0) {
    showDialogMessage('💸 Falência!',
        'Você ficou sem dinheiro. Faça trabalhos ou organize eventos para arrecadar fundos!');
  }
}

void showDialogMessage(String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void updateCargo() {
    final cargos = [
      {'xp': 50, 'nome': 'Membro'},
      {'xp': 80, 'nome': 'Diretor Social'},
      {'xp': 110, 'nome': 'Diretor de Marketing'},
      {'xp': 140, 'nome': 'Diretor de Campanhas'},
      {'xp': 180, 'nome': 'Tesoureiro'},
      {'xp': 220, 'nome': 'Secretário'},
      {'xp': 260, 'nome': 'Vice-Presidente'},
      {'xp': 300, 'nome': 'Presidente'},
    ];

    for (var c in cargos) {
      if (xp >= (c['xp'] as int) && cargos.indexWhere((e) => e['nome'] == cargo) < cargos.indexOf(c)) {
        cargo = c['nome'] as String;

        story.add("${DateTime.now().year + idade.floor() - 18}: 🎉 Você foi promovido(a) a $cargo!");

        showAnimatedDialog('🎉 Promoção!', 'Você agora é $cargo!');

        _confettiController.play();

        if (!conquistas.contains('Se tornou $cargo')) {
          conquistas.add('Se tornou $cargo');
        }

        break;
      }
    }
}

void checkRandomEvent() {
    final chance = random.nextInt(100);
    if (chance < 20) {
      showRandomDialog();
    }
}

  void showRandomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('🤔 Evento Aleatório', style: TextStyle(color: Colors.amber)),
        content: const Text(
          'Você foi convidado para uma reunião surpresa do clube. Deseja participar?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              applyChanges({'xp': 10, 'felicidade': 5}, 'Participou de uma reunião surpresa do clube.');
            },
            child: const Text('Participar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              story.add("${DateTime.now().year + idade.floor() - 18}: Você ignorou uma reunião do clube.");
            },
            child: const Text('Ignorar'),
          ),
        ],
      ),
    );
  }

  Widget statusIcon(IconData icon, String value, String keyName) {
    final animation = statusAnimations[keyName]!;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Column(
            children: [
              Icon(icon, color: Colors.amber, size: 28),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildStatusBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        statusIcon(Icons.attach_money, dinheiro.toString(), 'dinheiro'),
        statusIcon(Icons.school, inteligencia.toString(), 'inteligencia'),
        statusIcon(Icons.favorite, saude.toString(), 'saude'),
        statusIcon(Icons.emoji_emotions, felicidade.toString(), 'felicidade'),
        statusIcon(Icons.star, xp.toString(), 'xp'),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBarWithActions(
  title: 'C. LEO - ${widget.nome}',
  actions: [
    IconButton(
      icon: const Icon(Icons.person),
      onPressed: () {
              navigateWithTransition(
                context,
                ProfileScreen(
                  dinheiro: dinheiro,
                  inteligencia: inteligencia,
                  felicidade: felicidade,
                  saude: saude,
                  xp: xp,
                  idade: idade.floor(),
                  cargo: cargo,
                ),
              );
            },
    ),
    IconButton(
        icon: const Icon(Icons.emoji_events),
  onPressed: () {
    navigateWithTransition(
      context,
      ConquistasScreen(conquistas: conquistas),
    );
  },
    ),
  ],
),
      body: AnimatedBuilder(
        animation: _colorController,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorAnimation1.value ?? Colors.black,
                      colorAnimation2.value ?? Colors.black,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Header com Status
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.white.withOpacity(0.05),
                            padding: const EdgeInsets.all(12),
                            child: buildStatusBar(),
                          ),
                        ),
                      ),
                    ),
                    // Feed
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: story.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  color: Colors.white.withOpacity(0.05),
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    story[index],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Botões
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                navigateWithTransition(
                                  context,
                                  ActionsScreen(
                                      onActionSelected: applyChanges,
                                      onShowInfo: (info) => showDialogMessage('Info: ',info),
                                  ),
                                );
                              },
                              child: const Text(
                                'Escolher Ação',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(16),
                            ),
                            onPressed: () {},
                            child:
                                const Icon(Icons.refresh, color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // 🎆 Partículas de Confete
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: [Colors.amber, Colors.white, Colors.orange],
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    gravity: 0.2,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}