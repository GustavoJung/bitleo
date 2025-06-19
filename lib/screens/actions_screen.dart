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
                    ),
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
                          color: Color(0xFFD1B3FF),
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
                          backgroundColor: const Color(0xFFD1B3FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
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

  bool canPerformAction(Map<String, dynamic> action, Map<String, int> status) {
    if ((action['label'] == 'Trabalhar' || action['label'] == 'Campanha') &&
        status['saude']! < 30)
      return false;
    if ((action['label'] == 'Campanha' || action['label'] == 'Estudar') &&
        status['felicidade']! < 20)
      return false;
    if (action['label'] == 'Estudar' && status['inteligencia']! < 15)
      return false;
    return true;
  }

  String requirementText(Map<String, dynamic> action) {
    List<String> reqs = [];
    if (action['label'] == 'Trabalhar' || action['label'] == 'Campanha') {
      reqs.add('Saúde ≥ 30');
    }
    if (action['label'] == 'Campanha' || action['label'] == 'Estudar') {
      reqs.add('Felicidade ≥ 20');
    }
    if (action['label'] == 'Estudar') {
      reqs.add('Inteligência ≥ 15');
    }
    return reqs.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final status =
        ModalRoute.of(context)?.settings.arguments as Map<String, int>? ?? {};
    final saude = status['saude'] ?? 0;
    final felicidade = status['felicidade'] ?? 0;
    final inteligencia = status['inteligencia'] ?? 0;

    final List<Map<String, dynamic>> actions = [
      {
        'label': 'Trabalhar',
        'description': 'Ganhe dinheiro, mas fique um pouco mais estressado.',
        'icon': Icons.work,
        'effects': {'dinheiro': 20, 'felicidade': -3, 'xp': 3},
        'info': 'Trabalhar aumenta sua renda, necessário para eventos e ações.',
      },
      {
        'label': 'Estudar',
        'description': 'Aumente sua inteligência e XP com dedicação.',
        'icon': Icons.school,
        'effects': {'inteligencia': 5, 'felicidade': -2, 'xp': 3},
        'info': 'Estudar ajuda a atingir cargos que exigem inteligência.',
      },
      {
        'label': 'Campanha',
        'description': 'Engaje a comunidade e evolua no clube.',
        'icon': Icons.volunteer_activism,
        'effects': {'felicidade': 5, 'xp': 5, 'dinheiro': -10},
        'info': 'Realizar campanhas dá XP para crescer no clube.',
      },
      {
        'label': 'Descansar',
        'description': 'Recupere saúde e bem-estar. Todo líder precisa disso!',
        'icon': Icons.bedtime,
        'effects': {'saude': 10, 'felicidade': 10, 'xp': 1},
        'info': 'Essencial para manter felicidade e saúde equilibradas.',
      },
      {
        'label': 'Organizar Evento',
        'description': 'Mostre sua liderança e ganhe XP.',
        'icon': Icons.event,
        'effects': {
          'organização': 3,
          'xp': 5,
          'felicidade': 2,
          'dinheiro': -10,
        },
        'info': 'Organizar eventos melhora sua organização e dá XP.',
      },
      {
        'label': 'Participar de Reunião',
        'description': 'Melhore sua oratória e ganhe experiência.',
        'icon': Icons.groups,
        'effects': {'oratória': 2, 'xp': 3},
        'info': 'Ótimo para desenvolver oratória e avançar nos cargos.',
      },
      {
        'label': 'Mentorar Novato',
        'description': 'Aumente sua empatia e fortaleça o clube.',
        'icon': Icons.support,
        'effects': {'empatia': 3, 'xp': 4, 'felicidade': 2},
        'info': 'Mentorar ajuda a crescer como líder e aumenta empatia.',
      },
      {
        'label': 'Redes Sociais',
        'description': 'Divulgue ações e mostre seu talento digital.',
        'icon': Icons.share,
        'effects': {'oratória': 2, 'organização': 1, 'xp': 4},
        'info': 'Trabalhar com redes melhora oratória e organização.',
      },
      {
        'label': 'Reunião Distrital',
        'description': 'Interaja com outros clubes e expanda sua visão.',
        'icon': Icons.location_city,
        'effects': {'oratória': 3, 'empatia': 2, 'xp': 6, 'dinheiro': -15},
        'info': 'Reuniões distritais são ótimas para conexões e XP.',
      },
    ];

    return Scaffold(
      appBar: buildCustomAppBar('Escolher Ação'),
      extendBodyBehindAppBar: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF512DA8), Color(0xFF121212)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            final pode = true; //canPerformAction(action, status);
            final reqText = requirementText(action);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Opacity(
                    opacity: pode ? 1.0 : 0.4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          action['icon'],
                          color: pode
                              ? const Color(0xFFD1B3FF)
                              : Colors.white38,
                          size: 32,
                        ),
                        title: Text(
                          action['label'],
                          style: TextStyle(
                            color: pode ? Colors.white : Colors.white38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          action['description'],
                          style: TextStyle(
                            color: pode ? Colors.white70 : Colors.white38,
                          ),
                        ),
                        trailing: Tooltip(
                          message: pode ? 'Saiba mais' : reqText,
                          child: IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color: pode ? Colors.white70 : Colors.white38,
                            ),
                            onPressed: () => showInfoDialog(
                              context,
                              action['label'],
                              action['info'] ?? '',
                            ),
                          ),
                        ),
                        onTap: pode
                            ? () {
                                Navigator.pop(context);
                                onActionSelected(
                                  action['effects'] as Map<String, dynamic>,
                                  action['label'],
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Não pode: $reqText',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.deepPurple,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                      ),
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
