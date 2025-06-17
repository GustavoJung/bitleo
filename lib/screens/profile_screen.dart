import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    carregarDados();
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
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Atualizar Clube',
          style: TextStyle(color: Colors.amber),
        ),
        content: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Digite o nome do clube',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.amber),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              final clube = _controller.text.trim();
              if (clubesInfo.containsKey(clube)) {
                setState(() {
                  regiao = clubesInfo[clube]!['regiao']!;
                  distrito = clubesInfo[clube]!['distrito']!;
                  regiaoDesc = clubesInfo[clube]!['regiaoDesc']!;
                  distritoDesc = clubesInfo[clube]!['distritoDesc']!;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Aplicar', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar('Perfil'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 100,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cargo,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${idade.toInt()} anos',
                    style: const TextStyle(color: Colors.white70),
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
            ),
            const SizedBox(height: 30),
            infoCard(Icons.map, 'Região', regiaoDesc),
            infoCard(Icons.location_city, 'Distrito $distrito', distritoDesc),
            const SizedBox(height: 30),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                infoCardWrap(Icons.attach_money, 'Dinheiro', 'R\$ $dinheiro'),
                infoCardWrap(
                  Icons.school,
                  'Inteligência',
                  inteligencia.toString(),
                ),
                infoCardWrap(
                  Icons.emoji_emotions,
                  'Felicidade',
                  felicidade.toString(),
                ),
                infoCardWrap(Icons.favorite, 'Saúde', saude.toString()),
                infoCardWrap(Icons.star, 'Experiência', '$xp XP'),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Atributos',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Pontos restantes: $pontosRestantes',
              style: const TextStyle(color: Colors.white70),
            ),
            atributoCard('Oratória'),
            atributoCard('Liderança'),
            atributoCard('Empatia'),
            atributoCard('Organização'),
          ],
        ),
      ),
    );
  }

  Widget infoCardWrap(IconData icon, String label, String value) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 36,
      child: infoCard(icon, label, value),
    );
  }

  Widget infoCard(IconData icon, String label, String value) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber, size: 32),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ),
    );
  }

  Widget atributoCard(String nome) {
    int nivel = atributos[nome] ?? 0;
    double progresso = nivel / 50;
    bool atingiuLimite = nivel >= 50;

    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nome,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progresso.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white24,
              color: atingiuLimite ? Colors.green : Colors.amber,
            ),
            const SizedBox(height: 6),
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
