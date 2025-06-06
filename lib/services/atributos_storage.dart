import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AtributosStorage {
  static const _key = 'atributos';
  static const _pontosKey = 'pontos_de_atributo';
  static const _nomeKey = 'nome_jogador';
  static const _distribuiuKey = 'distribuiu_inicial';
  static const _ultimoXPKey = 'ultimo_xp_para_pontos';
  static const _statusKey = 'status_jogador';

  static Future<void> salvarStatus(Map<String, dynamic> status) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_statusKey, jsonEncode(status));
  }

  static Future<Map<String, dynamic>> carregarStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_statusKey);
    if (json == null) return {};
    return jsonDecode(json);
  }

  static Future<void> salvarUltimoXPParaPontos(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_ultimoXPKey, xp);
  }

  static Future<int> carregarUltimoXPParaPontos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_ultimoXPKey) ?? 0;
  }

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
    debugPrint("💾 Salvando atributos: $atributos");
    prefs.setString(_key, jsonEncode(atributos));
  }

  static Future<Map<String, int>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    debugPrint("📦 Carregando atributos: $jsonString");
    if (jsonString == null) {
      return {'Oratória': 0, 'Liderança': 0, 'Empatia': 0, 'Organização': 0};
    }
    return Map<String, int>.from(jsonDecode(jsonString));
  }

  static Future<void> salvarPontos(int pontos) async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint("💾 Salvando pontos: $pontos");
    prefs.setInt(_pontosKey, pontos);
  }

  static Future<int> carregarPontos() async {
    final prefs = await SharedPreferences.getInstance();
    final valor = prefs.getInt(_pontosKey) ?? 0;
    debugPrint("📦 Carregando pontos: $valor");
    return valor;
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
    print(primeiraVez);
    if (primeiraVez) {
      await prefs.setBool('primeiraVez', false);

      if (prefs.containsKey(_key)) return;
      // Inicia pontos de atributo
      await prefs.setInt(_pontosKey, 3);

      // Inicia atributos
      await prefs.setString(
        _key,
        jsonEncode({
          'Oratória': 0,
          'Liderança': 0,
          'Empatia': 0,
          'Organização': 0,
        }),
      );

      // Inicia status básicos (CORRIGIDO AQUI)
      await prefs.setString(
        _statusKey,
        jsonEncode({
          'dinheiro': 100,
          'inteligencia': 0,
          'felicidade': 100,
          'saude': 100,
          'xp': 0,
          'idade': 18,
          'cargo': 'Pré-LEO',
        }),
      );

      await prefs.setBool('Primeiro Passo', true);
    }
  }
}
