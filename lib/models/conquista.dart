class Conquista {
  final String titulo;
  final String descricao;
  bool desbloqueada;
  bool podeResgatar;

  Conquista({
    required this.titulo,
    required this.descricao,
    this.desbloqueada = false,
    this.podeResgatar = false,
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

class ConquistaHelper {
  static List<Conquista> getListaConquistas() {
    return [
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
  }

  static int totalConquistas() {
    return getListaConquistas().length;
  }
}
