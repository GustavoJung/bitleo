import 'package:bitleo/services/clube_storage.dart';
import 'package:bitleo/services/conquistas_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_appbar.dart';
import '../services/atributos_storage.dart';

Map<String, Map<String, String>> clubesInfo = {
  'LEO Clube Ômega Seara Centenário': {
    'regiao': 'Região B',
    'distrito': 'LD-8',
    'regiaoDesc':
        'Região B é conhecida pelo seu espírito inovador e união entre clubes.',
    'distritoDesc':
        'O Distrito LD-8 abrange diversos clubes do sul do Brasil, com forte tradição no movimento LEO.',
  },
};

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String regiao = 'Não informado';
  String distrito = 'Não informado';
  String regiaoDesc = 'Atualize seu clube para ver a região.';
  String distritoDesc = 'Atualize seu clube para ver o distrito.';

  Map<String, int> atributos = {
    'Oratória': 0,
    'Liderança': 0,
    'Empatia': 0,
    'Organização': 0,
  };

  int pontosRestantes = 0;
  int dinheiro = 0;
  int inteligencia = 0;
  int felicidade = 0;
  int saude = 0;
  int xp = 0;
  double idade = 18;
  String cargo = 'Pré-LEO';
  String clubeAtual = 'Clube não informado';

  @override
  void initState() {
    super.initState();
    carregarClube();
    carregarDados();
    ConquistaService.marcarTelaVisitada('profile');
  }

  Future<void> carregarClube() async {
    final clube = await ClubeStorage.carregar();
    setState(() {
      clubeAtual = clube;
      if (clubesInfo.containsKey(clube)) {
        regiao = clubesInfo[clube]!['regiao']!;
        distrito = clubesInfo[clube]!['distrito']!;
        regiaoDesc = clubesInfo[clube]!['regiaoDesc']!;
        distritoDesc = clubesInfo[clube]!['distritoDesc']!;
      }
    });
  }

  Future<void> carregarDados() async {
    final status = await AtributosStorage.carregarStatus();
    final a = await AtributosStorage.carregar();
    final p = await AtributosStorage.carregarPontos();
    final novoCargo = await AtributosStorage.carregarCargo();
    setState(() {
      atributos = a;
      pontosRestantes = p;
      dinheiro = status['dinheiro'] ?? 0;
      inteligencia = status['inteligencia'] ?? 0;
      felicidade = status['felicidade'] ?? 0;
      saude = status['saude'] ?? 0;
      xp = status['xp'] ?? 0;
      idade = (status['idade'] as num?)?.toDouble() ?? 18.0;
      cargo = novoCargo;
    });
  }

  void _showEditDialog(BuildContext context) {
    String? clubeSelecionado;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF4A148C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Atualizar Clube',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: DropdownButtonFormField<String>(
          value: clubeSelecionado,
          dropdownColor: const Color(0xFF4A148C),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color(0xFF4A148C),
            hintText: 'Selecione seu clube',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          iconEnabledColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          items: clubesInfo.keys.map((String clube) {
            return DropdownMenuItem<String>(
              value: clube,
              child: Text(clube, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            clubeSelecionado = newValue;
            ClubeStorage.salvar(clubeSelecionado!);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (clubeSelecionado != null &&
                  clubesInfo.containsKey(clubeSelecionado)) {
                setState(() {
                  regiao = clubesInfo[clubeSelecionado]!['regiao']!;
                  distrito = clubesInfo[clubeSelecionado]!['distrito']!;
                  regiaoDesc = clubesInfo[clubeSelecionado]!['regiaoDesc']!;
                  distritoDesc = clubesInfo[clubeSelecionado]!['distritoDesc']!;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar('Perfil'),
      backgroundColor: const Color(0xFF3B1E5C),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 80,
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cargo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${idade.toInt()} anos',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          clubeAtual,
                          style: const TextStyle(color: Colors.white54),
                        ),
                        TextButton(
                          onPressed: () => _showEditDialog(context),
                          child: const Text(
                            'Atualizar Clube',
                            style: TextStyle(color: Colors.amber),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 140),
                        child: infoCard(Icons.map, 'Região', regiaoDesc),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 140),
                        child: infoCard(
                          Icons.location_city,
                          'Distrito $distrito',
                          distritoDesc,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Recursos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth / 3 - 16,
                          child: infoCard(
                            Icons.attach_money,
                            'Dinheiro',
                            'R\$ $dinheiro',
                          ),
                        ),
                        SizedBox(
                          width: constraints.maxWidth / 3 - 16,
                          child: infoCard(
                            Icons.school,
                            'Inteligência',
                            inteligencia.toString(),
                          ),
                        ),
                        SizedBox(
                          width: constraints.maxWidth / 3 - 16,
                          child: infoCard(
                            Icons.emoji_emotions,
                            'Felicidade',
                            felicidade.toString(),
                          ),
                        ),
                        SizedBox(
                          width: constraints.maxWidth / 3 - 16,
                          child: infoCard(
                            Icons.favorite,
                            'Saúde',
                            saude.toString(),
                          ),
                        ),
                        SizedBox(
                          width: constraints.maxWidth / 3 - 16,
                          child: infoCard(Icons.star, 'Experiência', '$xp XP'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'Pontos restantes: $pontosRestantes',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                atributoCard('Oratória'),
                atributoCard('Liderança'),
                atributoCard('Empatia'),
                atributoCard('Organização'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget infoCard(IconData icon, String label, String value) {
    return Card(
      color: const Color(0xFF6A1B9A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget atributoCard(String nome) {
    int nivel = atributos[nome] ?? 0;
    double progresso = nivel / 50;
    bool atingiuLimite = nivel >= 50;

    return Card(
      color: const Color(0xFF6A1B9A),
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nome,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progresso.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: Colors.white24,
              color: atingiuLimite ? Colors.green : Colors.amber,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  atingiuLimite ? 'Nível máximo' : 'Nível: $nivel',
                  style: const TextStyle(color: Colors.white70),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: atingiuLimite ? Colors.grey : Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: (!atingiuLimite && pontosRestantes > 0)
                      ? () {
                          setState(() {
                            atributos[nome] = nivel + 1;
                            pontosRestantes -= 1;
                          });
                          AtributosStorage.salvar(atributos);
                          AtributosStorage.salvarPontos(pontosRestantes);
                        }
                      : null,
                  child: Text(atingiuLimite ? 'Máx' : 'Evoluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
