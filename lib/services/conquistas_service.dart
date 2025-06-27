import 'package:shared_preferences/shared_preferences.dart';

class ConquistaService {
  static const String _key = 'conquistas_desbloqueadas';
  static const String _keyExplorador = 'telas_visitadas';
  static const List<String> _telasPrincipais = [
    'actions',
    'profile',
    'conquistas',
    'name',
  ];

  static const String _resgatadasKey = 'conquistas_resgatadas';

  static Future<Set<String>> conquistasResgatadas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_resgatadasKey)?.toSet() ?? {};
  }

  static Future<void> registrarResgate(String titulo) async {
    final prefs = await SharedPreferences.getInstance();
    final atuais = await conquistasResgatadas();
    atuais.add(titulo);
    await prefs.setStringList(_resgatadasKey, atuais.toList());
  }

  static Future<Set<String>> conquistasDesbloqueadas() async {
    return _getDesbloqueadas();
  }

  static Future<void> salvarConquistas(List<String> conquistas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('conquistas', conquistas);
  }

  static Future<List<String>> carregarConquistas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('conquistas') ?? [];
  }

  static Future<Set<String>> _getDesbloqueadas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  static Future<void> desbloquear(String titulo) async {
    final prefs = await SharedPreferences.getInstance();
    final conquistas = await _getDesbloqueadas();
    if (!conquistas.contains(titulo)) {
      conquistas.add(titulo);
      await prefs.setStringList(_key, conquistas.toList());
    }
  }

  static Future<bool> isDesbloqueada(String titulo) async {
    final conquistas = await _getDesbloqueadas();
    return conquistas.contains(titulo);
  }

  static Future<Map<String, bool>> listarTodas(List<String> titulos) async {
    final desbloqueadas = await _getDesbloqueadas();
    return {for (var titulo in titulos) titulo: desbloqueadas.contains(titulo)};
  }

  static Future<void> resetar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
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
    if (acoes >= 10) await desbloquear('Persistente');
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
    final prefs = await SharedPreferences.getInstance();
    final visitadas = prefs.getStringList(_keyExplorador)?.toSet() ?? {};
    visitadas.add(telaId);
    await prefs.setStringList(_keyExplorador, visitadas.toList());

    if (_telasPrincipais.every((t) => visitadas.contains(t))) {
      await desbloquear('Explorador');
    }
  }
}
