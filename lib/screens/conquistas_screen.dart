import 'package:bitleo/services/atributos_storage.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../services/conquistas_service.dart';

class Conquista {
  final String titulo;
  final String descricao;
  bool desbloqueada;

  Conquista({
    required this.titulo,
    required this.descricao,
    this.desbloqueada = false,
  });

  Map<String, dynamic> toMap() => {
    'titulo': titulo,
    'descricao': descricao,
    'desbloqueada': desbloqueada,
  };

  static Conquista fromMap(Map<String, dynamic> map) => Conquista(
    titulo: map['titulo'],
    descricao: map['descricao'],
    desbloqueada: map['desbloqueada'],
  );
}

class ConquistasScreen extends StatefulWidget {
  const ConquistasScreen({super.key});

  @override
  State<ConquistasScreen> createState() => _ConquistasScreenState();
}

class _ConquistasScreenState extends State<ConquistasScreen> {
  List<Conquista> conquistas = [
    Conquista(
      titulo: 'Primeiro Passo',
      descricao: 'Você abriu o jogo pela primeira vez!',
    ),
    Conquista(
      titulo: 'Explorador',
      descricao: 'Visitou todas as telas principais.',
    ),
    Conquista(
      titulo: 'Ativo no clube',
      descricao: 'Realizou 10 ações no jogo.',
    ),
    Conquista(
      titulo: 'Começando a Jornada',
      descricao: 'Ganhou seus primeiros 10 de XP.',
    ),
    Conquista(
      titulo: 'Primeiro Passo de Liderança',
      descricao: 'Chegou a 50 de XP.',
    ),
    Conquista(titulo: 'Fala Bonita!', descricao: 'Atingiu 10 de Oratória.'),
    Conquista(
      titulo: 'Estrategista',
      descricao: 'Distribuiu seus pontos iniciais.',
    ),
    Conquista(
      titulo: 'Treta Controlada',
      descricao: 'Manteve a felicidade alta por 5 rodadas.',
    ),
    Conquista(titulo: 'Cura Total', descricao: 'Atingiu 100 de Saúde.'),
    Conquista(titulo: 'Maratona LEO', descricao: 'Jogou por 30 turnos.'),
  ];

  @override
  void initState() {
    super.initState();
    ConquistaService.marcarTelaVisitada('conquistas');
    _carregarConquistas();
  }

  Future<void> _carregarConquistas() async {
    final estados = await ConquistaService.listarTodas(
      conquistas.map((c) => c.titulo).toList(),
    );
    setState(() {
      for (var c in conquistas) {
        c.desbloqueada = estados[c.titulo] ?? false;
      }
    });
  }

  Future<bool> _verificarResgate(String titulo) async {
    final resgatadas = await ConquistaService.conquistasResgatadas();
    return resgatadas.contains(titulo);
  }

  Future<void> _resgatarRecompensa(String titulo) async {
    int pontosAtuais = await AtributosStorage.carregarPontos();
    await AtributosStorage.salvarPontos(pontosAtuais + 1);
    await ConquistaService.registrarResgate(titulo);
  }

  void _mostrarDetalhes(Conquista conquista) async {
    final jaResgatado = await _verificarResgate(conquista.titulo);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF4A148C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                conquista.titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '${conquista.descricao}\n\nRecompensa: +1 ponto de atributo',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          if (conquista.desbloqueada && !jaResgatado)
            TextButton(
              onPressed: () async {
                await _resgatarRecompensa(conquista.titulo);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recompensa resgatada com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                'Resgatar',
                style: TextStyle(color: Colors.amber),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Fechar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Conta as desbloqueadas
    final desbloqueadas = conquistas.where((c) => c.desbloqueada).length;
    final total = conquistas.length;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false; // Cancela o pop automático
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conquistas'),
          backgroundColor: const Color(0xFF2E003E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      '$desbloqueadas de $total conquistas desbloqueadas',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: conquistas.map((conquista) {
                      return MouseRegion(
                        cursor: conquista.desbloqueada
                            ? SystemMouseCursors.click
                            : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: () => _mostrarDetalhes(conquista),
                          child: ConquistaCard(conquista: conquista),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ConquistaCard extends StatelessWidget {
  final Conquista conquista;

  const ConquistaCard({super.key, required this.conquista});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 220,
      height: 180,
      decoration: BoxDecoration(
        color: conquista.desbloqueada
            ? const Color(0xFF7B1FA2)
            : const Color(0xFF6A1B9A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.emoji_events,
            color: conquista.desbloqueada ? Colors.amber : Colors.grey[300],
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            conquista.titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              conquista.descricao,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
