import 'dart:ui';
import 'package:flutter/material.dart';

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
        child: Container(
          color: const Color(
            0xFF6A1B9A,
          ).withOpacity(0.6), // Roxo sólido translúcido
        ),
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
    actions: actions
        .map(
          (widget) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Tooltip(
              message: _getTooltipForAction(widget),
              child: widget,
            ),
          ),
        )
        .toList(),
  );
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
        default:
          return 'Ação';
      }
    }
  }
  return 'Ação';
}
