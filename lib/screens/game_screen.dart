import 'dart:math';
import 'package:flutter/material.dart';
import 'actions_screen.dart';
import 'profile_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> story = ["Você ingressou no LEO Clube!"];

  int dinheiro = 100;
  int inteligencia = 5;
  int felicidade = 50;
  int saude = 50;
  double idade = 18;
  int xp = 0;
  String cargo = 'Membro';

  final random = Random();
  final ScrollController _scrollController = ScrollController();

  List<String> conquistas = [];

  // ---------------------------- FUNÇÕES CORE ------------------------------

  int getEffect(Map<String, dynamic> effects, String key) {
    final value = effects[key];
    if (value is int) return value;
    if (value is double) return value.toInt();
    return 0;
  }

  void desbloquearConquista(String titulo) {
    if (!conquistas.contains(titulo)) {
      conquistas.add(titulo);
      story.add("🎖️ Conquista desbloqueada: $titulo");
      showAnimatedDialog('🎖️ Conquista Desbloqueada!', titulo);
      scrollToBottom();
    }
  }

  void showAnimatedDialog(String title, String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
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

  void showActionInfo(String action) {
  Map<String, String> infos = {
    'Trabalhar': '🛠️ Trabalhar permite que você ganhe dinheiro para participar de eventos e manter sua saúde financeira. No mundo real, é como equilibrar sua vida profissional com o voluntariado.',
    'Fazer Campanha': '❤️ As campanhas são ações sociais que ajudam sua comunidade e o próprio clube. Benefícios: gera XP, felicidade, dinheiro, networking e visibilidade pro LEO Clube.',
    'Estudar': '📚 Estudar melhora sua inteligência, o que ajuda no desenvolvimento pessoal e nas funções de liderança dentro do clube.',
    'Cuidar da Saúde': '💖 Manter a saúde em dia é essencial. Participar de tudo sem cuidar de você leva a consequências negativas no jogo... e na vida real também!',
    'AcampaLEO': '🏕️ O AcampaLEO é um evento de integração. Fortalece amizades, gera XP e felicidade. É uma experiência única para qualquer LEO.',
    'SEDEL': '🎯 O SEDEL (Seminário de Desenvolvimento de Lideranças) prepara você para assumir cargos, desenvolver liderança e crescer como LEO e como pessoa.',
    'JALC': '⚽ JALC (Jogos Abertos do LEO Clube) promove integração, diversão, espírito de equipe e muito networking. E claro, competição saudável!',
    'Encontro de Regiões': '🌍 Um evento que aproxima LEOs de diferentes clubes, fortalece laços, troca experiências e amplia sua visão sobre o movimento.',
  };

  showAnimatedDialog(
    'Sobre $action',
    infos[action] ?? 'Informações não disponíveis.',
  );
}

  void updateCargo() {
    String oldCargo = cargo;
    if (xp >= 300) {
      cargo = 'Presidente';
    } else if (xp >= 200) {
      cargo = 'Vice-Presidente';
    } else if (xp >= 150) {
      cargo = 'Tesoureiro(a)';
    } else if (xp >= 100) {
      cargo = 'Secretário(a)';
    } else if (xp >= 50) {
      cargo = 'Diretor(a) de Marketing';
    } else {
      cargo = 'Membro';
    }

    if (cargo != oldCargo) {
      story.add("🏆 Parabéns! Você foi promovido(a) a $cargo no LEO Clube!");
      showAnimatedDialog('🎉 Promoção!', 'Agora você é $cargo no LEO Clube!');
      desbloquearConquista("Se tornou $cargo");
      scrollToBottom();
    }
  }

  String getActionDescription(String action) {
    Map<String, List<String>> descriptions = {
      'Trabalhar': [
        'Você ralou no trabalho e recebeu seu salário.',
        'Fez uns freelas e ganhou uma grana.',
        'Passou o dia no trampo e voltou exausto, mas com dinheiro no bolso.'
      ],
      'Fazer Campanha': [
        'Você participou de uma campanha incrível e ajudou muita gente!',
        'Organizou uma campanha solidária que foi um sucesso!',
        'Fez uma ação social que impactou a comunidade. Parabéns!'
      ],
      'Estudar': [
        'Passou horas estudando e ficou mais inteligente.',
        'Matou umas dúvidas antigas e se sente mais preparado.',
        'Fez um curso online top e aprendeu coisa nova.'
      ],
      'Cuidar da Saúde': [
        'Foi pra academia cuidar do shape. 💪',
        'Deu aquela caminhada na praça e se sentiu mais saudável.',
        'Tirou um tempo pra cuidar da saúde física e mental.'
      ],
      'AcampaLEO': [
        'Participou do AcampaLEO e fez amizades incríveis!',
        'Se divertiu MUITO no AcampaLEO, que experiência top!',
        'AcampaLEO foi pura integração, risadas e histórias!'
      ],
      'SEDEL': [
        'Participou do SEDEL e saiu de lá um(a) líder ainda melhor!',
        'Se desenvolveu no SEDEL e aprendeu muito sobre liderança.',
        'O SEDEL foi inspirador e cheio de aprendizados.'
      ],
      'JALC': [
        'Participou do JALC, jogou, competiu e se divertiu!',
        'Deu show no JALC, tanto no esporte quanto na resenha.',
        'JALC foi só alegria, risadas e competição saudável.'
      ],
      'Encontro de Regiões': [
        'Participou do Encontro de Regiões e fez muito networking!',
        'Conheceu leos de outras regiões e compartilhou experiências.',
        'O Encontro de Regiões foi incrível, cheio de troca e união.'
      ],
    };

    var list = descriptions[action];
    if (list != null) {
      return list[random.nextInt(list.length)];
    } else {
      return action;
    }
  }

  void applyChanges(String action, Map<String, int> changes) {
    if ((changes['dinheiro'] ?? 0) < 0 &&
    dinheiro + (changes['dinheiro'] ?? 0) < 0) {
  showAnimatedDialog(
    '💸 Sem Dinheiro!',
    'Você não tem dinheiro suficiente para isso.\n\n💡 Dica: Trabalhe ou faça campanhas para ganhar dinheiro!',
  );
  return;
}


    setState(() {
      story.add(getActionDescription(action));
      idade += 0.25;

      dinheiro += (changes['dinheiro'] ?? 0);
      inteligencia += (changes['inteligencia'] ?? 0);
      felicidade += (changes['felicidade'] ?? 0);
      saude += (changes['saude'] ?? 0);
      xp += (changes['xp'] ?? 0);

      felicidade = felicidade.clamp(0, 100);
      saude = saude.clamp(0, 100);
      inteligencia = inteligencia.clamp(0, 999);

      checkConsequences();
      randomEvent();
      updateCargo();
      scrollToBottom();
    });
  }

  void randomEvent() {
    if (random.nextInt(100) < 15) {
      List<Map<String, dynamic>> events = [
        {
          'desc': 'Você ficou gripado. Perdeu 10 de saúde e 20 reais.',
          'effects': {'saude': -10, 'dinheiro': -20}
        },
        {
          'desc': 'Ganhou uma rifa do LEO! +50 de dinheiro.',
          'effects': {'dinheiro': 50}
        },
        {
          'desc': 'Discutiu com um colega do clube. -5 felicidade.',
          'effects': {'felicidade': -5}
        },
        {
          'desc': 'Encontrou 10 reais no chão! 🍀',
          'effects': {'dinheiro': 10}
        },
        {
          'desc': 'Perdeu a hora da reunião. -5 XP.',
          'effects': {'xp': -5}
        },
      ];

      var selected = events[random.nextInt(events.length)];
      story.add("💥 Acontecimento inesperado: ${selected['desc']}");

      dinheiro += getEffect(selected['effects'], 'dinheiro');
      inteligencia += getEffect(selected['effects'], 'inteligencia');
      felicidade += getEffect(selected['effects'], 'felicidade');
      saude += getEffect(selected['effects'], 'saude');
      xp += getEffect(selected['effects'], 'xp');

      felicidade = felicidade.clamp(0, 100);
      saude = saude.clamp(0, 100);
      inteligencia = inteligencia.clamp(0, 999);
      xp = max(0, xp);

      checkConsequences();
      scrollToBottom();
    }
  }

  void checkConsequences() {
    if (saude <= 0) {
      story.add("Sua saúde acabou e você... faleceu. 💀");
      showGameOverDialog();
      return;
    }

    if (idade >= 30) {
      story.add(
          "🦁 Você completou 30 anos e se aposentou do LEO Clube. Parabéns pela sua jornada!");
      showGameOverDialog();
      return;
    }

    if (felicidade <= 0) {
      story.add(
          "Você entrou em depressão. 😞 Sua saúde e inteligência foram afetadas.");
      saude -= 10;
      inteligencia -= 5;
      felicidade = 10;
    }

    if (dinheiro < 0) {
      story.add(
          "Você ficou endividado! Isso afetou sua saúde e felicidade.");
      saude -= 5;
      felicidade -= 10;
    }

    felicidade = felicidade.clamp(0, 100);
    saude = saude.clamp(0, 100);
    inteligencia = inteligencia.clamp(0, 999);
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Fim de Jogo'),
        content: const Text(
            'Sua vida no LEO chegou ao fim...\nDeseja começar uma nova vida?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              newLife();
            },
            child: const Text('Nova Vida'),
          ),
        ],
      ),
    );
  }

  void newLife() {
    setState(() {
      story = ["Você ingressou no LEO Clube!"];
      dinheiro = 100;
      inteligencia = 5;
      felicidade = 50;
      saude = 50;
      xp = 0;
      idade = 18;
      cargo = 'Membro';
      conquistas = [];
    });
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void showConquistasScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Minhas Conquistas')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: conquistas.isEmpty
                ? [
                    const Center(
                        child: Text(
                            'Nenhuma conquista ainda. Bora fazer história!'))
                  ]
                : conquistas
                    .map(
                      (c) => Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          leading: const Icon(Icons.emoji_events,
                              color: Colors.amber),
                          title: Text(
                            c,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vida de LEO Clube'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    dinheiro: dinheiro,
                    inteligencia: inteligencia,
                    felicidade: felicidade,
                    saude: saude,
                    xp: xp,
                    idade: idade.floor(),
                    cargo: cargo,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: showConquistasScreen,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: story.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        story[index],
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ActionsScreen(
                        onActionSelected: applyChanges,
                        onShowInfo: showActionInfo,
                        ),
                    ),
                    );
                },
                child: const Text('Escolher Ação'),
                ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: newLife,
              child: const Text('Nova Vida'),
            ),
          ],
        ),
      ),
    );
  }
}
