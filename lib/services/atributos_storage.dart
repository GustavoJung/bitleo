import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AtributosStorageFirestore {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }
    return user.uid;
  }

  static DocumentReference<Map<String, dynamic>> get _docRef {
    return _firestore.collection('users').doc(_uid);
  }

  static Future<void> salvarStatus(Map<String, dynamic> status) async {
    await _docRef.set({'status': status}, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>> carregarStatus() async {
    final doc = await _docRef.get();
    return (doc.data()?['status'] as Map<String, dynamic>?) ??
        {
          'dinheiro': 100,
          'inteligencia': 0,
          'felicidade': 100,
          'saude': 100,
          'xp': 0,
          'idade': 18,
          'cargo': 'Pré-LEO',
        };
  }

  static Future<void> salvarUltimoXPParaPontos(int xp) async {
    await _docRef.set({'ultimoXPParaPontos': xp}, SetOptions(merge: true));
  }

  static Future<int> carregarUltimoXPParaPontos() async {
    final doc = await _docRef.get();
    return (doc.data()?['ultimoXPParaPontos'] as int?) ?? 0;
  }

  static Future<void> salvarDistribuicaoInicial(bool valor) async {
    await _docRef.set({'distribuiuInicial': valor}, SetOptions(merge: true));
  }

  static Future<bool> carregarDistribuicaoInicial() async {
    final doc = await _docRef.get();
    return (doc.data()?['distribuiuInicial'] as bool?) ?? false;
  }

  static Future<void> salvar(Map<String, int> atributos) async {
    await _docRef.set({'atributos': atributos}, SetOptions(merge: true));
  }

  static Future<Map<String, int>> carregar() async {
    final doc = await _docRef.get();
    return Map<String, int>.from(
      (doc.data()?['atributos'] as Map<String, dynamic>?) ??
          {'Oratória': 0, 'Liderança': 0, 'Empatia': 0, 'Organização': 0},
    );
  }

  static Future<void> salvarPontos(int pontos) async {
    await _docRef.set({'pontosDeAtributo': pontos}, SetOptions(merge: true));
  }

  static Future<int> carregarPontos() async {
    final doc = await _docRef.get();
    return (doc.data()?['pontosDeAtributo'] as int?) ?? 0;
  }

  static Future<void> salvarNomeJogador(String nome) async {
    await _docRef.set({'nome': nome}, SetOptions(merge: true));
  }

  static Future<String?> carregarNomeJogador() async {
    final doc = await _docRef.get();
    return doc.data()?['nome'] as String?;
  }

  static Future<void> salvarHistorico(List<String> story) async {
    await _docRef.set({'historico': story}, SetOptions(merge: true));
  }

  static Future<List<String>> carregarHistorico() async {
    final doc = await _docRef.get();
    return List<String>.from(doc.data()?['historico'] ?? []);
  }

  static Future<void> salvarCargo(String cargo) async {
    await _docRef.set({'cargo': cargo}, SetOptions(merge: true));
  }

  static Future<String> carregarCargo() async {
    final doc = await _docRef.get();
    return doc.data()?['cargo'] as String? ?? 'Pré-LEO';
  }

  static Future<void> verificarInicializacao() async {
    final doc = await _docRef.get();
    if (doc.exists) return;

    await _docRef.set({
      'pontosDeAtributo': 3,
      'atributos': {
        'Oratória': 0,
        'Liderança': 0,
        'Empatia': 0,
        'Organização': 0,
      },
      'status': {
        'dinheiro': 100,
        'inteligencia': 0,
        'felicidade': 100,
        'saude': 100,
        'xp': 0,
        'idade': 18,
        'cargo': 'Pré-LEO',
      },
      'distribuiuInicial': false,
      'ultimoXPParaPontos': 0,
      'historico': [],
      'cargo': 'Pré-LEO',
    });
  }
}
