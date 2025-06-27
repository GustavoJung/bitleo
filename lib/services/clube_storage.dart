import 'package:shared_preferences/shared_preferences.dart';

class ClubeStorage {
  static const _key = 'clube_selecionado';

  static Future<void> salvar(String clube) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, clube);
  }

  static Future<String> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? 'Clube não informado';
  }

  static Future<bool> existeClubeSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }
}
