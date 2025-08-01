import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final _uid = FirebaseAuth.instance.currentUser!.uid;
  static final _doc = FirebaseFirestore.instance.collection('users').doc(_uid);

  Future<void> createUserDocument({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      ...data,
      'atributos': {
        'Oratória': 0,
        'Liderança': 0,
        'Empatia': 0,
        'Organização': 0,
      },
      'pontosDeAtributo': 3,
      'status': {
        'dinheiro': 30,
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

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }

  Future<void> updateUserName(String uid, String nome) async {
    await _firestore.collection('usuarios').doc(uid).set({
      'nome': nome,
    }, SetOptions(merge: true));
  }

  static Future<void> salvarConquistas(List<String> conquistas) async {
    await _doc.set({'conquistas': conquistas}, SetOptions(merge: true));
  }

  static Future<List<String>> carregarConquistas() async {
    final doc = await _doc.get();
    return List<String>.from(doc.data()?['conquistas'] ?? []);
  }

  // Atributos
  static Future<void> salvar(Map<String, int> atributos) async {
    await _doc.set({'atributos': atributos}, SetOptions(merge: true));
  }

  static Future<Map<String, int>> carregar() async {
    final snap = await _doc.get();
    final dados = snap.data()?['atributos'] as Map<String, dynamic>? ?? {};
    return dados.map((k, v) => MapEntry(k, v as int));
  }

  // Pontos
  static Future<void> salvarPontos(int pontos) async {
    await _doc.set({'pontosDeAtributo': pontos}, SetOptions(merge: true));
  }

  static Future<int> carregarPontos() async {
    final snap = await _doc.get();
    return (snap.data()?['pontosDeAtributo'] ?? 0) as int;
  }

  // Status
  static Future<void> salvarStatus(Map<String, dynamic> status) async {
    await _doc.set({'status': status}, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>> carregarStatus() async {
    final snap = await _doc.get();
    return Map<String, dynamic>.from(snap.data()?['status'] ?? {});
  }

  // Historico
  static Future<void> salvarHistorico(List<String> historico) async {
    await _doc.set({'historico': historico}, SetOptions(merge: true));
  }

  static Future<List<String>> carregarHistorico() async {
    final snap = await _doc.get();
    return List<String>.from(snap.data()?['historico'] ?? []);
  }

  // Cargo
  static Future<void> salvarCargo(String cargo) async {
    await _doc.update({'status.cargo': cargo});
  }

  static Future<String> carregarCargo() async {
    final snap = await _doc.get();
    return (snap.data()?['status']?['cargo'] ?? 'Pré-LEO') as String;
  }

  // Distribuição inicial
  static Future<void> salvarDistribuicaoInicial(bool valor) async {
    await _doc.set({'distribuiuInicial': valor}, SetOptions(merge: true));
  }

  static Future<bool> carregarDistribuicaoInicial() async {
    final snap = await _doc.get();
    return (snap.data()?['distribuiuInicial'] ?? false) as bool;
  }

  // Tutorial
  static Future<void> salvarTutorialVisto(bool valor) async {
    await _doc.set({'tutorialVisto': valor}, SetOptions(merge: true));
  }

  static Future<bool> carregarTutorialVisto() async {
    final snap = await _doc.get();
    return (snap.data()?['tutorialVisto'] ?? false) as bool;
  }

  // Ultimo XP
  static Future<void> salvarUltimoXPParaPontos(int xp) async {
    await _doc.set({'ultimoXPParaPontos': xp}, SetOptions(merge: true));
  }

  static Future<int> carregarUltimoXPParaPontos() async {
    final snap = await _doc.get();
    return (snap.data()?['ultimoXPParaPontos'] ?? 0) as int;
  }

  // Inicialização (primeiro uso)
  static Future<void> verificarInicializacao() async {
    final snap = await _doc.get();
    if (!snap.exists) {
      await _doc.set({
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

  static Future<void> salvarNomeJogador(String nome) async {
    await _doc.set({'nome': nome}, SetOptions(merge: true));
  }

  static Future<String?> carregarNomeJogador() async {
    final doc = await _doc.get();
    return doc.data()?['nome'] as String?;
  }

  static Future<void> salvarNomeClube(String nomeClube) async {
    await _doc.set({'nomeClube': nomeClube}, SetOptions(merge: true));
  }

  static Future<String?> getNomeClube() async {
    final doc = await _doc.get();
    return doc.data()?['clube'] as String?;
  }

  static Future<void> registrarResgateConquista(String titulo) async {
    final doc = await _doc.get();
    final atuais = List<String>.from(doc.data()?['conquistasResgatadas'] ?? []);
    if (!atuais.contains(titulo)) {
      atuais.add(titulo);
      await _doc.set({'conquistasResgatadas': atuais}, SetOptions(merge: true));
    }
  }

  static Future<List<String>> conquistasResgatadas() async {
    final doc = await _doc.get();
    return List<String>.from(doc.data()?['conquistasResgatadas'] ?? []);
  }

  static Future<Set<String>> conquistasDesbloqueadas() async {
    final doc = await _doc.get();
    return Set<String>.from(doc.data()?['conquistasDesbloqueadas'] ?? []);
  }

  static Future<void> desbloquear(String titulo) async {
    final desbloqueadas = await conquistasDesbloqueadas();
    if (!desbloqueadas.contains(titulo)) {
      desbloqueadas.add(titulo);
      await _doc.set({
        'conquistasDesbloqueadas': desbloqueadas.toList(),
      }, SetOptions(merge: true));
    }
  }

  static Future<bool> isDesbloqueada(String titulo) async {
    final desbloqueadas = await conquistasDesbloqueadas();
    return desbloqueadas.contains(titulo);
  }

  static Future<Map<String, bool>> listarTodas(List<String> titulos) async {
    final desbloqueadas = await conquistasDesbloqueadas();
    return {for (var titulo in titulos) titulo: desbloqueadas.contains(titulo)};
  }

  static Future<void> resetarConquistas() async {
    await _doc.set({'conquistasDesbloqueadas': []}, SetOptions(merge: true));
  }

  static Future<void> checarDesbloqueios({
    required int xp,
    required int acoes,
    int? oratoria,
    int? saude,
    int? felicidadeAlta,
    bool? pontosDistribuidos,
    int? turnosJogando,
  }) async {
    if (xp >= 10) await desbloquear('Começando a Jornada');
    if (xp >= 50) await desbloquear('Primeiro Passo de Liderança');
    if (acoes >= 10) await desbloquear('Ativo no clube');
    if ((oratoria ?? 0) >= 10) await desbloquear('Fala Bonita!');
    if ((saude ?? 0) >= 100) await desbloquear('Cura Total');
    if ((felicidadeAlta ?? 0) >= 5) await desbloquear('Treta Controlada');
    if (pontosDistribuidos == true) await desbloquear('Estrategista');
    if ((turnosJogando ?? 0) >= 30) await desbloquear('Maratona LEO');
  }

  static Future<void> marcarInicioDoJogo() async {
    await desbloquear('Primeiro Passo');
  }

  static Future<void> marcarTelaVisitada(String telaId) async {
    final doc = await _doc.get();
    final visitadas = List<String>.from(doc.data()?['telasVisitadas'] ?? []);
    if (!visitadas.contains(telaId)) {
      visitadas.add(telaId);
      await _doc.set({'telasVisitadas': visitadas}, SetOptions(merge: true));
    }

    if (_telasPrincipais.every((t) => visitadas.contains(t))) {
      await desbloquear('Explorador');
    }
  }

  static final List<String> _telasPrincipais = [
    'actions',
    'profile',
    'conquistas',
    'name',
  ];
}
