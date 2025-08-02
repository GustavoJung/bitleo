import 'dart:ui';
import 'package:bitleo/services/firestore_service.dart';
import 'package:bitleo/widgets/action_card.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class ActionsScreen extends StatelessWidget {
  final Function(Map<String, dynamic>, String) onActionSelected;
  final Function(String) onShowInfo;
  final Map<String, int> status;
  final Map<String, int> atributos;

  const ActionsScreen({
    super.key,
    required this.onActionSelected,
    required this.onShowInfo,
    required this.status,
    required this.atributos,
  });

  void showInfoDialog(BuildContext context, String title, String description) {
    FirestoreService.marcarTelaVisitada('actions');
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Color(0xFFE1BEE7),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        textAlign: TextAlign.center,
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
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Fechar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }

  String getRequirementMessage(
    Map<String, dynamic> action,
    Map<String, int> todosDados,
  ) {
    final reqs = action['requisitos'] as Map<String, int>?;

    if (reqs == null) return 'Você não pode realizar esta ação no momento.';

    List<String> mensagens = [];

    for (final entry in reqs.entries) {
      final chave = entry.key.toLowerCase();
      final atual = todosDados[chave] ?? 0;
      if (atual < entry.value) {
        mensagens.add('${entry.key} ≥ ${entry.value} (atual: $atual)');
      }
    }

    if (mensagens.isEmpty) {
      return 'Você não pode realizar esta ação no momento.';
    }

    return 'Requisitos:\n${mensagens.join('\n')}';
  }

  bool canPerformAction(
    Map<String, dynamic> action,
    Map<String, int> todosDados,
  ) {
    final reqs = action['requisitos'] as Map<String, int>?;

    if (reqs == null) return true;

    for (final entry in reqs.entries) {
      final chave = entry.key.toLowerCase();
      final atual = todosDados[chave] ?? 0;
      if (atual < entry.value) return false;
    }

    return true;
  }

  String requirementText(
    Map<String, dynamic> action,
    Map<String, int> todosDados,
  ) {
    final reqs = action['requisitos'] as Map<String, int>?;

    if (reqs == null) return 'Sem requisitos.';

    List<String> mensagens = [];

    for (final entry in reqs.entries) {
      final chave = entry.key.toLowerCase();
      final atual = todosDados[chave] ?? 0;
      mensagens.add('${entry.key} ≥ ${entry.value} (atual: $atual)');
    }

    return mensagens.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final status = this.status;
    final atributos = this.atributos;
    final Map<String, int> todosDados = {
      ...status.map((k, v) => MapEntry(k.toLowerCase(), v)),
      ...atributos.map((k, v) => MapEntry(k.toLowerCase(), v)),
    };
    final actions = [
      {
        'label': 'Trabalhar',
        'description': 'Ganhe dinheiro, mas fique um pouco mais estressado.',
        'icon': Icons.work,
        'effects': {'dinheiro': 10, 'felicidade': -3, 'xp': 3},
        'info': 'Trabalhar aumenta sua renda, necessário para eventos e ações.',
        'requisitos': {'saude': 30},
      },
      {
        'label': 'Estudar',
        'description': 'Aumente sua inteligência e XP com dedicação.',
        'icon': Icons.school,
        'effects': {'inteligencia': 5, 'felicidade': -2, 'xp': 3},
        'info': 'Estudar ajuda a atingir cargos que exigem inteligência.',
        'requisitos': {'saude': 10, 'felicidade': 15},
      },
      {
        'label': 'Campanha',
        'description': 'Engaje a comunidade e evolua no clube.',
        'icon': Icons.volunteer_activism,
        'effects': {'felicidade': 5, 'xp': 5, 'dinheiro': -5},
        'info': 'Realizar campanhas dá XP para crescer no clube.',
        'requisitos': {'saude': 20, 'felicidade': 15},
      },
      {
        'label': 'Descansar',
        'description': 'Recupere saúde e bem-estar. Todo líder precisa disso!',
        'icon': Icons.bedtime,
        'effects': {'saude': 15, 'felicidade': 20, 'xp': 1},
        'info': 'Essencial para manter felicidade e saúde equilibradas.',
      },
      {
        'label': 'Organizar Evento',
        'description': 'Mostre sua liderança e ganhe XP.',
        'icon': Icons.event,
        'effects': {'organização': 1, 'xp': 10, 'felicidade': 3},
        'info': 'Organizar eventos melhora sua organização e dá XP.',
        'requisitos': {'organização': 5},
      },
      {
        'label': 'Participar de Reunião',
        'description': 'Melhore sua oratória e ganhe experiência.',
        'icon': Icons.groups,
        'effects': {'oratória': 1, 'xp': 3},
        'info': 'Ótimo para desenvolver oratória e avançar nos cargos.',
      },
      {
        'label': 'Mentorar Novato',
        'description': 'Aumente sua empatia e fortaleça o clube.',
        'icon': Icons.support,
        'effects': {'empatia': 1, 'xp': 4, 'felicidade': 4},
        'info': 'Mentorar ajuda a crescer como líder e aumenta empatia.',
        'requisitos': {'Liderança': 10},
      },
      {
        'label': 'Redes Sociais',
        'description': 'Divulgue ações e mostre seu talento digital.',
        'icon': Icons.share,
        'effects': {'oratória': 1, 'organização': 1, 'xp': 4},
        'info': 'Trabalhar com redes melhora oratória e organização.',
        'requisitos': {'felicidade': 15},
      },
      {
        'label': 'Reunião Distrital',
        'description': 'Interaja com outros clubes e expanda sua visão.',
        'icon': Icons.location_city,
        'effects': {'oratória': 1, 'empatia': 1, 'xp': 5, 'dinheiro': -15},
        'info': 'Reuniões distritais são ótimas para conexões e XP.',
        'requisitos': {'empatia': 3, 'felicidade': 20},
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
              final pode = canPerformAction(action, todosDados);
              final reqText = requirementText(action, todosDados);

              final String label = action['label'] as String;
              final String description = action['description'] as String;
              final String info = action['info'] as String;
              final IconData icon = action['icon'] as IconData;
              final Map<String, dynamic> effects =
                  action['effects'] as Map<String, dynamic>;

              return ActionCard(
                action: action,
                pode: pode,
                reqText: reqText,
                onTap: () {
                  if (pode) {
                    Navigator.pop(context);
                    onActionSelected(effects, label);
                  } else {
                    final mensagem = getRequirementMessage(action, todosDados);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          mensagem,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.deepPurple,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
                onInfo: () => showInfoDialog(context, label, info),
              );
            },
          ),
        ),
      ),
    );
  }
}
