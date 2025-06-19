import 'dart:math';
import 'dart:ui';
import 'package:bitleo/services/action_messages.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<String> story = [];

  int dinheiro = 100;
  int inteligencia = 5;
  int felicidade = 50;
  int saude = 50;
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
      await AtributosStorage.verificarInicializacao();

      final results = await Future.wait([
        AtributosStorage.carregarStatus(),
        AtributosStorage.carregar(),
        AtributosStorage.carregarDistribuicaoInicial(),
        AtributosStorage.carregarPontos(),
        AtributosStorage.carregarUltimoXPParaPontos(),
        AtributosStorage.carregarHistorico(),
      ]);

      final status = results[0] as Map<String, dynamic>;
      final dados = results[1] as Map<String, int>;
      final distribuiu = results[2] as bool;
      final p = results[3] as int;
      final ultimoXP = results[4] as int;
      final historico = results[5] as List<String>;
      final conquistasSalvas = await AtributosStorage.carregarConquistas();

      String auxCargo = await AtributosStorage.carregarCargo();

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
      });

      if (p == 3 && !distribuiu) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDistribuicaoInicial();
        });
      }

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

  void adicionarConquista(String conquista) async {
    if (!conquistas.contains(conquista)) {
      setState(() {
        conquistas.add(conquista);
      });
      await AtributosStorage.salvarConquistas(conquistas);
      showAnimatedDialog('🏆 Nova Conquista!', conquista);
    }
  }

  void salvarDadosStatus() {
    AtributosStorage.salvarStatus({
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
            return AlertDialog(
              backgroundColor: const Color(0xFF2E003E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Center(
                child: Text(
                  '🎯 Personalize seu Personagem',
                  style: TextStyle(
                    color: Color(0xFFD1B3FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pontos restantes: $pontosDeAtributo',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ...atributos.keys.map((key) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    setModalState(() {
                                      atributos[key] =
                                          (atributos[key] ?? 0) + 1;
                                    });
                                    setState(() {
                                      pontosDeAtributo--;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (pontosDeAtributo > 0) {
                      final continuar = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF3E1F47),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Pontos Restantes',
                            style: TextStyle(color: Color(0xFFD1B3FF)),
                          ),
                          content: Text(
                            'Você ainda tem $pontosDeAtributo ponto(s) não distribuído(s).\nDeseja continuar mesmo assim?',
                            style: const TextStyle(color: Colors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text(
                                'Confirmar',
                                style: TextStyle(color: Colors.greenAccent),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (continuar != true) return;
                    }
                    if (!dadosCarregados) return;
                    Navigator.of(context).pop();
                    await AtributosStorage.salvar(atributos);
                    await AtributosStorage.salvarPontos(pontosDeAtributo);
                    await AtributosStorage.salvarDistribuicaoInicial(true);
                    setState(() {
                      distribuiuPontosIniciais = true;
                    });
                  },
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      color: Color(0xFFD1B3FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E003E).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD1B3FF).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFD1B3FF),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Ok',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
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
        totalAcoesDesdeInicioTrimestre < minimoAcoesEntreEventos)
      return;

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
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    await AtributosStorage.salvarHistorico(story);
  }

  void applyChanges(AcaoTipo tipo, Map<String, dynamic> selected) async {
    if (!dadosCarregados || isProcessing) return;
    setState(() => isProcessing = true);

    int gasto = ((selected['dinheiro'] ?? 0) as num).toInt();

    if (dinheiro + gasto < 0) {
      adicionarAoFeed(
        "$anoAtual: Quis participar, mas não tinha dinheiro suficiente para a ação.",
      );
      await AtributosStorage.salvarHistorico(story);
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
      AtributosStorage.salvarUltimoXPParaPontos(xpAnteriorParaPontos);
    }

    AtributosStorage.salvar(atributos);
    AtributosStorage.salvarPontos(pontosDeAtributo);

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

    AtributosStorage.salvarStatus({
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

    ActionMessageHelper.aplicarConquistas(
      tipo: tipo,
      xp: xp,
      atributos: atributos,
      cargo: cargo,
      story: story,
      conquistasAtuais: conquistas,
      novaConquista: (conquista) {
        adicionarConquista(conquista); // salva e mostra confete
        adicionarAoFeed("$anoAtual: Conquista desbloqueada: $conquista 🎉");
      },
    );

    AtributosStorage.salvarConquistas(conquistas);

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

  void showDialogMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E003E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFD1B3FF),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.deepPurpleAccent),
            ),
          ),
        ],
      ),
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

  void _oferecerPromocao(
    String novoCargo,
    int xpNecessario,
    Map<String, int> requisitos,
  ) {
    final anoAtual = DateTime.now().year + idade.floor() - 18;
    final requisitosTexto = requisitos.entries
        .map((e) => "- ${e.key}: ${atributos[e.key] ?? 0}/${e.value}")
        .join('\n');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2E003E),
        title: Text(
          'Nova oportunidade: $novoCargo',
          style: const TextStyle(color: Color(0xFFD1B3FF)),
        ),
        content: Text(
          'Você atingiu os requisitos para o cargo de $novoCargo!\n\n'
          'XP atual: $xp / Requerido: $xpNecessario\n\n'
          'Requisitos de atributos:\n$requisitosTexto\n\n'
          'Deseja aceitar a promoção?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() async {
                cargo = novoCargo;
                await AtributosStorage.salvarCargo(novoCargo);
                adicionarConquista("Se tornou $cargo");
                adicionarAoFeed(
                  "$anoAtual: Aceitou o desafio e assumiu o cargo de $cargo com entusiasmo.",
                );
                _confettiController.play();
              });
            },
            child: const Text(
              'Aceitar',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                xp = (xp / 2).floor();
                cargosRecusados[novoCargo] = anoAtual;
                adicionarAoFeed(
                  "$anoAtual: Recusou a chance de se tornar $novoCargo naquele momento e perdeu metade do XP.",
                );
              });
            },
            child: const Text(
              'Recusar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void showEventoEspecial(String nomeEvento, {bool contaComoAcao = true}) {
    final Map<String, String> descricoesEventos = {
      'EventoEspecialJALC':
          'Jornada de Aprendizado e Liderança do Clube. Um dos maiores eventos de formação para jovens líderes.',
      'EventoEspecialSEDEL':
          'Seminário de Desenvolvimento de Lideranças. Um espaço para fortalecer competências e valores do movimento.',
      'EventoEspecialACAMPALEO':
          'Acampamento LEO de integração e vivências ao ar livre com outros clubes.',
      'EventoEspecialEncontro de Região':
          'Reunião entre clubes da mesma região para alinhar projetos e fortalecer laços.',
      'EventoEspecialCONFE':
          'Conferência Final de Encerramento. Celebração anual dos resultados e trajetórias dos membros.',
    };

    final descricao =
        descricoesEventos[nomeEvento] ?? 'Evento especial do clube.';
    AcaoTipo? tipoEvento = AcaoTipo.values.firstWhere(
      (e) => e.name == 'EventoEspecial${nomeEvento.replaceAll(' ', '')}',
      orElse: () => AcaoTipo.Campanha,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3A0A5D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          '📅 Evento Especial: $nomeEvento',
          style: const TextStyle(
            color: Color(0xFFE1BEE7),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '$descricao\n\nVocê foi convidado para o evento $nomeEvento! Deseja participar? Custa 30 de dinheiro.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
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
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              adicionarAoFeed("$anoAtual: Recusou o evento $nomeEvento.");
            },
            child: const Text(
              'Recusar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void showRandomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2E003E),
        title: const Text(
          '🤔 Evento Aleatório',
          style: TextStyle(color: Color(0xFFD1B3FF)),
        ),
        content: const Text(
          'Você foi convidado para uma reunião surpresa do clube. Deseja participar?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              applyChanges(AcaoTipo.ParticiparReuniao, {
                'xp': 10,
                'felicidade': 5,
              });
            },
            child: const Text('Participar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              adicionarAoFeed(
                "${DateTime.now().year + idade.floor() - 18}: Você ignorou uma reunião do clube.",
              );
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        statusIcon(Icons.attach_money, dinheiro.toString(), 'dinheiro'),
        statusIcon(Icons.school, inteligencia.toString(), 'inteligencia'),
        statusIcon(Icons.favorite, saude.toString(), 'saude'),
        statusIcon(Icons.emoji_emotions, felicidade.toString(), 'felicidade'),
        statusIcon(Icons.star, xp.toString(), 'xp'),
        statusIcon(Icons.fitness_center, '$pontosDeAtributo', 'atributos'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBarWithActions(
        title: 'C. LEO - ${widget.nome}',
        actions: [
          Tooltip(
            message: pontosDeAtributo > 0
                ? 'Você tem pontos de atributos para distribuir!'
                : 'Ver perfil',
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (_, __, ___) => const ProfileScreen(),
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
                      final novosAtributos = await AtributosStorage.carregar();
                      final novosPontos =
                          await AtributosStorage.carregarPontos();
                      setState(() {
                        atributos = novosAtributos;
                        pontosDeAtributo = novosPontos;
                      });
                      updateCargo();
                    });
                  },
                ),
                if (pontosDeAtributo > 0)
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
                        '$pontosDeAtributo',
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
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              navigateWithTransition(context, ConquistasScreen());
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
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: story.length,
                        itemBuilder: (context, index) {
                          final texto = story[index];
                          final partes = texto.split(': ');
                          final ano = partes.first;
                          final descricao = partes.length > 1
                              ? partes.sublist(1).join(': ')
                              : '';
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A0A5D).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.deepPurple.shade900.withOpacity(
                                    0.5,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.all(14),
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
                                            color: Color.fromARGB(
                                              255,
                                              236,
                                              224,
                                              255,
                                            ),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          descricao,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Color.fromARGB(
                                              255,
                                              236,
                                              224,
                                              255,
                                            ),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              44,
                              3,
                              70,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
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
                                onShowInfo: (info) =>
                                    showDialogMessage('Info: ', info),
                              ),
                            );
                          },
                          child: const Text(
                            'Escolher Ação',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
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
                    colors: [
                      Color(0xFFFFD54F),
                      Colors.white,
                      Color(0xFFFF7043),
                    ],
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
