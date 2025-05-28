import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class ActionsScreen extends StatelessWidget {
  final Function(Map<String, dynamic>, String) onActionSelected;
  final Function(String) onShowInfo;

  const ActionsScreen({
    super.key,
    required this.onActionSelected,
    required this.onShowInfo,
  });

  void showInfoDialog(BuildContext context, String title, String description) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Fechar',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        'label': 'Trabalhar',
        'description': 'Ganhe dinheiro trabalhando.',
        'icon': Icons.work,
        'effects': {'dinheiro': 50, 'felicidade': -5, 'xp': 5},
      },
      {
        'label': 'Estudar',
        'description': 'Melhore sua inteligência.',
        'icon': Icons.school,
        'effects': {'inteligencia': 5, 'felicidade': -2, 'xp': 5},
      },
      {
        'label': 'Campanha',
        'description': 'Ajude a comunidade e ganhe XP.',
        'icon': Icons.volunteer_activism,
        'effects': {'felicidade': 5, 'xp': 10, 'dinheiro': -10},
      },
      {
        'label': 'SEDEL',
        'description': 'Desenvolvimento de lideranças.',
        'icon': Icons.leaderboard,
        'effects': {'xp': 30, 'felicidade': 5, 'dinheiro': -50},
      },
      {
        'label': 'JALC',
        'description': 'Jogos do LEO Clube. Diversão garantida.',
        'icon': Icons.sports_esports,
        'effects': {'felicidade': 20, 'xp': 15, 'dinheiro': -40, 'saude': -5},
      },
      {
        'label': 'AcampaLEO',
        'description': 'Acampamento cheio de atividades.',
        'icon': Icons.park,
        'effects': {'felicidade': 25, 'xp': 20, 'dinheiro': -60, 'saude': -10},
      },
      {
        'label': 'Encontro de Regiões',
        'description': 'Integração com outros clubes.',
        'icon': Icons.group,
        'effects': {'felicidade': 10, 'xp': 15, 'dinheiro': -30},
      },
      {
        'label': 'Descansar',
        'description': 'Recupere sua saúde e felicidade.',
        'icon': Icons.bedtime,
        'effects': {'saude': 10, 'felicidade': 10, 'xp': 2},
      },
    ];

    return Scaffold(
      appBar: buildCustomAppBar('Escolher Ação'),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 100, bottom: 20),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(action['icon'], color: Colors.amber, size: 32),
                      title: Text(
                        action['label'],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        action['description'],
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.white70),
                        onPressed: () {
                           showInfoDialog(
                            context,
                            action['label'],
                            action['description'],
                        );
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                          onActionSelected(
                            action['effects'] as Map<String, dynamic>,
                            action['label'],
                          );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
