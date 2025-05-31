import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AtributosStorage {
  static const _key = 'atributos';
  static const _pontosKey = 'pontos_de_atributo';

  static Future<void> salvar(Map<String, int> atributos) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, jsonEncode(atributos));
  }

  static Future<Map<String, int>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) {
      return {
        'Oratória': 0,
        'Liderança': 0,
        'Empatia': 0,
        'Organização': 0,
      };
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
}
