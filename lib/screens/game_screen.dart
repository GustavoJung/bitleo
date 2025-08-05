import 'dart:math';
import 'dart:ui';
import 'package:bitleo/screens/name_screen.dart';
import 'package:bitleo/services/CooldownHelper.dart';
import 'package:bitleo/services/action_messages.dart';
import 'package:bitleo/services/firestore_service.dart';
import 'package:bitleo/widgets/animated_story_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<String> story = [];

  int dinheiro = 30;
  int inteligencia = 5;
  int felicidade = 70;
  int saude = 70;
  double idade = 18;
  int xp = 0;
  late int anoAtual;
  int anoAnterior = 0;
  int xpAnteriorParaPontos = 0;
  int acoesDesdeUltimoEvento = 0;
  int totalAcoesDesdeInicioTrimestre = 0;
  int descansosSeguidos = 0;
  int diasJogados = 0;
  Set<String> eventosMostradosEsteAno = {};
  Map<String, int> acoesExecutadasEsteAno = {};
  Map<String, int> trimestreEvento = {
    'JALC': 1,
    'SEDEL': 2,
    'ACAMPALEO': 3,
    'Encontro de Região': 4,
    'CONFE': 4,
  };
  Map<String, double> ultimaOcorrenciaEvento = {
    'JALC': 0,
    'SEDEL': 0,
    'ACAMPALEO': 0,
    'Encontro de Região': 0,
    'CONFE': 0,
  };
  Map<int, bool> eventoDoTrimestreJaMostrado = {
    1: false,
    2: false,
    3: false,
    4: false,
  };
  Map<int, Set<String>> eventosMostradosPorTrimestre = {
    1: {},
    2: {},
    3: {},
    4: {},
  };
  String cargo = 'Pré-LEO';
  String clube = "";
  String? ultimoCargoOferecido;
  String regiao = 'Região Alpha';
  String distrito = 'Distrito Z';
  String regiaoDesc =
      'Uma das regiões mais ativas do nosso universo LEO, cheia de clubes dedicados.';
  String distritoDesc =
      'Esse distrito fictício é conhecido por organizar os melhores eventos!';

  final random = Random();
  final ScrollController _scrollController = ScrollController();
  Map<String, int> cargosRecusados = {};
  List<String> conquistas = [];
  List<String> conquistasResgatadas = [];

  int totalConquistasLista = 0;
  Set<String> animatingStatus = {};
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late AnimationController _colorController;
  late Animation<Color?> colorAnimation1;
  late Animation<Color?> colorAnimation2;
  late ConfettiController _confettiController;

  late Map<String, AnimationController> statusControllers;
  late Map<String, Animation<double>> statusAnimations;
  String animatedStatus = '';
  int pontosDeAtributo = 3;
  bool distribuiuPontosIniciais = false;
  Map<String, int> atributos = {
    'Oratória': 0,
    'Liderança': 0,
    'Empatia': 0,
    'Organização': 0,
  };
  bool isProcessing = false;
  bool dadosCarregados = false;
  late final List<Map<String, dynamic>> cargos = [
    {
      'xp': 50,
      'nome': 'Membro',
      'requisitos': {'Oratória': 5},
    },
    {
      'xp': 80,
      'nome': 'Diretor Social',
      'requisitos': {'Empatia': 10},
    },
    {
      'xp': 110,
      'nome': 'Diretor de Marketing',
      'requisitos': {'Oratória': 15, 'Organização': 10},
    },
    {
      'xp': 140,
      'nome': 'Diretor de Campanhas',
      'requisitos': {'Liderança': 15},
    },
    {
      'xp': 180,
      'nome': 'Tesoureiro',
      'requisitos': {'Organização': 20},
    },
    {
      'xp': 220,
      'nome': 'Secretário',
      'requisitos': {'Oratória': 20, 'Organização': 25},
    },
    {
      'xp': 260,
      'nome': 'Vice-Presidente',
      'requisitos': {'Liderança': 30, 'Oratória': 25},
    },
    {
      'xp': 300,
      'nome': 'Presidente',
      'requisitos': {
        'Liderança': 40,
        'Oratória': 35,
        'Empatia': 30,
        'Organização': 30,
      },
    },
  ];
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    final int anoReal = DateTime.now().year;
    anoAtual = anoReal;
    anoAnterior = anoReal;

    () async {
      await FirestoreService.verificarInicializacao(uid);

      final viuTutorial = await FirestoreService.carregarTutorialVisto(uid);
      if (!viuTutorial) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showTutorial();
        });
      }

      final results = await Future.wait([
        FirestoreService.carregarStatus(uid),
        FirestoreService.carregarAtributos(uid),
        FirestoreService.carregarDistribuicaoInicial(uid),
        FirestoreService.carregarPontos(uid),
        FirestoreService.carregarUltimoXPParaPontos(uid),
        FirestoreService.carregarHistorico(uid),
      ]);

      final status = results[0] as Map<String, dynamic>;
      final dados = results[1] as Map<String, int>;
      final distribuiu = results[2] as bool;
      final p = results[3] as int;
      final ultimoXP = results[4] as int;
      final historico = results[5] as List<String>;
      final conquistasSalvas = await FirestoreService.carregarConquistas(uid);
      final getTotalConquistas = await FirestoreService.conquistasDesbloqueadas(
        uid,
      );
      final conquistasResgatadasSalvas =
          await FirestoreService.conquistasResgatadas(uid);
      String auxCargo = await FirestoreService.carregarCargo(uid);
      await FirestoreService.marcarInicioDoJogo(uid);
      final loadClube = await FirestoreService.getNomeClube(uid);
      final dadosAcoes = await FirestoreService.carregarAcoesExecutadasEsteAno(
        uid,
      );
      setState(() {
        dinheiro = status['dinheiro'] ?? dinheiro;
        inteligencia = status['inteligencia'] ?? inteligencia;
        felicidade = status['felicidade'] ?? felicidade;
        saude = status['saude'] ?? saude;
        xp = status['xp'] ?? xp;
        idade = (status['idade'] ?? idade).toDouble();
        cargo = auxCargo;
        conquistas = conquistasSalvas;
        atributos = dados;
        distribuiuPontosIniciais = distribuiu;
        pontosDeAtributo = p;
        xpAnteriorParaPontos = ultimoXP;
        for (var item in historico.reversed) {
          story.insert(0, item);
          _listKey.currentState?.insertItem(0);
        }
        dadosCarregados = true;
        conquistasResgatadas = conquistasResgatadasSalvas;
        totalConquistasLista = getTotalConquistas.length;
        clube = loadClube!;
        acoesExecutadasEsteAno = Map<String, int>.from(dadosAcoes ?? {});
        diasJogados = status['diasJogados'] ?? 0;
      });

      updateCargo();
    }();

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    colorAnimation1 = ColorTween(
      begin: const Color(0xFF6A1B9A), // vinho escuro
      end: const Color(0xFF512DA8), // roxo intermediário
    ).animate(_colorController);

    colorAnimation2 = ColorTween(
      begin: const Color(0xFF512DA8),
      end: const Color(0xFF121212), // preto quase puro
    ).animate(_colorController);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    statusControllers = {
      'dinheiro': AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
      'inteligencia': AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
      'felicidade': AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
      'saude': AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
      'xp': AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
      'atributos': AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    };

    statusAnimations = {
      for (var key in statusControllers.keys)
        key:
            TweenSequence([
                  TweenSequenceItem(
                    tween: Tween(begin: 1.0, end: 1.3),
                    weight: 50,
                  ),
                  TweenSequenceItem(
                    tween: Tween(begin: 1.3, end: 1.0),
                    weight: 50,
                  ),
                ])
                .chain(CurveTween(curve: Curves.easeInOut))
                .animate(statusControllers[key]!),
    };
  }

  Future<void> adicionarConquista(String conquista) async {
    final conquistasFirebase = await FirestoreService.conquistasDesbloqueadas(
      uid,
    );

    // Se já está no Firebase, nem faz nada!
    if (conquistasFirebase.contains(conquista)) return;

    // Desbloqueia no Firestore e local só uma vez
    await FirestoreService.desbloquear(uid, conquista);

    setState(() {
      conquistas.add(conquista);
      totalConquistasLista++;
    });

    _confettiController.play();
    showAnimatedDialog('🏆 Nova Conquista!', conquista);
  }

  void salvarDadosStatus() {
    FirestoreService.salvarStatus(uid, {
      'dinheiro': dinheiro,
      'inteligencia': inteligencia,
      'felicidade': felicidade,
      'saude': saude,
      'idade': idade,
      'xp': xp,
      'cargo': cargo,
      'diasJogados': diasJogados,
    });
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

  Map<String, dynamic>? getProximoCargoInfo() {
    for (var c in cargos) {
      final nomeCargo = c['nome'];
      final xpRequerido = c['xp'];
      final requisitos = Map<String, int>.from(c['requisitos'] ?? {});
      bool cargoAtualEhInferior =
          cargos.indexWhere((e) => e['nome'] == cargo) < cargos.indexOf(c);

      if (cargoAtualEhInferior) {
        return {'nome': nomeCargo, 'xp': xpRequerido, 'requisitos': requisitos};
      }
    }
    return null; // Já está no cargo máximo
  }

  String getProximoCargoPreview() {
    for (var c in cargos) {
      final nomeCargo = c['nome'];
      final xpRequerido = c['xp'];
      final requisitos = Map<String, int>.from(c['requisitos'] ?? {});
      bool cargoAtualEhInferior =
          cargos.indexWhere((e) => e['nome'] == cargo) < cargos.indexOf(c);

      if (cargoAtualEhInferior) {
        final reqText = requisitos.entries
            .map((e) => "- ${e.key}: ${e.value}")
            .join('\n');
        return '''
Próximo Cargo: $nomeCargo
Requisitos:
- XP necessário: $xpRequerido
$reqText
''';
      }
    }
    return 'Você já atingiu o cargo máximo!';
  }

  void showDistribuicaoInicial() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Distribuição inicial',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, _, __) {
        final scale = Tween<double>(begin: 0.85, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );
        final fade = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E1E2E), Color(0xFF2A004F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.purpleAccent.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.tune,
                            size: 48,
                            color: Colors.amberAccent,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Distribua Seus Pontos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Hora de melhorar personagem. Evolua seus atributos!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.5,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Pontos restantes: $pontosDeAtributo',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...atributos.keys.map((key) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$key: ${atributos[key]}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    onPressed: pontosDeAtributo > 0
                                        ? () {
                                            setModalState(() {
                                              atributos[key] =
                                                  (atributos[key] ?? 0) + 1;
                                              pontosDeAtributo--;
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A1B9A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () async {
                                if (pontosDeAtributo > 0) {
                                  final continuar = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (ctx) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 24,
                                      ),
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 400,
                                          ), // <<< Limita a largura!
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              28,
                                            ),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 16,
                                                sigmaY: 16,
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  24,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xFF1E1E2E),
                                                          Color(0xFF2A004F),
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(28),
                                                  border: Border.all(
                                                    color: Colors.purpleAccent
                                                        .withOpacity(0.3),
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.purpleAccent
                                                          .withOpacity(0.3),
                                                      blurRadius: 20,
                                                      offset: const Offset(
                                                        0,
                                                        8,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      size: 44,
                                                      color: Colors.amberAccent,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    const Text(
                                                      'Pontos Restantes',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color:
                                                            Colors.amberAccent,
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        decoration:
                                                            TextDecoration.none,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      'Você ainda tem $pontosDeAtributo ponto(s) não distribuído(s).\nQuer continuar assim mesmo?',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 16,
                                                        height: 1.5,
                                                        decoration:
                                                            TextDecoration.none,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  ctx,
                                                                  false,
                                                                ),
                                                            child: const Text(
                                                              'Cancelar',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white70,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 16,
                                                        ),
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  const Color(
                                                                    0xFF6A1B9A,
                                                                  ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      24,
                                                                    ),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        12,
                                                                  ),
                                                            ),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  ctx,
                                                                  true,
                                                                ),
                                                            child: const Text(
                                                              'Confirmar',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  if (continuar != true) return;
                                }
                                if (!dadosCarregados) return;
                                Navigator.of(context).pop();
                                await FirestoreService.salvarProgressoConquista(
                                  uid,
                                  'Fala Bonita!',
                                  atributos['Oratória']!,
                                );
                                await FirestoreService.salvarAtributos(
                                  uid,
                                  atributos,
                                );
                                await FirestoreService.salvarPontos(
                                  uid,
                                  pontosDeAtributo,
                                );
                                await FirestoreService.salvarDistribuicaoInicial(
                                  uid,
                                  true,
                                );
                                final conquistasAntes =
                                    await FirestoreService.conquistasDesbloqueadas(
                                      uid,
                                    );
                                await FirestoreService.desbloquear(
                                  uid,
                                  "Estrategista",
                                );
                                final conquistasDepois =
                                    await FirestoreService.conquistasDesbloqueadas(
                                      uid,
                                    );

                                for (final nome in conquistasDepois.difference(
                                  conquistasAntes,
                                )) {
                                  adicionarConquista(nome);
                                  adicionarAoFeed(
                                    "Conquista desbloqueada: $nome 🎉",
                                  );
                                }
                                setState(() {
                                  distribuiuPontosIniciais = true;
                                });
                              },
                              child: const Text(
                                'Confirmar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void navigateWithTransition(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: curve));
          return FadeTransition(opacity: animation.drive(tween), child: child);
        },
      ),
    );
  }

  void showAnimatedDialog(String title, String message) {
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
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
                      const Icon(
                        Icons.emoji_events,
                        size: 48,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFD1B3FF),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Fechar',
                            style: TextStyle(
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
        );
      },
    );
  }

  void atualizarAno() {
    final int anoReal = DateTime.now().year;
    final int anosPassados = idade.floor() - 18;
    anoAtual = anoReal + anosPassados;
    if (anoAtual != anoAnterior) {
      anoAnterior = anoAtual;
      eventosMostradosEsteAno.clear();
      acoesExecutadasEsteAno.clear();
      eventoDoTrimestreJaMostrado.updateAll((_, __) => false);
      eventosMostradosPorTrimestre.updateAll((_, __) => {});
      totalAcoesDesdeInicioTrimestre = 0;
    }
  }

  void checkEventoTrimestral() {
    final int diasNoAno = 365;
    final List<String> eventosEspeciais = [
      'EventoEspecialJALC',
      'EventoEspecialSEDEL',
      'EventoEspecialACAMPALEO',
      'EventoEspecialEncontrodeRegiao',
      'EventoEspecialCONFE',
    ];
    int eventosNoAno = eventosEspeciais.length;
    int tamanhoFatia = (diasNoAno / eventosNoAno).floor();

    int diaDoAno = (diasJogados % diasNoAno) + 1;

    for (int i = 0; i < eventosNoAno; i++) {
      int inicioJanela = i * tamanhoFatia + 1;
      int fimJanela = (i == eventosNoAno - 1)
          ? diasNoAno
          : inicioJanela + tamanhoFatia - 1;

      // Só mostra se o evento não foi mostrado ainda esse ano, e está dentro da janela dele
      if (diaDoAno >= inicioJanela &&
          diaDoAno <= fimJanela &&
          !eventosMostradosEsteAno.contains(eventosEspeciais[i])) {
        eventosMostradosEsteAno.add(eventosEspeciais[i]);
        showEventoEspecial(eventosEspeciais[i], contaComoAcao: false);
        break; // Só mostra UM por chamada
      }
    }
  }

  Future<void> adicionarAoFeed(String texto) async {
    setState(() {
      story.insert(0, texto);
      _listKey.currentState?.insertItem(0);
    });
    await Future.delayed(const Duration(milliseconds: 100));
    await FirestoreService.salvarHistorico(uid, story);
  }

  void applyChanges(AcaoTipo tipo, Map<String, dynamic> selected) async {
    if (!dadosCarregados || isProcessing) return;
    setState(() => isProcessing = true);

    final conquistasAntes = await FirestoreService.conquistasDesbloqueadas(uid);
    final identificador = '${tipo.name}_${selected['nome']}';
    final ultimaAcao = await LocalCooldownStorage.carregarUltimaAcao();

    // Cooldown: evitar repetição
    if (identificador == ultimaAcao) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: const Color.fromARGB(255, 44, 3, 70),
            duration: const Duration(seconds: 2),
            content: SizedBox(
              width: double.infinity,
              child: Text(
                "Tente variar suas ações!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );

      setState(() => isProcessing = false);
      return;
    }

    await LocalCooldownStorage.salvarUltimaAcao(identificador);

    // Impeditivos
    if ((identificador.contains('trabalhar') ||
            identificador.contains('campanha')) &&
        saude < 30) {
      adicionarAoFeed(
        "$anoAtual: Você está exausto demais para essa ação. Cuide da sua saúde!",
      );
      setState(() => isProcessing = false);
      return;
    }

    if ((identificador.contains('campanha') ||
            identificador.contains('palestrar')) &&
        felicidade < 20) {
      adicionarAoFeed(
        "$anoAtual: Você está desmotivado demais para isso. Recupere sua felicidade!",
      );
      setState(() => isProcessing = false);
      return;
    }

    if (identificador.contains('palestrar') && inteligencia < 15) {
      adicionarAoFeed(
        "$anoAtual: Você precisa ser mais inteligente pra palestrar com confiança!",
      );
      setState(() => isProcessing = false);
      return;
    }

    // Salvar última ação
    await LocalCooldownStorage.salvarUltimaAcao(identificador);

    // Evento negativo aleatório (se saúde muito baixa)
    if (saude < 15 && (DateTime.now().millisecondsSinceEpoch % 4 == 0)) {
      adicionarAoFeed(
        "$anoAtual: Você ficou doente por negligenciar sua saúde. 😷",
      );
      saude -= 10;
      felicidade -= 5;
    }

    int gasto = ((selected['dinheiro'] ?? 0) as num).toInt();
    final pontos = ((selected['xp'] ?? 0) as num).toInt();
    xp += pontos;

    int ganho = ((xp - xpAnteriorParaPontos) ~/ 15);
    if (ganho > 0) {
      pontosDeAtributo += ganho;
      xpAnteriorParaPontos += ganho * 15;
      triggerStatusAnim('atributos');
      FirestoreService.salvarUltimoXPParaPontos(uid, xpAnteriorParaPontos);
    }

    FirestoreService.salvarAtributos(uid, atributos);
    FirestoreService.salvarPontos(uid, pontosDeAtributo);

    final acaoNome = tipo.name;
    acoesExecutadasEsteAno[acaoNome] =
        (acoesExecutadasEsteAno[acaoNome] ?? 0) + 1;

    await FirestoreService.salvarAcoesExecutadasEsteAno(
      uid,
      acoesExecutadasEsteAno,
    );

    dinheiro += gasto;
    final intel = ((selected['inteligencia'] ?? 0) as num).toInt();
    inteligencia += intel;
    inteligencia = inteligencia.clamp(0, 100);
    final feliz = ((selected['felicidade'] ?? 0) as num).toInt();
    felicidade += feliz;
    felicidade = felicidade.clamp(0, 100);
    final vida = ((selected['saude'] ?? 0) as num).toInt();
    saude += vida;
    saude = saude.clamp(0, 100);

    const int diasPorAcao = 5; // ou o valor que quiser
    diasJogados += diasPorAcao;
    atualizarAnoPorDias();

    if (saude <= 0) {
      await FirestoreService.desbloquear(uid, 'Zé Ruela');
    }
    if (dinheiro < 0) {
      await FirestoreService.desbloquear(uid, 'Endividado');
    }
    if (felicidade < 0) {
      await FirestoreService.desbloquear(uid, 'Detestado');
    }
    await FirestoreService.salvarProgressoConquista(
      uid,
      'Começando a Jornada',
      xp,
    );
    await FirestoreService.salvarProgressoConquista(
      uid,
      'Primeiro Passo de Liderança',
      xp,
    );
    await FirestoreService.salvarProgressoConquista(
      uid,
      'Ativo no clube',
      totalAcoesDesdeInicioTrimestre,
    );
    await FirestoreService.salvarProgressoConquista(uid, 'Cura Total', saude);

    switch (tipo) {
      case AcaoTipo.Trabalhar:
        await FirestoreService.incrementarProgressoConquista(uid, 'Workaholic');
        break;
      case AcaoTipo.Estudar:
        await FirestoreService.incrementarProgressoConquista(
          uid,
          'Estudante Aplicado',
        );
        break;
      case AcaoTipo.Campanha:
        await FirestoreService.incrementarProgressoConquista(
          uid,
          'Campeão de Campanha',
        );
        break;
      case AcaoTipo.OrganizarEvento:
        await FirestoreService.incrementarProgressoConquista(
          uid,
          'Organizador Profissional',
        );
        break;
      case AcaoTipo.ParticiparReuniao:
        await FirestoreService.incrementarProgressoConquista(
          uid,
          'Amigo de Todos',
        );
        break;
      case AcaoTipo.MentorarNovato:
        await FirestoreService.incrementarProgressoConquista(
          uid,
          'Mentor Sênior',
        );
        // Aqui pode desbloquear também a "Mentorando Novos LEOs" se for a primeira vez
        break;
      case AcaoTipo.RedesSociais:
        await FirestoreService.incrementarProgressoConquista(uid, 'Influencer');
        break;
      case AcaoTipo.ReuniaoDistrital:
        await FirestoreService.incrementarProgressoConquista(
          uid,
          'Amigo de Todos',
        );
        break;
      default:
        break;
    }

    acoesDesdeUltimoEvento++;
    totalAcoesDesdeInicioTrimestre++;
    await FirestoreService.incrementarProgressoConquista(uid, 'Ativo no clube');
    salvarDadosStatus();

    await adicionarAoFeed(
      "$anoAtual: ${ActionMessageHelper.getRandomMessage(tipo)}",
    );

    // checagem das conquistas
    await FirestoreService.checarDesbloqueios(
      uid: uid,
      xp: xp,
      acoes: totalAcoesDesdeInicioTrimestre,
      oratoria: atributos['Oratória'],
      saude: saude,
      felicidadeAlta: felicidade > 80 ? 5 : 0,
      pontosDistribuidos: distribuiuPontosIniciais && pontosDeAtributo == 0,
      empatia: atributos['Empatia'],
      lideranca: atributos['Liderança'],
      organizacao: atributos['Organização'],
      inteligencia: inteligencia,
      campanhas: acoesExecutadasEsteAno['Campanha'] ?? 0,
      estudou: acoesExecutadasEsteAno['Estudar'] ?? 0,
      trabalhou: acoesExecutadasEsteAno['Trabalhar'] ?? 0,
      mentorou: acoesExecutadasEsteAno['Mentorar Novato'] ?? 0,
      eventosOrganizados: acoesExecutadasEsteAno['Organizar Evento'] ?? 0,
      reunioesParticipadas:
          acoesExecutadasEsteAno['Participar de Reunião'] ?? 0,
      redesSociais: acoesExecutadasEsteAno['Redes Sociais'] ?? 0,
      reunioesDistritais: acoesExecutadasEsteAno['Reunião Distrital'] ?? 0,
    );

    final conquistasDepois = await FirestoreService.conquistasDesbloqueadas(
      uid,
    );

    for (final nome in conquistasDepois.difference(conquistasAntes)) {
      adicionarConquista(nome); // Sua função já evita duplicação local
      adicionarAoFeed("$anoAtual: Conquista desbloqueada: $nome 🎉");
    }
    setState(() {
      if (gasto != 0) triggerStatusAnim('dinheiro');
      if (intel != 0) triggerStatusAnim('inteligencia');
      if (feliz != 0) triggerStatusAnim('felicidade');
      if (vida != 0) triggerStatusAnim('saude');
      conquistas = conquistasDepois.toList();
      checkEventoTrimestral();
      updateCargo();
      isProcessing = false;
    });
  }

  void atualizarAnoPorDias() {
    final int anoInicial = DateTime.now().year;
    final int diasNoAno = 365; // pode ser mais chique e usar 366 se quiser kkk

    int anosPassados = diasJogados ~/ diasNoAno;
    int diaDoAno = (diasJogados % diasNoAno) + 1; // 1 a 365

    anoAtual = anoInicial + anosPassados;
    // Se quiser, exibe o dia também!
    print("Hoje é dia $diaDoAno de $anoAtual");
    // Aqui pode limpar coisas quando muda de ano, se precisar
    if (anoAtual != anoAnterior) {
      anoAnterior = anoAtual;
      eventosMostradosEsteAno.clear();
      acoesExecutadasEsteAno.clear();
      eventoDoTrimestreJaMostrado.updateAll((_, __) => false);
      eventosMostradosPorTrimestre.updateAll((_, __) => {});
      totalAcoesDesdeInicioTrimestre = 0;
    }
  }

  void triggerStatusAnim(String statusKey) {
    animatingStatus.add(statusKey);
    setState(() {});

    Future.delayed(const Duration(milliseconds: 600), () {
      animatingStatus.remove(statusKey);
      setState(() {});
    });
  }

  void checkConsequences() {
    if (felicidade <= 0) {
      showDialogMessage(
        '😢 Tristeza!',
        'Sua felicidade está muito baixa. Cuide do seu bem-estar!',
      );
    }
    if (saude <= 0) {
      showDialogMessage(
        '🏥 Problema de Saúde!',
        'Sua saúde está crítica. Você precisa descansar e se cuidar!',
      );
    }
    if (dinheiro <= 0) {
      showDialogMessage(
        '💸 Falência!',
        'Você ficou sem dinheiro. Faça trabalhos ou organize eventos para arrecadar fundos!',
      );
    }
  }

  Future<void> showCustomDialog({
    required IconData icon,
    required String title,
    required String description,
    String? secondaryText,
    String primaryButtonText = 'Entendi',
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ), // 👈 Largura máxima aqui
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
                        Icon(icon, size: 48, color: const Color(0xFFE1BEE7)),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFD1B3FF),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        if (secondaryText != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            secondaryText,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (secondaryButtonText != null)
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (onSecondaryPressed != null) {
                                    onSecondaryPressed();
                                  }
                                },
                                child: Text(
                                  secondaryButtonText,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6A1B9A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (onPrimaryPressed != null) {
                                    onPrimaryPressed();
                                  }
                                },
                                child: Text(
                                  primaryButtonText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showDialogMessage(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
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
                      const Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Color(0xFFE1BEE7),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFD1B3FF),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Entendi',
                            style: TextStyle(
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
        );
      },
    );
  }

  void _oferecerPromocao(
    String novoCargo,
    int xpNecessario,
    Map<String, int> requisitos,
  ) {
    final anoAtual = DateTime.now().year + idade.floor() - 18;
    final requisitosTexto = requisitos.entries
        .map((e) => "- ${e.key}: ${atributos[e.key] ?? 0}/${e.value}")
        .join('\n');

    showCustomDialog(
      icon: Icons.star,
      title: 'Nova Oportunidade!',
      description: 'Você atingiu os requisitos para o cargo de $novoCargo!',
      secondaryText:
          '📈 XP atual: $xp / Requerido: $xpNecessario\n\nRequisitos:\n$requisitosTexto',
      primaryButtonText: 'Aceitar',
      onPrimaryPressed: () async {
        setState(() {
          cargo = novoCargo;
        });
        await FirestoreService.salvarCargo(uid, novoCargo);
        adicionarConquista("Se tornou $novoCargo");
        await adicionarAoFeed(
          "$anoAtual: Aceitou o desafio e assumiu o cargo de $novoCargo com entusiasmo.",
        );
        _confettiController.play();
      },
      secondaryButtonText: 'Recusar',
      onSecondaryPressed: () {
        setState(() {
          xp = (xp / 2).floor();
          cargosRecusados[novoCargo] = anoAtual;
          adicionarAoFeed(
            "$anoAtual: Recusou a chance de se tornar $novoCargo e perdeu metade do XP.",
          );
        });
      },
    );
  }

  void updateCargo() {
    final anoAtual = DateTime.now().year + idade.floor() - 18;

    for (var c in cargos) {
      final String nomeCargo = c['nome'];
      final int xpReq = c['xp'];
      final requisitos = Map<String, int>.from(c['requisitos'] ?? {});

      final elegivel =
          xp >= xpReq &&
          requisitos.entries.every((e) => (atributos[e.key] ?? 0) >= e.value);

      final cargoAtualEhInferior =
          cargos.indexWhere((e) => e['nome'] == cargo) < cargos.indexOf(c);

      final recusadoRecentemente =
          (cargosRecusados[nomeCargo] ?? 0) >= anoAtual;

      if (elegivel &&
          cargoAtualEhInferior &&
          nomeCargo != ultimoCargoOferecido &&
          !recusadoRecentemente) {
        ultimoCargoOferecido = nomeCargo;
        _oferecerPromocao(nomeCargo, xpReq, requisitos);
        break;
      }
    }
  }

  void showRandomDialog() {
    final anoAtual = DateTime.now().year + idade.floor() - 18;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
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
                      const Icon(
                        Icons.event,
                        size: 48,
                        color: Color(0xFFE1BEE7),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Evento Aleatório',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFD1B3FF),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Você foi convidado para uma reunião surpresa do clube. Deseja participar?',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              adicionarAoFeed(
                                "$anoAtual: Você ignorou uma reunião do clube.",
                              );
                            },
                            child: const Text(
                              'Ignorar',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 20,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              applyChanges(AcaoTipo.ParticiparReuniao, {
                                'xp': 10,
                                'felicidade': 5,
                              });
                            },
                            child: const Text(
                              'Participar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String padronizarNomeEvento(String nomeEvento) {
    if (!nomeEvento.startsWith('EventoEspecial')) {
      return 'EventoEspecial${nomeEvento.replaceAll(' ', '')}';
    }
    return nomeEvento.replaceAll(' ', '');
  }

  void showEventoEspecial(String nomeEvento, {bool contaComoAcao = true}) {
    // Mapa com nomes bonitinhos e descrições dos eventos
    final Map<String, Map<String, String>> eventosDetalhes = {
      'EventoEspecialJALC': {
        'titulo': 'JALC',
        'descricao':
            'Jogos Anuais de LEO Clube. Evento esportivo com disputa sadia e novas amizades.',
      },
      'EventoEspecialSEDEL': {
        'titulo': 'SEDEL',
        'descricao':
            'Seminário de Desenvolvimento de Lideranças. Fortaleça competências e valores.',
      },
      'EventoEspecialACAMPALEO': {
        'titulo': 'ACAMPALEO',
        'descricao': 'Acampamento LEO de integração com outros clubes.',
      },
      'EventoEspecialEncontrodeRegião': {
        'titulo': 'Encontro de Região',
        'descricao':
            'Reunião entre clubes da região com disputas artísticas e definições de eventos.',
      },
      'EventoEspecialCONFE': {
        'titulo': 'CONFE',
        'descricao':
            'Conferência anual. Celebração dos resultados e premiações.',
      },
    };
    final nomeEventoPadrao = padronizarNomeEvento(nomeEvento);
    Map<String, String>? detalhesEvento;
    for (var key in eventosDetalhes.keys) {
      if (key.toLowerCase().replaceAll(' ', '') ==
          nomeEventoPadrao.toLowerCase().replaceAll(' ', '')) {
        detalhesEvento = eventosDetalhes[key];
        break;
      }
    }
    final evento =
        detalhesEvento ??
        {'titulo': nomeEventoPadrao, 'descricao': 'Evento especial do clube.'};

    // Pega o tipo do evento na enum
    AcaoTipo tipoEvento = AcaoTipo.values.firstWhere(
      (e) => e.name == nomeEventoPadrao,
      orElse: () => AcaoTipo.Campanha,
    );

    final anoAtual = DateTime.now().year + idade.floor() - 18;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
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
                      const Icon(
                        Icons.event,
                        size: 48,
                        color: Color(0xFFE1BEE7),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        evento['titulo'] ?? 'Evento Especial',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFD1B3FF),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        evento['descricao'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Custa 30 de dinheiro.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              adicionarAoFeed(
                                "$anoAtual: Recusou o evento ${evento['titulo']}.",
                              );
                            },
                            child: const Text(
                              'Recusar',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 20,
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              if (dinheiro < 30) {
                                adicionarAoFeed(
                                  "$anoAtual: Você participou do evento, mas não tinha dinheiro e agora ficou devendo! Ganhou metade das recompensas.",
                                );

                                applyChanges(tipoEvento, {
                                  'xp': 7,
                                  'felicidade': 5,
                                  'dinheiro': -30,
                                  'contaComoAcao': contaComoAcao,
                                });
                              } else {
                                applyChanges(tipoEvento, {
                                  'xp': 15,
                                  'felicidade': 10,
                                  'dinheiro': -30,
                                  'contaComoAcao': contaComoAcao,
                                });
                              }
                            },
                            child: const Text(
                              'Participar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showTutorial() async {
    final List<Map<String, String>> paginas = [
      {
        'titulo': 'Bem-vindo(a) ao Jogo!',
        'texto':
            'Prepare-se para entrar na vida LEO Clube e conhecer alguns aspectos desse movimento que muda nossas vidas! ',
      },
      {
        'titulo': 'Como jogar',
        'texto':
            'Toque em "Nova atividade" pra começar a sua saga. Cada ação vale tempo e pode mudar seus atributos. Escolha com sabedoria… ou só vai clicando mesmo, ninguém vai te julgar (mentira, vai sim).',
      },
      {
        'titulo': 'Atributos e Status',
        'texto':
            'Fique de olho em dinheiro, inteligência, felicidade e saúde. Se um deles zerar, vai passar vergonha no clube… ou pior, perde o jogo!',
      },
      {
        'titulo': 'Distribua seus Pontos!',
        'texto':
            'Quando você ganhar pontos de atributo, o ícone de perfil vai aparecer com um badge. Clique lá e distribua seus pontinhos. É tipo montar personagem em RPG, só que ninguém vai te chamar de nerd (só eu, talvez).',
      },
      {
        'titulo': 'Conquistas',
        'texto':
            'Desbloqueie conquistas fazendo coisas legais. Se conseguir todas, me avisa pra eu te dar parabéns — ou pelo menos um emoji de foguinho. 🚀',
      },
    ];

    int currentIndex = 0;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Tutorial',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, _, __) {
        final fade = Tween<double>(begin: 0, end: 1).animate(animation);
        final scale = Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: Center(
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  final page = paginas[currentIndex];
                  final total = paginas.length;

                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E1E2E), Color(0xFF2A004F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.purpleAccent.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.school,
                            size: 48,
                            color: Colors.amberAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page['titulo']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              decoration:
                                  TextDecoration.none, // SEM sublinhado!
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page['texto']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.5,
                              decoration:
                                  TextDecoration.none, // SEM sublinhado!
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Passo ${currentIndex + 1} de $total',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A1B9A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () async {
                                if (currentIndex < paginas.length - 1) {
                                  setModalState(() {
                                    currentIndex++;
                                  });
                                } else {
                                  Navigator.pop(context);
                                  await FirestoreService.salvarTutorialVisto(
                                    uid,
                                    true,
                                  );
                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );
                                  showDistribuicaoInicial();
                                }
                              },
                              child: Text(
                                currentIndex < paginas.length - 1
                                    ? 'Próximo'
                                    : 'Começar',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
    await FirestoreService.salvarProgressoConquista(uid, 'Cura Total', saude);
    await FirestoreService.checarDesbloqueios(
      uid: uid,
      xp: xp,
      acoes: totalAcoesDesdeInicioTrimestre,
      oratoria: atributos['Oratória'],
      saude: saude,
      felicidadeAlta: felicidade > 80 ? 5 : 0,
      pontosDistribuidos: distribuiuPontosIniciais && pontosDeAtributo == 0,
      empatia: atributos['Empatia'],
      lideranca: atributos['Liderança'],
      organizacao: atributos['Organização'],
      inteligencia: inteligencia,
      campanhas: acoesExecutadasEsteAno['Campanha'] ?? 0,
      estudou: acoesExecutadasEsteAno['Estudar'] ?? 0,
      trabalhou: acoesExecutadasEsteAno['Trabalhar'] ?? 0,
      mentorou: acoesExecutadasEsteAno['Mentorar Novato'] ?? 0,
      eventosOrganizados: acoesExecutadasEsteAno['Organizar Evento'] ?? 0,
      reunioesParticipadas:
          acoesExecutadasEsteAno['Participar de Reunião'] ?? 0,
      redesSociais: acoesExecutadasEsteAno['Redes Sociais'] ?? 0,
      reunioesDistritais: acoesExecutadasEsteAno['Reunião Distrital'] ?? 0,
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
              Icon(
                icon,
                color: const Color.fromARGB(255, 230, 192, 255),
                size: 28,
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          Tooltip(
            message: dinheiro.toString(),
            child: buildStatusBarItem(
              keyName: 'dinheiro',
              label: 'Dinheiro',
              color: Colors.green,
              icon: const Icon(
                Icons.attach_money,
                size: 22,
                color: Colors.green,
              ),
              value: dinheiro,
            ),
          ),
          Tooltip(
            message: inteligencia.toString(),
            child: buildStatusBarItem(
              keyName: 'inteligencia',
              label: 'Inteligência',
              color: Colors.blue,
              icon: const Icon(Icons.school, size: 22, color: Colors.blue),
              value: inteligencia,
              maxValue: 100,
            ),
          ),
          Tooltip(
            message: saude.toString(),
            child: buildStatusBarItem(
              keyName: 'saude',
              label: 'Saúde',
              color: Colors.red,
              icon: const Icon(Icons.favorite, size: 22, color: Colors.red),
              value: saude,
              maxValue: 100,
            ),
          ),
          Tooltip(
            message: felicidade.toString(),
            child: buildStatusBarItem(
              keyName: 'felicidade',
              label: 'Felicidade',
              color: Colors.amber,
              icon: const Text('😊', style: TextStyle(fontSize: 22)),
              value: felicidade,
              maxValue: 100,
            ),
          ),
          Tooltip(
            message: xp.toString(),
            child: buildStatusBarItem(
              keyName: 'xp',
              label: 'XP',
              color: Colors.purple,
              icon: const Icon(Icons.star, size: 22, color: Colors.purple),
              value: xp,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusBarItem({
    required String keyName,
    required String label,
    required Color color,
    required Widget icon,
    int? value,
    int? maxValue,
    String? labelText,
    bool forceNoBar = false,
  }) {
    final isXpOrDinheiro = keyName == 'xp' || keyName == 'dinheiro';
    final hasBar =
        !isXpOrDinheiro && maxValue != null && value != null && !forceNoBar;
    final percentage = hasBar ? (value! / maxValue!).clamp(0.0, 1.0) : 0.0;
    final isAnimating = animatingStatus.contains(keyName);

    return AnimatedScale(
      scale: isAnimating ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 32, height: 32, child: Center(child: icon)),
            const SizedBox(height: 8),
            if (hasBar)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              // Espaço reservado para deixar igual a altura dos outros
              SizedBox(height: 8),
            const SizedBox(height: 6),
            if (labelText != null)
              Text(
                labelText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              )
            else
              Text(
                '${value ?? 0}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statusIconWithLabel(
    IconData icon,
    String value,
    String label,
    String keyName,
  ) {
    final animation = statusAnimations[keyName]!;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: const Color.fromARGB(255, 230, 192, 255),
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildObjetivoWidget() {
    final info = getProximoCargoInfo();
    final borderStyle = BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );

    if (info == null) {
      return Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: borderStyle,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 Objetivo Atual:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'Você já atingiu o cargo máximo!',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final nome = info['nome'];
    final xpNecessario = info['xp'] as int;
    final requisitos = info['requisitos'] as Map<String, int>;

    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: borderStyle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),

          Text(
            'Objetivo Atual: $nome',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          SizedBox(height: 8),
          const SizedBox(height: 8),
          Text(
            'XP necessário: $xpNecessario (atual: $xp)',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),

          ...requisitos.entries.map(
            (e) => Text(
              '${e.key}: ${atributos[e.key] ?? 0}/${e.value}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildIconWithBadge({
    required IconData icon,
    required String tooltip,
    required int badgeCount,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          IconButton(icon: Icon(icon, size: 32), onPressed: onPressed),
          if (badgeCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<String> getUserCargo() async {
    String userCargo = await FirestoreService.carregarCargo(uid);
    return userCargo;
  }

  AcaoTipo getTipoFromLabel(String label) {
    switch (label) {
      case 'Trabalhar':
        return AcaoTipo.Trabalhar;
      case 'Estudar':
        return AcaoTipo.Estudar;
      case 'Campanha':
        return AcaoTipo.Campanha;
      case 'Descansar':
        return AcaoTipo.Descansar;
      case 'Organizar Evento':
        return AcaoTipo.OrganizarEvento;
      case 'Participar de Reunião':
        return AcaoTipo.ParticiparReuniao;
      case 'Mentorar Novato':
        return AcaoTipo.MentorarNovato;
      case 'Redes Sociais':
        return AcaoTipo.RedesSociais;
      default:
        return AcaoTipo.Trabalhar; // Fallback pra não explodir!
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBarWithActions(
        title: '${cargo ?? 'Carregando...'} ${widget.nome}',
        actions: [
          _buildIconWithBadge(
            icon: Icons.person,
            tooltip: pontosDeAtributo > 0
                ? 'Você tem pontos de atributos para distribuir!'
                : 'Ver perfil',
            badgeCount: pontosDeAtributo,
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (_, __, ___) => ProfileScreen(
                    userCargo: cargo,
                    nome: widget.nome,
                    clube: clube,
                    uid: uid,
                  ),
                  transitionsBuilder: (_, animation, __, child) {
                    final tween = Tween(
                      begin: 0.0,
                      end: 1.0,
                    ).chain(CurveTween(curve: Curves.easeInOut));
                    return FadeTransition(
                      opacity: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              ).then((_) async {
                final novosAtributos = await FirestoreService.carregarAtributos(
                  uid,
                );
                final novosPontos = await FirestoreService.carregarPontos(uid);
                setState(() {
                  atributos = novosAtributos;
                  pontosDeAtributo = novosPontos;
                });
                updateCargo();
              });
            },
          ),
          _buildIconWithBadge(
            icon: Icons.emoji_events,
            tooltip: 'Conquistas',
            badgeCount: (totalConquistasLista - conquistasResgatadas.length),
            onPressed: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ConquistasScreen()),
              );
              if (resultado == true) {
                final novosPontos = await FirestoreService.carregarPontos(uid);
                final conquistasAtualizadas =
                    await FirestoreService.conquistasDesbloqueadas(uid);
                final conquistasResgatadasAtualizadas =
                    await FirestoreService.conquistasResgatadas(uid);
                setState(() {
                  pontosDeAtributo = novosPontos;
                  totalConquistasLista = conquistasAtualizadas.length;
                  conquistasResgatadas = conquistasResgatadasAtualizadas;
                });
              }
            },
          ),
          OutlinedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const NameScreen()),
                (route) => false,
              );
            },
            icon: SizedBox(
              width: 28,
              height: 28,
              child: Image.asset('assets/images/out.png'),
            ),
            label: const Text(
              'Sair',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        label: const Text(
          'Nova atividade',
          style: TextStyle(
            color: Color(0xFF6A1B9A),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onPressed: () {
          navigateWithTransition(
            context,
            ActionsScreen(
              onActionSelected: (effects, label) {
                final tipo = getTipoFromLabel(label as String);
                applyChanges(tipo, effects);
              },
              onShowInfo: (info) => showDialogMessage('Informações', info),
              status: {
                'saude': saude,
                'felicidade': felicidade,
                'inteligencia': inteligencia,
                'dinheiro': dinheiro,
                'xp': xp,
              },
              atributos: atributos,
              uid: uid,
            ),
          );
        },
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _colorController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorAnimation1.value ?? const Color(0xFF6A1B9A),
                      colorAnimation2.value ?? const Color(0xFF121212),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [buildStatusBar(), buildObjetivoWidget()],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: AnimatedStoryList(
                            story: story,
                            listKey: _listKey,
                            scrollController: _scrollController,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                const Color(0xFFFFD54F),
                Colors.white,
                const Color(0xFFFF7043),
              ],
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
