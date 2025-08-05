import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Ajuda: pega o uid do usuário logado
  static String get uid => FirebaseAuth.instance.currentUser!.uid;

  static DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  static Future<void> createUserDocument({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _userDoc(uid).set({
      ...data,
      'atributos': {
        'Oratória': 0,
        'Liderança': 0,
        'Empatia': 0,
        'Organização': 0,
      },
      'pontosDeAtributo': 3,
      'status': {
        'dinheiro': 40,
        'inteligencia': 5,
        'felicidade': 70,
        'saude': 70,
        'xp': 0,
        'idade': 18,
        'cargo': 'Pré-LEO',
      },
      'historico': [],
      'distribuiuInicial': false,
      'tutorialVisto': false,
      'ultimoXPParaPontos': 0,
      'conquistas': [],
      'conquistasDesbloqueadas': [],
      'conquistasResgatadas': [],
      'telasVisitadas': [],
    });
  }

  static Future<Map<String, int>> progressoConquistas(String uid) async {
    final doc = await _userDoc(uid).get();
    final data =
        doc.data()?['progressoConquistas'] as Map<String, dynamic>? ?? {};
    return data.map((k, v) => MapEntry(k, v as int));
  }

  static Future<void> incrementarProgressoConquista(
    String uid,
    String titulo,
  ) async {
    final doc = await _userDoc(uid).get();
    final progresso = Map<String, dynamic>.from(
      doc.data()?['progressoConquistas'] ?? {},
    );
    progresso[titulo] = (progresso[titulo] ?? 0) + 1;
    await _userDoc(
      uid,
    ).set({'progressoConquistas': progresso}, SetOptions(merge: true));
  }

  static Future<void> checarDesbloqueios({
    required String uid,
    required int xp,
    required int acoes,
    int? oratoria,
    int? saude,
    int? felicidadeAlta,
    bool? pontosDistribuidos,
    int? empatia,
    int? lideranca,
    int? organizacao,
    int? inteligencia,
    int? campanhas,
    int? estudou,
    int? trabalhou,
    int? mentorou,
    int? eventosOrganizados,
    int? reunioesParticipadas,
    int? redesSociais,
  }) async {
    if (xp >= 10) await desbloquear(uid, 'Começando a Jornada');
    if (xp >= 50) await desbloquear(uid, 'Primeiro Passo de Liderança');
    if (acoes >= 10) await desbloquear(uid, 'Ativo no clube');
    if ((oratoria ?? 0) >= 10) await desbloquear(uid, 'Fala Bonita!');
    if ((oratoria ?? 0) >= 50) await desbloquear(uid, 'Senhor da Oratória');
    if ((saude ?? 0) >= 100) await desbloquear(uid, 'Cura Total');
    if (pontosDistribuidos == true) await desbloquear(uid, 'Estrategista');
    if ((estudou ?? 0) >= 15) await desbloquear(uid, 'Estudante Aplicado');
    if ((trabalhou ?? 0) >= 20) await desbloquear(uid, 'Workaholic');
    if ((mentorou ?? 0) >= 5) await desbloquear(uid, 'Mentor Sênior');
    if ((eventosOrganizados ?? 0) >= 5)
      await desbloquear(uid, 'Organizador Profissional');
    if ((redesSociais ?? 0) >= 10) await desbloquear(uid, 'Influencer');
    if ((reunioesParticipadas ?? 0) >= 3)
      await desbloquear(uid, 'Amigo de Todos');
    if ((campanhas ?? 0) >= 1) await desbloquear(uid, 'Campeão de Campanha');
    if ((mentorou ?? 0) >= 1) await desbloquear(uid, 'Mentorando Novos LEOs');
  }

  static Future<Map<String, int>> carregarAcoesExecutadasEsteAno(
    String uid,
  ) async {
    final doc = await _userDoc(uid).get();
    final data =
        doc.data()?['acoesExecutadasEsteAno'] as Map<String, dynamic>? ?? {};
    return data.map((k, v) => MapEntry(k, v as int));
  }

  static Future<void> salvarProgressoConquista(
    String uid,
    String nome,
    int valor,
  ) async {
    final doc = await _userDoc(uid).get();
    final progresso = Map<String, dynamic>.from(
      doc.data()?['progressoConquistas'] ?? {},
    );
    progresso[nome] = valor;
    await _userDoc(
      uid,
    ).set({'progressoConquistas': progresso}, SetOptions(merge: true));
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(
    String uid,
  ) {
    return _userDoc(uid).get();
  }

  static Future<void> updateUserName(String uid, String nome) async {
    await _userDoc(uid).set({'nome': nome}, SetOptions(merge: true));
  }

  static Future<void> salvarAcoesExecutadasEsteAno(
    String uid,
    Map<String, int> map,
  ) async {
    await _userDoc(
      uid,
    ).set({'acoesExecutadasEsteAno': map}, SetOptions(merge: true));
  }

  static Future<void> salvarConquistas(
    String uid,
    List<String> conquistas,
  ) async {
    await _userDoc(
      uid,
    ).set({'conquistas': conquistas}, SetOptions(merge: true));
  }

  static Future<List<String>> carregarConquistas(String uid) async {
    final doc = await _userDoc(uid).get();
    return List<String>.from(doc.data()?['conquistas'] ?? []);
  }

  static Future<void> salvarAtributos(
    String uid,
    Map<String, int> atributos,
  ) async {
    await _userDoc(uid).set({'atributos': atributos}, SetOptions(merge: true));
  }

  static Future<Map<String, int>> carregarAtributos(String uid) async {
    final snap = await _userDoc(uid).get();
    final dados = snap.data()?['atributos'] as Map<String, dynamic>? ?? {};
    return dados.map((k, v) => MapEntry(k, v as int));
  }

  static Future<void> salvarPontos(String uid, int pontos) async {
    await _userDoc(
      uid,
    ).set({'pontosDeAtributo': pontos}, SetOptions(merge: true));
  }

  static Future<int> carregarPontos(String uid) async {
    final snap = await _userDoc(uid).get();
    return (snap.data()?['pontosDeAtributo'] ?? 0) as int;
  }

  static Future<void> salvarStatus(
    String uid,
    Map<String, dynamic> status,
  ) async {
    await _userDoc(uid).set({'status': status}, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>> carregarStatus(String uid) async {
    final snap = await _userDoc(uid).get();
    return Map<String, dynamic>.from(snap.data()?['status'] ?? {});
  }

  static Future<void> salvarHistorico(
    String uid,
    List<String> historico,
  ) async {
    await _userDoc(uid).set({'historico': historico}, SetOptions(merge: true));
  }

  static Future<List<String>> carregarHistorico(String uid) async {
    final snap = await _userDoc(uid).get();
    return List<String>.from(snap.data()?['historico'] ?? []);
  }

  static Future<void> salvarCargo(String uid, String cargo) async {
    await _userDoc(uid).update({'status.cargo': cargo});
  }

  static Future<String> carregarCargo(String uid) async {
    final snap = await _userDoc(uid).get();
    return (snap.data()?['status']?['cargo'] ?? 'Pré-LEO') as String;
  }

  static Future<void> salvarDistribuicaoInicial(String uid, bool valor) async {
    await _userDoc(
      uid,
    ).set({'distribuiuInicial': valor}, SetOptions(merge: true));
  }

  static Future<bool> carregarDistribuicaoInicial(String uid) async {
    final snap = await _userDoc(uid).get();
    return (snap.data()?['distribuiuInicial'] ?? false) as bool;
  }

  static Future<void> salvarTutorialVisto(String uid, bool valor) async {
    await _userDoc(uid).set({'tutorialVisto': valor}, SetOptions(merge: true));
  }

  static Future<bool> carregarTutorialVisto(String uid) async {
    final snap = await _userDoc(uid).get();
    return (snap.data()?['tutorialVisto'] ?? false) as bool;
  }

  static Future<void> salvarUltimoXPParaPontos(String uid, int xp) async {
    await _userDoc(
      uid,
    ).set({'ultimoXPParaPontos': xp}, SetOptions(merge: true));
  }

  static Future<int> carregarUltimoXPParaPontos(String uid) async {
    final snap = await _userDoc(uid).get();
    return (snap.data()?['ultimoXPParaPontos'] ?? 0) as int;
  }

  static Future<void> verificarInicializacao(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists) {
      await _userDoc(uid).set({
        'atributos': {
          'Oratória': 0,
          'Liderança': 0,
          'Empatia': 0,
          'Organização': 0,
        },
        'pontosDeAtributo': 3,
        'status': {
          'dinheiro': 100,
          'inteligencia': 0,
          'felicidade': 100,
          'saude': 100,
          'xp': 0,
          'idade': 18,
          'cargo': 'Pré-LEO',
        },
        'historico': [],
        'distribuiuInicial': false,
        'tutorialVisto': false,
        'ultimoXPParaPontos': 0,
      });
    }
  }

  static Future<void> salvarNomeJogador(String uid, String nome) async {
    await _userDoc(uid).set({'nome': nome}, SetOptions(merge: true));
  }

  static Future<String?> carregarNomeJogador(String uid) async {
    final doc = await _userDoc(uid).get();
    return doc.data()?['nome'] as String?;
  }

  static Future<void> salvarNomeClube(String uid, String nomeClube) async {
    await _userDoc(uid).set({'nomeClube': nomeClube}, SetOptions(merge: true));
  }

  static Future<String?> getNomeClube(String uid) async {
    final doc = await _userDoc(uid).get();
    return doc.data()?['clube'] as String?;
  }

  static Future<void> registrarResgateConquista(
    String uid,
    String titulo,
  ) async {
    final doc = await _userDoc(uid).get();
    final atuais = List<String>.from(doc.data()?['conquistasResgatadas'] ?? []);
    if (!atuais.contains(titulo)) {
      atuais.add(titulo);
      await _userDoc(
        uid,
      ).set({'conquistasResgatadas': atuais}, SetOptions(merge: true));
    }
  }

  static Future<List<String>> conquistasResgatadas(String uid) async {
    final doc = await _userDoc(uid).get();
    return List<String>.from(doc.data()?['conquistasResgatadas'] ?? []);
  }

  static Future<Set<String>> conquistasDesbloqueadas(String uid) async {
    final doc = await _userDoc(uid).get();
    return Set<String>.from(doc.data()?['conquistasDesbloqueadas'] ?? []);
  }

  static Future<void> desbloquear(String uid, String titulo) async {
    final doc = await _userDoc(uid).get();
    final conquistas = List<String>.from(
      doc.data()?['conquistasDesbloqueadas'] ?? [],
    );

    if (!conquistas.contains(titulo)) {
      conquistas.add(titulo);

      final conquistasDeProgresso = {
        'Ativo no clube': 10,
        'Começando a Jornada': 10,
        'Primeiro Passo de Liderança': 50,
        'Fala Bonita!': 10,
        'Cura Total': 100,
        'Workaholic': 20,
        'Estudante Aplicado': 15,
        'Organizador Profissional': 5,
        'Mentor Sênior': 5,
        'Influencer': 10,
        'Amigo de Todos': 3,
        'Senhor da Oratória': 50,
        'Descansado Demais': 10,
      };

      Map<String, dynamic> progresso = Map<String, dynamic>.from(
        doc.data()?['progressoConquistas'] ?? {},
      );
      if (conquistasDeProgresso.containsKey(titulo)) {
        progresso[titulo] = conquistasDeProgresso[titulo];
        await _userDoc(
          uid,
        ).set({'progressoConquistas': progresso}, SetOptions(merge: true));
      }

      await _userDoc(
        uid,
      ).set({'conquistasDesbloqueadas': conquistas}, SetOptions(merge: true));
    }
  }

  static Future<bool> isDesbloqueada(String uid, String titulo) async {
    final desbloqueadas = await conquistasDesbloqueadas(uid);
    return desbloqueadas.contains(titulo);
  }

  static Future<Map<String, bool>> listarTodas(
    String uid,
    List<String> titulos,
  ) async {
    final desbloqueadas = await conquistasDesbloqueadas(uid);
    return {for (var titulo in titulos) titulo: desbloqueadas.contains(titulo)};
  }

  static Future<void> resetarConquistas(String uid) async {
    await _userDoc(
      uid,
    ).set({'conquistasDesbloqueadas': []}, SetOptions(merge: true));
  }

  static Future<void> marcarInicioDoJogo(String uid) async {
    await desbloquear(uid, 'Primeiro Passo');
  }

  static Future<List<Map<String, dynamic>>> getRanking() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('status.xp', descending: true)
        .limit(10) // pega só o top 10
        .get();
    return snap.docs.map((doc) {
      final data = doc.data();
      return {
        'nome': data['nome'] ?? 'Sem Nome',
        'xp': data['status']?['xp'] ?? 0,
        'uid': doc.id,
        'clube': data['clube'],
      };
    }).toList();
  }

  static Future<void> marcarTelaVisitada(String uid, String telaId) async {
    final doc = await _userDoc(uid).get();
    final visitadas = List<String>.from(doc.data()?['telasVisitadas'] ?? []);
    if (!visitadas.contains(telaId)) {
      visitadas.add(telaId);
      await _userDoc(
        uid,
      ).set({'telasVisitadas': visitadas}, SetOptions(merge: true));
    }

    if (_telasPrincipais.every((t) => visitadas.contains(t))) {
      await desbloquear(uid, 'Explorador');
    }
  }

  static final List<String> _telasPrincipais = [
    'actions',
    'profile',
    'conquistas',
    'name',
  ];
}
