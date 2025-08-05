class Conquista {
  String titulo;
  String descricao;
  bool desbloqueada;
  bool podeResgatar;
  int? progressoAtual;
  int? progressoNecessario;
  bool secreta; // NOVO: conquista secreta? Exibe "???" até desbloquear
  String? dica; // NOVO: dica da conquista, aparece só se quiser

  Conquista({
    required this.titulo,
    required this.descricao,
    this.desbloqueada = false,
    this.podeResgatar = false,
    this.progressoAtual,
    this.progressoNecessario,
    this.secreta = false,
    this.dica,
  });

  Map<String, dynamic> toMap() => {
    'titulo': titulo,
    'descricao': descricao,
    'desbloqueada': desbloqueada,
    'podeResgatar': podeResgatar,
    'progressoAtual': progressoAtual,
    'progressoNecessario': progressoNecessario,
    'secreta': secreta,
    'dica': dica,
  };

  static Conquista fromMap(Map<String, dynamic> map) => Conquista(
    titulo: map['titulo'],
    descricao: map['descricao'],
    desbloqueada: map['desbloqueada'] ?? false,
    podeResgatar: map['podeResgatar'] ?? false,
    progressoAtual: map['progressoAtual'],
    progressoNecessario: map['progressoNecessario'],
    secreta: map['secreta'] ?? false,
    dica: map['dica'],
  );
}

class ConquistaHelper {
  static List<Conquista> getListaConquistas() {
    return [
      // Progresso/Atributos
      Conquista(
        titulo: 'Primeiro Passo',
        descricao: 'Você abriu o jogo pela primeira vez!',
      ),
      Conquista(
        titulo: 'Ativo no clube',
        descricao: 'Realizou 10 ações no jogo.',
        progressoAtual: 0,
        progressoNecessario: 10,
      ),
      Conquista(
        titulo: 'Começando a Jornada',
        descricao: 'Ganhou seus primeiros 10 de XP.',
        progressoAtual: 0,
        progressoNecessario: 10,
      ),
      Conquista(
        titulo: 'Primeiro Passo de Liderança',
        descricao: 'Chegou a 50 de XP.',
        progressoAtual: 0,
        progressoNecessario: 50,
      ),
      Conquista(
        titulo: 'Fala Bonita!',
        descricao: 'Atingiu 10 de Oratória.',
        progressoAtual: 0,
        progressoNecessario: 10,
      ),
      Conquista(
        titulo: 'Cura Total',
        descricao: 'Atingiu 100 de Saúde.',
        progressoAtual: 0,
        progressoNecessario: 100,
      ),
      Conquista(
        titulo: 'Workaholic',
        descricao: 'Trabalhou 20 vezes. Vai com calma, hein!',
        progressoAtual: 0,
        progressoNecessario: 20,
      ),
      Conquista(
        titulo: 'Estudante Aplicado',
        descricao: 'Estudou 15 vezes. Só falta o TCC agora!',
        progressoAtual: 0,
        progressoNecessario: 15,
      ),
      Conquista(
        titulo: 'Organizador Profissional',
        descricao: 'Organizou 5 eventos.',
        progressoAtual: 0,
        progressoNecessario: 5,
      ),
      Conquista(
        titulo: 'Mentor Sênior',
        descricao: 'Mentorou 5 novatos.',
        progressoAtual: 0,
        progressoNecessario: 5,
      ),
      Conquista(
        titulo: 'Influencer',
        descricao: 'Usou Redes Sociais 10 vezes.',
        progressoAtual: 0,
        progressoNecessario: 10,
      ),
      Conquista(
        titulo: 'Amigo de Todos',
        descricao: 'Participou de 3 reuniões.',
        progressoAtual: 0,
        progressoNecessario: 3,
      ),

      // Eventos únicos
      Conquista(
        titulo: 'Mentorando Novos LEOs',
        descricao: 'Mentorou um novato pela primeira vez.',
      ),
      Conquista(
        titulo: 'Campeão de Campanha',
        descricao: 'Realizou sua primeira campanha.',
      ),
      Conquista(
        titulo: 'Estrategista',
        descricao: 'Distribuiu seus pontos iniciais.',
      ),

      // Secretas
      Conquista(
        titulo: 'Zé Ruela',
        descricao: 'Ficou com saúde zerada. Parabéns, ein...',
        secreta: true,
        dica: 'Dica: não recomendo tentar!',
      ),
      Conquista(
        titulo: 'Endividado',
        descricao: 'Conseguiu ficar com dinheiro negativo! Vai pedir Pix?',
        secreta: true,
        dica: 'Dica: dinheiro é bom, não esquece.',
      ),
      Conquista(
        titulo: 'Detestado',
        descricao: 'Ficou com felicidade abaixo de zero. Eita!',
        secreta: true,
        dica: 'Dica: tente não ser odiado!',
      ),
      Conquista(
        titulo: 'Senhor da Oratória',
        descricao: 'Atingiu 50 de Oratória. Tá pronto pro TED!',
        progressoAtual: 0,
        progressoNecessario: 50,
        secreta: true,
        dica: 'Fala mais que o Faustão!',
      ),
      Conquista(
        titulo: 'Na pele do outro',
        descricao: 'Atingiu 50 de Empatia. Cuidando dos demais!',
        secreta: true,
        dica: 'O outro em primeiro lugar!',
      ),
    ];
  }

  static int totalConquistas() {
    return getListaConquistas().length;
  }
}
