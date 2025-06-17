import 'package:bitleo/services/atributos_storage.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class Conquista {
  final String titulo;
  final String descricao;
  final bool desbloqueada;

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
    Conquista(titulo: 'Persistente', descricao: 'Realizou 10 ações no jogo.'),
    Conquista(
      titulo: 'Começando a Jornada',
      descricao: 'Ganhou seus primeiros 10 de XP.',
    ),
    Conquista(
      titulo: 'Primeiro Passo de Liderança',
      descricao: 'Chegou a 50 de XP.',
    ),
    Conquista(titulo: 'Fala Bonita!', descricao: 'Atingiu 10 de Oratória.'),
    Conquista(titulo: 'Líder Nato', descricao: 'Atingiu 10 de Liderança.'),
    Conquista(titulo: 'Coração Aberto', descricao: 'Atingiu 10 de Empatia.'),
    Conquista(
      titulo: 'Organizado Demais',
      descricao: 'Atingiu 10 de Organização.',
    ),
    Conquista(
      titulo: 'Chegou ao Topo!',
      descricao: 'Virou Presidente do clube.',
    ),
    Conquista(titulo: 'Sobreviveu à JALC', descricao: 'Participou da JALC.'),
    Conquista(
      titulo: 'Acampou com Estilo',
      descricao: 'Participou do ACAMPALEO.',
    ),
    Conquista(
      titulo: 'História em Construção',
      descricao: 'Acumulou 10 entradas no histórico.',
    ),
    Conquista(
      titulo: 'Se tornou Membro',
      descricao: 'Foi empossado como membro.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    carregarConquistas();
  }

  Future<void> carregarConquistas() async {
    final conquistasSalvas = await AtributosStorage.carregarConquistas();
    setState(() {
      conquistas = conquistas.map((c) {
        final desbloqueada = conquistasSalvas.contains(c.titulo);
        return Conquista(
          titulo: c.titulo,
          descricao: c.descricao,
          desbloqueada: desbloqueada,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conquistasDesbloqueadas = conquistas
        .where((c) => c.desbloqueada)
        .toList();

    return Scaffold(
      appBar: buildCustomAppBar('Minhas Conquistas'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: conquistasDesbloqueadas.isEmpty
            ? const Center(
                child: Text(
                  'Nenhuma conquista ainda.\nBora fazer história no LEO Clube!',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: conquistasDesbloqueadas.length,
                itemBuilder: (context, index) {
                  final conquista = conquistasDesbloqueadas[index];
                  return Card(
                    color: Colors.white.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 50,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            conquista.titulo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4,
                          ),
                          child: Text(
                            conquista.descricao,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
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
