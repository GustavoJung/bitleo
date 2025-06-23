import 'package:bitleo/services/atributos_storage.dart';
import 'package:bitleo/services/conquistas_service.dart';
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

  @override
  Widget build(BuildContext context) {
    final total = conquistas.length;
    final desbloqueadas = conquistas.where((c) => c.desbloqueada).length;

    return Scaffold(
      appBar: buildCustomAppBar('Minhas Conquistas'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF512DA8), Color(0xFF121212)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '$desbloqueadas de $total conquistas desbloqueadas',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: conquistas.length,
                itemBuilder: (context, index) {
                  final conquista = conquistas[index];
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF2E003E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(
                            conquista.titulo,
                            style: const TextStyle(
                              color: Color(0xFFD1B3FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            conquista.descricao,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Fechar',
                                style: TextStyle(
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Opacity(
                      opacity: conquista.desbloqueada ? 1.0 : 0.3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A0A5D).withOpacity(0.4),
                            border: Border.all(
                              color: const Color(0xFFD1B3FF).withOpacity(0.2),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox.expand(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center, // <- esse é o pulo do gato
                                    children: [
                                      const Icon(
                                        Icons.emoji_events,
                                        color: Color.fromARGB(
                                          255,
                                          230,
                                          203,
                                          85,
                                        ),
                                        size: 40,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        conquista.titulo,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        conquista.descricao,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!conquista.desbloqueada)
                                const Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Icon(
                                    Icons.lock,
                                    color: Colors.white38,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
