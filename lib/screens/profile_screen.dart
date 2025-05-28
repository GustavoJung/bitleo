import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final int dinheiro, inteligencia, felicidade, saude, xp, idade;
  final String cargo;

  const ProfileScreen({
    super.key,
    required this.dinheiro,
    required this.inteligencia,
    required this.felicidade,
    required this.saude,
    required this.xp,
    required this.idade,
    required this.cargo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            info('Dinheiro', 'R\$ $dinheiro', Icons.attach_money),
            info('Inteligência', inteligencia.toString(), Icons.school),
            info('Felicidade', felicidade.toString(), Icons.emoji_emotions),
            info('Saúde', saude.toString(), Icons.favorite),
            info('Experiência', '$xp XP', Icons.star),
            info('Idade', '$idade anos', Icons.cake),
            info('Cargo', cargo, Icons.emoji_events),
          ],
        ),
      ),
    );
  }

  Widget info(String label, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.orange, size: 32),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(
              fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
