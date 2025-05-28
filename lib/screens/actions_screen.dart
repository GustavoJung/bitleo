import 'package:flutter/material.dart';

class ActionsScreen extends StatelessWidget {
  final Function(String, Map<String, int>) onActionSelected;
  final Function(String) onShowInfo;

  const ActionsScreen({
    super.key,
    required this.onActionSelected,
    required this.onShowInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha sua Ação')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          actionCard(context, 'Trabalhar', Icons.work, 'Ganhar dinheiro.',
              {'dinheiro': 50, 'felicidade': -2, 'saude': -2}),
          actionCard(context, 'Fazer Campanha', Icons.volunteer_activism,
              'Ajudar o clube e ganhar XP.',
              {'xp': 10, 'felicidade': 5, 'dinheiro': 20}),
          actionCard(context, 'Estudar', Icons.school, 'Aumentar inteligência.',
              {'inteligencia': 5, 'saude': -1}),
          actionCard(context, 'Cuidar da Saúde', Icons.favorite,
              'Melhorar sua saúde.', {'saude': 10}),
          actionCard(context, 'AcampaLEO', Icons.emoji_people,
              'Evento de integração.', {'xp': 20, 'felicidade': 15, 'dinheiro': -30}),
          actionCard(context, 'SEDEL', Icons.leaderboard,
              'Desenvolvimento de liderança.',
              {'xp': 25, 'inteligencia': 10, 'dinheiro': -40}),
          actionCard(context, 'JALC', Icons.sports_soccer,
              'Jogos e diversão.', {'xp': 15, 'felicidade': 10, 'saude': -5, 'dinheiro': -20}),
          actionCard(context, 'Encontro de Regiões', Icons.groups,
              'Networking e aprendizado.', {'xp': 20, 'felicidade': 10, 'dinheiro': -25}),
        ],
      ),
    );
  }

  Widget actionCard(BuildContext context, String label, IconData icon,
      String description, Map<String, int> changes) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange, size: 32),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.amber),
          onPressed: () {
            onShowInfo(label);
          },
        ),
        onTap: () {
          onActionSelected(label, changes);
          Navigator.pop(context);
        },
      ),
    );
  }
}
