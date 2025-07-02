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
    await _firestore.collection('users').doc(uid).set(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }

  Future<void> updateUserName(String uid, String nome) async {
    await _firestore.collection('usuarios').doc(uid).set({
      'nome': nome,
    }, SetOptions(merge: true));
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
}
