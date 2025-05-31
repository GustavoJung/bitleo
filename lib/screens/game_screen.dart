import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'actions_screen.dart';
import 'profile_screen.dart';
import 'conquistas_screen.dart';
import '../widgets/custom_appbar.dart';
import '../services/atributos_storage.dart';

class GameScreen extends StatefulWidget {
  final String nome;

  const GameScreen({super.key, required this.nome});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  List<String> story = [];
 
  int dinheiro = 100;
  int inteligencia = 5;
  int felicidade = 50;
  int saude = 50;
  double idade = 18;
  int xp = 0;
  String cargo = 'Pré-LEO';
  String? ultimoCargoOferecido;
  String regiao = 'Região Alpha';
  String distrito = 'Distrito Z';
  String regiaoDesc = 'Uma das regiões mais ativas do nosso universo LEO, cheia de clubes dedicados.';
  String distritoDesc = 'Esse distrito fictício é conhecido por organizar os melhores eventos!';

  final random = Random();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _clubeController = TextEditingController();
  List<String> conquistas = [];

  late AnimationController _colorController;
  late Animation<Color?> colorAnimation1;
  late Animation<Color?> colorAnimation2;
  late ConfettiController _confettiController;

  late Map<String, AnimationController> statusControllers;
  late Map<String, Animation<double>> statusAnimations;
  String animatedStatus = '';
  int pontosDeAtributo = 0;
  Map<String, int> atributos = {
    'Oratória': 0,
    'Liderança': 0,
    'Empatia': 0,
    'Organização': 0,
  };

   late final List<Map<String, dynamic>> cargos = [
    {'xp': 50, 'nome': 'Membro', 'requisitos': {'Oratória': 5}},
    {'xp': 80, 'nome': 'Diretor Social', 'requisitos': {'Empatia': 10}},
    {'xp': 110, 'nome': 'Diretor de Marketing', 'requisitos': {'Oratória': 15, 'Organizacao': 10}},
    {'xp': 140, 'nome': 'Diretor de Campanhas', 'requisitos': {'Lideranca': 15}},
    {'xp': 180, 'nome': 'Tesoureiro', 'requisitos': {'Organizacao': 20}},
    {'xp': 220, 'nome': 'Secretário', 'requisitos': {'Oratória': 20, 'Organizacao': 25}},
    {'xp': 260, 'nome': 'Vice-Presidente', 'requisitos': {'Lideranca': 30, 'Oratória': 25}},
    {'xp': 300, 'nome': 'Presidente', 'requisitos': {'Lideranca': 40, 'Oratória': 35, 'Empatia': 30, 'Organizacao': 30}},
  ];

  @override
  void initState() {
    super.initState();

    AtributosStorage.carregar().then((dados) {
      setState(() => atributos = dados);
      updateCargo();
    });

    AtributosStorage.carregarPontos().then((p) {
      setState(() => pontosDeAtributo = p);
    });

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    colorAnimation1 = ColorTween(begin: const Color(0xFF0F2027), end: const Color(0xFF203A43)).animate(_colorController);
    colorAnimation2 = ColorTween(begin: const Color(0xFF203A43), end: const Color(0xFF2C5364)).animate(_colorController);

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

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

  String getProximoCargoPreview() {
  for (var c in cargos) {
    final nomeCargo = c['nome'];
    final xpRequerido = c['xp'];
    final requisitos = Map<String, int>.from(c['requisitos'] ?? {});
    bool cargoAtualEhInferior =
        cargos.indexWhere((e) => e['nome'] == cargo) < cargos.indexOf(c);

    if (cargoAtualEhInferior) {
      final reqText = requisitos.entries.map((e) => "- ${e.key}: ${e.value}").join('\n');
      return '''
Próximo Cargo: $nomeCargo
XP necessário: $xpRequerido
Requisitos:
$reqText
''';
    }
  }
  return 'Você já atingiu o cargo máximo!';
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
      showDialogMessage('Sem grana', 'Você não tem dinheiro suficiente.');
      return;
    }

    final pontos = ((selected['xp'] ?? 0) as num).toInt();
    xp += pontos;
    if (pontos != 0) {
      triggerStatusAnim('xp');
      pontosDeAtributo += (pontos ~/ 5);
      AtributosStorage.salvarPontos(pontosDeAtributo);
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

      idade += 0.05;

      story.add("${DateTime.now().year + idade.floor() - 18}: $description");

      updateCargo();
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
    for (var c in cargos) {
      final nomeCargo = c['nome'];
      final xpReq = c['xp'];
      final requisitos = Map<String, int>.from(c['requisitos'] ?? {});
      if (xp >= xpReq && requisitos.entries.every((e) => (atributos[e.key] ?? 0) >= e.value) && cargos.indexWhere((e) => e['nome'] == cargo) < cargos.indexOf(c) && nomeCargo != ultimoCargoOferecido) {
        ultimoCargoOferecido = nomeCargo;
        _oferecerPromocao(nomeCargo, xpReq, requisitos);
        break;
      }
    }
  }

void _oferecerPromocao(String novoCargo, int xpNecessario, Map<String, int> requisitos) {
    final requisitosTexto = requisitos.entries.map((e) => "- ${e.key}: ${atributos[e.key] ?? 0}/${e.value}").join('\n');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nova oportunidade: $novoCargo'),
        content: Text('Você atingiu os requisitos para o cargo de $novoCargo!\n\nRequisitos:\n$requisitosTexto\n\nDeseja aceitar a promoção?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                cargo = novoCargo;
                story.add("${DateTime.now().year + idade.floor() - 18}: Promovido(a) a $cargo!");
                _confettiController.play();
              });
            },
            child: const Text('Aceitar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                xp = (xp / 2).floor();
                story.add("${DateTime.now().year + idade.floor() - 18}: Recusou promoção para $novoCargo e perdeu metade do XP.");
              });
            },
            child: const Text('Recusar'),
          ),
        ],
      ),
    );
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
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => ProfileScreen(
        dinheiro: dinheiro,
        inteligencia: inteligencia,
        felicidade: felicidade,
        saude: saude,
        xp: xp,
        idade: idade.floor(),
        cargo: cargo,
        pontosDeAtributo: pontosDeAtributo,
      ),
      transitionsBuilder: (_, animation, __, child) {
        const curve = Curves.easeInOut;
        final tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
        return FadeTransition(opacity: animation.drive(tween), child: child);
      },
    ),
  ).then((_) async {
    final novosAtributos = await AtributosStorage.carregar();
final novosPontos = await AtributosStorage.carregarPontos();
setState(() {
  atributos = novosAtributos;
  pontosDeAtributo = novosPontos;
});
updateCargo(); // verificar promoção após voltar
  });
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
                    Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Colors.white.withOpacity(0.05),
        padding: const EdgeInsets.all(12),
        child: Text(
          getProximoCargoPreview(),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
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