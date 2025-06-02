import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AtributosStorage {
  static const _key = 'atributos';
  static const _pontosKey = 'pontos_de_atributo';
  static const _nomeKey = 'nome_jogador';
  static const _distribuiuKey = 'distribuiu_inicial';

  static Future<void> salvarDistribuicaoInicial(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_distribuiuKey, valor);
  }

  static Future<bool> carregarDistribuicaoInicial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_distribuiuKey) ?? false;
  }

  static Future<void> salvar(Map<String, int> atributos) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, jsonEncode(atributos));
  }

  static Future<Map<String, int>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) {
      return {'Oratória': 0, 'Liderança': 0, 'Empatia': 0, 'Organização': 0};
    }
    return Map<String, int>.from(jsonDecode(jsonString));
  }

  static Future<void> salvarPontos(int pontos) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_pontosKey, pontos);
  }

  static Future<int> carregarPontos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pontosKey) ?? 0;
  }

  static Future<void> salvarNomeJogador(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_nomeKey, nome);
  }

  static Future<String?> carregarNomeJogador() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nomeKey);
  }

  static Future<void> verificarInicializacao() async {
    final prefs = await SharedPreferences.getInstance();
    final primeiraVez = prefs.getBool('primeiraVez') ?? true;
    if (primeiraVez) {
      await prefs.setBool('primeiraVez', false);
      await prefs.setInt(_pontosKey, 3);
      await prefs.setString(
        _key,
        jsonEncode({
          'Oratória': 0,
          'Liderança': 0,
          'Empatia': 0,
          'Organização': 0,
        }),
      );
      await prefs.setBool('Primeiro Passo', true);
    }
  }
}
