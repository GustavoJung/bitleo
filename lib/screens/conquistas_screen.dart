import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  ];

  @override
  void initState() {
    super.initState();
    carregarConquistas();
  }

  Future<void> carregarConquistas() async {
    final prefs = await SharedPreferences.getInstance();

    // Verifica se é a primeira vez que o app é aberto
    final primeiraVez = prefs.getBool('primeiraVez') ?? true;
    if (primeiraVez) {
      await prefs.setBool('primeiraVez', false);
      await prefs.setInt('pontosDeAtributo', 3);
      await prefs.setBool('Primeiro Passo', true);
    }

    setState(() {
      conquistas = conquistas.map((c) {
        final desbloqueada = prefs.getBool(c.titulo) ?? false;
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
