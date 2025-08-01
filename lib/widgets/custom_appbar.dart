import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/name_screen.dart';

/// AppBar simples (sem ações)
PreferredSizeWidget buildCustomAppBar(String title) {
  return AppBar(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    flexibleSpace: ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(0),
        bottomRight: Radius.circular(0),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(color: const Color(0xFF6A1B9A).withOpacity(0.6)),
      ),
    ),
    title: Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  );
}

/// AppBar com ações e tooltips
PreferredSizeWidget buildCustomAppBarWithActions({
  required String title,
  required List<Widget> actions,
}) {
  return AppBar(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    flexibleSpace: ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(0),
        bottomRight: Radius.circular(0),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(color: const Color(0xFF6A1B9A).withOpacity(0.6)),
      ),
    ),
    title: Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    actions: [..._addSpacingBetweenActions(actions), const SizedBox(width: 12)],
  );
}

List<Widget> _addSpacingBetweenActions(List<Widget> actions) {
  final spacedActions = <Widget>[];
  for (int i = 0; i < actions.length; i++) {
    final widget = actions[i];
    Widget finalWidget = widget;

    if (widget is IconButton) {
      final icon = widget.icon;
      if (icon is Icon) {
        finalWidget = Tooltip(
          message: _getTooltipForAction(widget),
          child: widget,
        );
      }
    }

    spacedActions.add(finalWidget);

    if (i != actions.length - 1) {
      spacedActions.add(const SizedBox(width: 8)); // espaçamento entre ícones
    }
  }
  return spacedActions;
}

/// Função auxiliar para definir textos de hover
String _getTooltipForAction(Widget widget) {
  if (widget is IconButton) {
    final icon = widget.icon;
    if (icon is Icon) {
      switch (icon.icon) {
        case Icons.person:
          return 'Perfil';
        case Icons.emoji_events:
          return 'Conquistas';
        case Icons.settings:
          return 'Configurações';
        case Icons.help:
          return 'Ajuda';
        case Icons.logout:
          return 'Sair';
        default:
          return 'Ação';
      }
    }
  }
  return 'Ação';
}

/// Botão de logout pronto pra usar no AppBar
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.white),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const NameScreen()),
          (route) => false,
        );
      },
    );
  }
}
