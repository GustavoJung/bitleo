import 'package:bitleo/services/firestore_service.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../services/atributos_storage.dart';

class ProfileScreen extends StatefulWidget {
  final String userCargo;
  final String nome;
  final String clube;
  final String uid;

  const ProfileScreen({
    super.key,
    required this.userCargo,
    required this.nome,
    required this.clube,
    required this.uid,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  Map<String, int> atributos = {
    'Oratória': 0,
    'Liderança': 0,
    'Empatia': 0,
    'Organização': 0,
  };

  int pontosRestantes = 0;

  @override
  void initState() {
    super.initState();
    carregarDados();
    FirestoreService.marcarTelaVisitada(widget.uid, 'profile');
  }

  Future<void> carregarDados() async {
    final status = await FirestoreService.carregarStatus(widget.uid);
    final a = await FirestoreService.carregarAtributos(widget.uid);
    final p = await FirestoreService.carregarPontos(widget.uid);

    setState(() {
      atributos = a;
      pontosRestantes = p;
    });
  }

  Widget buildTituloEDica() {
    final valores = atributos.values.toSet();

    // Caso todos estejam iguais
    if (valores.length == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '🎯 Equilíbrio Total',
            style: TextStyle(
              color: Colors.amberAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Você está equilibrado em todas as áreas. Continue assim!',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 24),
        ],
      );
    }

    final atributoMaisAlto = atributos.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final atributoMaisBaixo = atributos.entries.reduce(
      (a, b) => a.value <= b.value ? a : b,
    );

    final nomeAlto = atributoMaisAlto.key;
    final nomeBaixo = atributoMaisBaixo.key;
    final valorAlto = atributoMaisAlto.value;
    final valorBaixo = atributoMaisBaixo.value;

    // Título baseado no nível do atributo mais alto
    String titulo;
    if (valorAlto >= 45) {
      titulo = '🌟 Mestre em $nomeAlto';
    } else if (valorAlto >= 30) {
      titulo = '🧠 Avançado em $nomeAlto';
    } else if (valorAlto >= 15) {
      titulo = '🚀 Em ascensão em $nomeAlto';
    } else {
      titulo = '🌱 Iniciante promissor';
    }

    // Dica baseada na diferença entre atributos
    final diferenca = valorAlto - valorBaixo;
    String dica;
    if (diferenca >= 30) {
      dica =
          'Você está se especializando em ${nomeAlto.toLowerCase()}, mas está negligenciando ${nomeBaixo.toLowerCase()}.';
    } else if (diferenca >= 15) {
      dica =
          'Boa progressão em ${nomeAlto.toLowerCase()}, mas que tal dar atenção a ${nomeBaixo.toLowerCase()}?';
    } else {
      dica =
          'Seu perfil está relativamente equilibrado, mas ${nomeBaixo.toLowerCase()} ainda pode evoluir.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.amberAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(dica, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar('Perfil'),
      backgroundColor: const Color(0xFF3B1E5C),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 80,
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.userCargo,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          widget.clube,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                buildTituloEDica(),
                Text(
                  'Pontos restantes: $pontosRestantes',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                atributoCard('Oratória'),
                atributoCard('Liderança'),
                atributoCard('Empatia'),
                atributoCard('Organização'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget atributoCard(String nome) {
    int nivel = atributos[nome] ?? 0;
    double progresso = nivel / 50;
    bool atingiuLimite = nivel >= 50;

    final iconMap = {
      'Oratória': 'assets/images/public-speaking.png',
      'Liderança': 'assets/images/leadership.png',
      'Empatia': 'assets/images/empathy.png',
      'Organização': 'assets/images/time-management.png',
    };

    final iconPath = iconMap[nome];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E2E), Color(0xFF2A004F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purpleAccent.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          if (iconPath != null)
            Image.asset(iconPath, width: 40, height: 40)
          else
            const Icon(
              Icons.help_outline,
              color: Colors.purpleAccent,
              size: 28,
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$nome',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progresso.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    atingiuLimite ? Colors.green : Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      atingiuLimite ? 'Nível máximo' : 'Nível: $nivel',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: atingiuLimite
                            ? Colors.grey
                            : Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (!atingiuLimite && pontosRestantes > 0)
                          ? () async {
                              final novosAtributos = Map<String, int>.from(
                                atributos,
                              );
                              novosAtributos[nome] = nivel + 1;
                              final novosPontos = pontosRestantes - 1;

                              await AtributosStorageFirestore.salvar(
                                novosAtributos,
                              );
                              await AtributosStorageFirestore.salvarPontos(
                                novosPontos,
                              );
                              if (nome == 'Oratória') {
                                await FirestoreService.salvarProgressoConquista(
                                  widget.uid,
                                  'Fala Bonita!',
                                  novosAtributos['Oratória']!,
                                );
                                if (novosAtributos['Oratória']! >= 50) {
                                  await FirestoreService.desbloquear(
                                    widget.uid,
                                    'Senhor da Oratória',
                                  );
                                }
                                if (novosAtributos['Empatia']! >= 50) {
                                  await FirestoreService.desbloquear(
                                    widget.uid,
                                    'Na pele do outro',
                                  );
                                }
                              }

                              setState(() {
                                atributos = novosAtributos;
                                pontosRestantes = novosPontos;
                              });
                            }
                          : null,
                      child: Text(atingiuLimite ? 'Máx' : 'Evoluir'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
