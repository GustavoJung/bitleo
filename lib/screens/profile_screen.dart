import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

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
                  const Icon(Icons.emoji_events,
                      color: Colors.amber, size: 100),
                  const SizedBox(height: 10),
                  Text(
                    cargo,
                    style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$idade anos',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            infoCard(Icons.attach_money, 'Dinheiro', 'R\$ $dinheiro'),
            infoCard(Icons.school, 'Inteligência', inteligencia.toString()),
            infoCard(
                Icons.emoji_emotions, 'Felicidade', felicidade.toString()),
            infoCard(Icons.favorite, 'Saúde', saude.toString()),
            infoCard(Icons.star, 'Experiência', '$xp XP'),
          ],
        ),
      ),
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
        trailing: Text(
          value,
          style: const TextStyle(
              fontSize: 18,
              color: Colors.amber,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
