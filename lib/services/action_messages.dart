import 'dart:math';

enum AcaoTipo {
  Trabalhar,
  Estudar,
  Campanha,
  Descansar,
  OrganizarEvento,
  ParticiparReuniao,
  MentorarNovato,
  RedesSociais,
  ReuniaoDistrital,
  EventoEspecialJALC,
  EventoEspecialSEDEL,
  EventoEspecialACAMPALEO,
  EventoEspecialEncontroRegiao,
  EventoEspecialCONFE,
}

class ActionMessageHelper {
  static final Map<AcaoTipo, List<String>> _messages = {
    AcaoTipo.Trabalhar: [
      'Conseguiu um bico e ganhou uma graninha.',
      'Fez uma tarefa extra e faturou um troco.',
      'Se esforçou no trabalho e recebeu um pagamento justo.',
    ],
    AcaoTipo.Estudar: [
      'Aproveitou o tempo e estudou sobre liderança.',
      'Leu um livro sobre oratória e aprendeu técnicas novas.',
      'Assistiu uma palestra online sobre empatia.',
    ],
    AcaoTipo.Campanha: [
      'Organizou uma campanha de arrecadação.',
      'Fez uma ação solidária e ajudou a comunidade.',
      'Participou de um mutirão beneficente.',
    ],
    AcaoTipo.Descansar: [
      'Tirou um tempo pra si e descansou.',
      'Dormiu bem e acordou revigorado.',
      'Relaxou assistindo série e recuperou as energias.',
    ],
    AcaoTipo.OrganizarEvento: [
      'Planejou um evento e delegou as tarefas.',
      'Cuidou dos detalhes do evento do clube.',
      'Organizou uma ação e tudo saiu nos conformes.',
    ],
    AcaoTipo.ParticiparReuniao: [
      'Foi à reunião e deu boas ideias.',
      'Participou de um debate construtivo na reunião.',
      'Aprendeu bastante na reunião do clube.',
    ],
    AcaoTipo.MentorarNovato: [
      'Deu dicas valiosas pra um novo membro.',
      'Ajudou alguém a se integrar no clube.',
      'Mostrou o caminho das pedras pra um novato.',
    ],
    AcaoTipo.RedesSociais: [
      'Postou sobre as ações do clube nas redes.',
      'Fez um conteúdo criativo e engajou a galera.',
      'Atualizou as redes com as últimas novidades.',
    ],
    AcaoTipo.ReuniaoDistrital: [
      'Conheceu líderes de outros clubes.',
      'Fez networking em um encontro distrital.',
      'Compartilhou ideias em reunião com o distrito.',
    ],
    AcaoTipo.EventoEspecialJALC: [
      'Participou da JALC e aprendeu muito sobre liderança.',
    ],
    AcaoTipo.EventoEspecialSEDEL: ['Teve um momento transformador no SEDEL.'],
    AcaoTipo.EventoEspecialACAMPALEO: [
      'Se conectou com a galera no ACAMPALEO.',
    ],
    AcaoTipo.EventoEspecialEncontroRegiao: [
      'Trocou experiências valiosas no Encontro de Região.',
    ],
    AcaoTipo.EventoEspecialCONFE: ['Celebrou suas conquistas no CONFE.'],
  };

  static String getRandomMessage(AcaoTipo tipo) {
    final lista = _messages[tipo];
    if (lista != null && lista.isNotEmpty) {
      return lista[Random().nextInt(lista.length)];
    }
    return tipo.name;
  }

  static AcaoTipo? fromLabel(String label) {
    return AcaoTipo.values.firstWhere(
      (e) => e.name.toLowerCase() == label.replaceAll(' ', '').toLowerCase(),
      orElse: () => AcaoTipo.Trabalhar,
    );
  }

  static Set<String> getConquistasPossiveis(
    AcaoTipo tipo,
    int xp,
    Map<String, int> atributos,
    String cargo,
    List<String> story,
  ) {
    Set<String> conquistas = {};

    if (xp >= 10) conquistas.add('Começando a Jornada');
    if (xp >= 50) conquistas.add('Primeiro Passo de Liderança');
    if ((atributos['Oratória'] ?? 0) >= 10) conquistas.add('Fala Bonita!');
    if ((atributos['Liderança'] ?? 0) >= 10) conquistas.add('Líder Nato');
    if ((atributos['Empatia'] ?? 0) >= 10) conquistas.add('Coração Aberto');
    if ((atributos['Organização'] ?? 0) >= 10)
      conquistas.add('Organizado Demais');
    if (cargo == 'Presidente') conquistas.add('Chegou ao Topo!');
    if (tipo == AcaoTipo.EventoEspecialJALC)
      conquistas.add('Sobreviveu à JALC');
    if (tipo == AcaoTipo.EventoEspecialACAMPALEO)
      conquistas.add('Acampou com Estilo');
    if (story.length >= 10) conquistas.add('História em Construção');
    return conquistas;
  }

  static void aplicarConquistas({
    required AcaoTipo tipo,
    required int xp,
    required Map<String, int> atributos,
    required String cargo,
    required List<String> story,
    required List<String> conquistasAtuais,
    required void Function(String) novaConquista,
  }) {
    final novas = getConquistasPossiveis(tipo, xp, atributos, cargo, story);
    for (var conquista in novas) {
      if (!conquistasAtuais.contains(conquista)) {
        novaConquista(conquista);
      }
    }
  }
}
