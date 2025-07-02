import 'package:shared_preferences/shared_preferences.dart';

class LocalCooldownStorage {
  static const _ultimaAcaoKey = 'ultima_acao';

  static Future<void> salvarUltimaAcao(String acao) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ultimaAcaoKey, acao);
  }

  static Future<String?> carregarUltimaAcao() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ultimaAcaoKey);
  }
}
