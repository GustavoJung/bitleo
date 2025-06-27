import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../services/conquistas_service.dart';

class ActionsScreen extends StatelessWidget {
  final Function(Map<String, dynamic>, String) onActionSelected;
  final Function(String) onShowInfo;

  const ActionsScreen({
    super.key,
    required this.onActionSelected,
    required this.onShowInfo,
  });

  void showInfoDialog(BuildContext context, String title, String description) {
    ConquistaService.marcarTelaVisitada('actions');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3B1E5C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          description,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
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
    final actions = [
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
      backgroundColor: const Color(0xFF3B1E5C),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ListView.builder(
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              final pode = true; //canPerformAction(action, status);
              final reqText = requirementText(action);

              final String label = action['label'] as String;
              final String description = action['description'] as String;
              final String info = action['info'] as String;
              final IconData icon = action['icon'] as IconData;
              final Map<String, dynamic> effects =
                  action['effects'] as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Opacity(
                      opacity: pode ? 1.0 : 0.4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B9A).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            icon,
                            color: pode ? Colors.amber : Colors.white38,
                            size: 32,
                          ),
                          title: Text(
                            label,
                            style: TextStyle(
                              color: pode ? Colors.white : Colors.white38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            description,
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
                              onPressed: () =>
                                  showInfoDialog(context, label, info),
                            ),
                          ),
                          onTap: pode
                              ? () {
                                  Navigator.pop(context);
                                  onActionSelected(effects, label);
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
      ),
    );
  }
}
