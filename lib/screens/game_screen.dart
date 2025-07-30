import 'dart:math';
import 'dart:ui';
import 'package:bitleo/screens/name_screen.dart';
import 'package:bitleo/services/CooldownHelper.dart';
import 'package:bitleo/services/action_messages.dart';
import 'package:bitleo/services/firestore_service.dart';
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

  @override
  void initState() {
    super.initState();
    final int anoReal = DateTime.now().year;
    anoAtual = anoReal;
    anoAnterior = anoReal;

    () async {
      await FirestoreService.verificarInicializacao();

      final viuTutorial = await FirestoreService.carregarTutorialVisto();
      if (!viuTutorial) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showTutorial();
        });
      }

      final results = await Future.wait([
        FirestoreService.carregarStatus(),
        FirestoreService.carregar(),
        FirestoreService.carregarDistribuicaoInicial(),
        FirestoreService.carregarPontos(),
        FirestoreService.carregarUltimoXPParaPontos(),
        FirestoreService.carregarHistorico(),
      ]);

      final status = results[0] as Map<String, dynamic>;
      final dados = results[1] as Map<String, int>;
      final distribuiu = results[2] as bool;
      final p = results[3] as int;
      final ultimoXP = results[4] as int;
      final historico = results[5] as List<String>;
      final conquistasSalvas = await FirestoreService.carregarConquistas();
      final getTotalConquistas =
          await FirestoreService.conquistasDesbloqueadas();
      final conquistasResgatadasSalvas =
          await FirestoreService.conquistasResgatadas();
      String auxCargo = await FirestoreService.carregarCargo();
      await FirestoreService.marcarInicioDoJogo();

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
        story = historico;
        dadosCarregados = true;
        conquistasResgatadas = conquistasResgatadasSalvas;
        totalConquistasLista = getTotalConquistas.length;
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
      duration: const Duration(seconds: 2),
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

  void adicionarConquista(String conquista) {
    _confettiController.play();
    showAnimatedDialog('🏆 Nova Conquista!', conquista);

    if (!conquistas.contains(conquista)) {
      setState(() {
        conquistas.add(conquista);
        totalConquistasLista++;
      });
    }
  }

  void salvarDadosStatus() {
    FirestoreService.salvarStatus({
      'dinheiro': dinheiro,
      'inteligencia': inteligencia,
      'felicidade': felicidade,
      'saude': saude,
      'idade': idade,
      'xp': xp,
      'cargo': cargo,
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.tune,
                            size: 48,
                            color: Color(0xFFE1BEE7),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Distribua Seus Pontos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFD1B3FF),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Pontos restantes: $pontosDeAtributo',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
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
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    onPressed: pontosDeAtributo > 0
                                        ? () {
                                            // Atualiza modal e estado principal
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
                          }),
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
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Pontos Restantes'),
                                      content: Text(
                                        'Você ainda tem $pontosDeAtributo ponto(s) não distribuído(s).\nDeseja continuar mesmo assim?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text('Confirmar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (continuar != true) return;
                                }
                                if (!dadosCarregados) return;
                                Navigator.of(context).pop();

                                await FirestoreService.salvar(atributos);
                                await FirestoreService.salvarPontos(
                                  pontosDeAtributo,
                                );
                                await FirestoreService.salvarDistribuicaoInicial(
                                  true,
                                );
                                await FirestoreService.desbloquear(
                                  "Estrategista",
                                );
                                adicionarConquista("Estrategista");
                                adicionarAoFeed(
                                  "Nova conquista desbloqueada: Estrategista! 🎉",
                                );
                                setState(() {
                                  distribuiuPontosIniciais = true;
                                });
                              },
                              child: const Text(
                                'Confirmar',
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
    final int minimoAcoesEntreEventos = 3;
    final trimestreAtual = ((idade * 100).floor() % 100) ~/ 20 + 1;

    if (eventoDoTrimestreJaMostrado[trimestreAtual] == true ||
        totalAcoesDesdeInicioTrimestre < minimoAcoesEntreEventos) {
      return;
    }

    for (var evento in trimestreEvento.keys) {
      if (trimestreEvento[evento] == trimestreAtual &&
          !eventosMostradosPorTrimestre[trimestreAtual]!.contains(evento)) {
        eventosMostradosEsteAno.add(evento);
        eventosMostradosPorTrimestre[trimestreAtual]!.add(evento);
        ultimaOcorrenciaEvento[evento] = idade;
        eventoDoTrimestreJaMostrado[trimestreAtual] = true;
        showEventoEspecial(evento, contaComoAcao: false);
        break;
      }
    }
  }

  Future<void> adicionarAoFeed(String texto) async {
    setState(() {
      story.add(texto);
    });
    await Future.delayed(const Duration(milliseconds: 100));
    await FirestoreService.salvarHistorico(story);
  }

  void applyChanges(AcaoTipo tipo, Map<String, dynamic> selected) async {
    if (!dadosCarregados || isProcessing) return;
    setState(() => isProcessing = true);

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
                  fontFamily: 'Poppins',
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

    if (dinheiro + gasto < 0) {
      adicionarAoFeed(
        "$anoAtual: Quis participar, mas não tinha dinheiro suficiente para a ação.",
      );
      await FirestoreService.salvarHistorico(story);
      setState(() => isProcessing = false);
      return;
    }

    final pontos = ((selected['xp'] ?? 0) as num).toInt();
    xp += pontos;

    int ganho = ((xp - xpAnteriorParaPontos) ~/ 15);
    if (ganho > 0) {
      pontosDeAtributo += ganho;
      xpAnteriorParaPontos += ganho * 15;
      triggerStatusAnim('atributos');
      FirestoreService.salvarUltimoXPParaPontos(xpAnteriorParaPontos);
    }

    FirestoreService.salvar(atributos);
    FirestoreService.salvarPontos(pontosDeAtributo);

    dinheiro += gasto;
    final intel = ((selected['inteligencia'] ?? 0) as num).toInt();
    inteligencia += intel;
    final feliz = ((selected['felicidade'] ?? 0) as num).toInt();
    felicidade += feliz;
    final vida = ((selected['saude'] ?? 0) as num).toInt();
    saude += vida;
    idade += 0.01;

    bool contaComoAcao = selected['contaComoAcao'] ?? true;
    if (contaComoAcao) {
      acoesDesdeUltimoEvento++;
      totalAcoesDesdeInicioTrimestre++;
    }

    FirestoreService.salvarStatus({
      'dinheiro': dinheiro,
      'inteligencia': inteligencia,
      'felicidade': felicidade,
      'saude': saude,
      'xp': xp,
      'idade': idade,
      'cargo': cargo,
    });

    atualizarAno();
    await adicionarAoFeed(
      "$anoAtual: ${ActionMessageHelper.getRandomMessage(tipo)}",
    );

    final conquistasAntes = await FirestoreService.conquistasDesbloqueadas();

    // checagem das conquistas
    await FirestoreService.checarDesbloqueios(
      xp: xp,
      acoes: totalAcoesDesdeInicioTrimestre,
      oratoria: atributos['Oratória'],
      saude: saude,
      felicidadeAlta: felicidade > 80 ? 5 : 0,
      pontosDistribuidos: distribuiuPontosIniciais && pontosDeAtributo == 0,
      turnosJogando: ((idade - 18) * 100).floor(),
    );

    final conquistasDepois = await FirestoreService.conquistasDesbloqueadas();

    for (final nome in conquistasDepois.difference(conquistasAntes)) {
      adicionarConquista(nome);
      adicionarAoFeed("$anoAtual: Conquista desbloqueada: $nome 🎉");
    }
    setState(() {
      if (gasto != 0) triggerStatusAnim('dinheiro');
      if (intel != 0) triggerStatusAnim('inteligencia');
      if (feliz != 0) triggerStatusAnim('felicidade');
      if (vida != 0) triggerStatusAnim('saude');
      checkEventoTrimestral();
      updateCargo();
      isProcessing = false;
    });
  }

  void triggerStatusAnim(String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    statusControllers[status]?.forward(from: 0);
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
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
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
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
      onPrimaryPressed: () {
        setState(() async {
          cargo = novoCargo;
          await FirestoreService.salvarCargo(novoCargo);
          adicionarConquista("Se tornou $cargo");
          adicionarAoFeed(
            "$anoAtual: Aceitou o desafio e assumiu o cargo de $cargo com entusiasmo.",
          );
          _confettiController.play();
        });
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

  void showEventoEspecial(String nomeEvento, {bool contaComoAcao = true}) {
    final Map<String, String> descricoesEventos = {
      'EventoEspecialJALC':
          'Jornada de Aprendizado e Liderança do Clube. Um dos maiores eventos de formação.',
      'EventoEspecialSEDEL':
          'Seminário de Desenvolvimento de Lideranças. Fortaleça competências e valores.',
      'EventoEspecialACAMPALEO':
          'Acampamento LEO de integração com outros clubes.',
      'EventoEspecialEncontro de Região':
          'Reunião entre clubes da região para alinhar projetos.',
      'EventoEspecialCONFE':
          'Conferência Final. Celebração anual dos resultados.',
    };

    final descricao =
        descricoesEventos[nomeEvento] ?? 'Evento especial do clube.';

    AcaoTipo tipoEvento = AcaoTipo.values.firstWhere(
      (e) => e.name == 'EventoEspecial${nomeEvento.replaceAll(' ', '')}',
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
            constraints: const BoxConstraints(
              maxWidth: 400, // 👈 Máximo 400px de largura
            ),
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
                        'Evento Especial',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFD1B3FF),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        descricao,
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
                                "$anoAtual: Recusou o evento $nomeEvento.",
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
                            onPressed: () {
                              Navigator.pop(context);
                              applyChanges(tipoEvento, {
                                'xp': 15,
                                'felicidade': 10,
                                'dinheiro': -30,
                                'contaComoAcao': contaComoAcao,
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

  void showTutorial() {
    final List<Map<String, String>> paginas = [
      {
        'titulo': 'Bem-vindo!',
        'texto': 'Aqui você acompanha sua jornada dentro do LEO Clube.',
      },
      {
        'titulo': 'Escolher Ação',
        'texto':
            'Toque em "Nova Ação" no botão flutuante para avançar e viver novas experiências!',
      },
      {
        'titulo': 'Status',
        'texto': 'Seus atributos aumentam conforme suas ações. Fique de olho!',
      },
      {
        'titulo': 'Distribua Pontos',
        'texto':
            'Toque no botão de perfil quando tiver pontos disponíveis para evoluir seus atributos.',
      },
      {
        'titulo': 'Conquistas',
        'texto': 'Desbloqueie marcos e veja tudo o que já conquistou!',
      },
    ];

    int currentIndex = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final page = paginas[currentIndex];
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
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.school,
                            size: 48,
                            color: Color(0xFFE1BEE7),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page['titulo']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFD1B3FF),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page['texto']!,
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
      },
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
    final List<Map<String, dynamic>> statusItems = [
      {
        'icon': Icons.attach_money,
        'label': 'Dinheiro',
        'value': dinheiro.toString(),
        'key': 'dinheiro',
      },
      {
        'icon': Icons.school,
        'label': 'Inteligência',
        'value': inteligencia.toString(),
        'key': 'inteligencia',
      },
      {
        'icon': Icons.favorite,
        'label': 'Saúde',
        'value': saude.toString(),
        'key': 'saude',
      },
      {
        'icon': Icons.emoji_emotions,
        'label': 'Felicidade',
        'value': felicidade.toString(),
        'key': 'felicidade',
      },
      {'icon': Icons.star, 'label': 'XP', 'value': xp.toString(), 'key': 'xp'},
      {
        'icon': Icons.fitness_center,
        'label': 'Atributos',
        'value': '$pontosDeAtributo',
        'key': 'atributos',
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statusItems.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SizedBox(
              width: 90, // <-- define largura igual para todos
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: statusIconWithLabel(
                  item['icon'] as IconData,
                  item['value'] as String,
                  item['label'] as String,
                  item['key'] as String,
                ),
              ),
            ),
          );
        }).toList(),
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
    if (info == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Text(
            '🎉 Você já atingiu o cargo máximo!',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    final nome = info['nome'];
    final xpNecessario = info['xp'] as int;
    final requisitos = info['requisitos'] as Map<String, int>;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 Objetivo Atual: $nome',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'XP necessário: $xpNecessario (atual: $xp)',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            ...requisitos.entries.map(
              (e) => Text(
                '${e.key}: ${atributos[e.key] ?? 0}/${e.value}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
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
    String userCargo = await FirestoreService.carregarCargo();
    return userCargo;
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
                  pageBuilder: (_, __, ___) =>
                      ProfileScreen(userCargo: cargo, nome: widget.nome),
                  transitionsBuilder: (_, animation, __, child) {
                    const curve = Curves.easeInOut;
                    final tween = Tween(
                      begin: 0.0,
                      end: 1.0,
                    ).chain(CurveTween(curve: curve));
                    return FadeTransition(
                      opacity: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              ).then((_) async {
                final novosAtributos = await FirestoreService.carregar();
                final novosPontos = await FirestoreService.carregarPontos();
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
                final novosPontos = await FirestoreService.carregarPontos();
                final conquistasAtualizadas =
                    await FirestoreService.conquistasDesbloqueadas();
                final conquistasResgatadasAtualizadas =
                    await FirestoreService.conquistasResgatadas();
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
                final tipo = AcaoTipo.values.firstWhere(
                  (e) => e.name == label.replaceAll(' ', ''),
                  orElse: () => AcaoTipo.Trabalhar,
                );
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
                    buildObjetivoWidget(),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: story.length,
                            itemBuilder: (context, index) {
                              final reversedStory = story.reversed.toList();
                              final texto = reversedStory[index];
                              final partes = texto.split(': ');
                              final ano = partes.first;
                              final descricao = partes.length > 1
                                  ? partes.sublist(1).join(': ')
                                  : '';
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.event_note,
                                      color: Color(0xFFD1B3FF),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ano,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Color(0xFFE1BEE7),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            descricao,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
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
