import 'dart:ui';
import 'package:flutter/material.dart';

/// AppBar simples (sem ações)
PreferredSizeWidget buildCustomAppBar(String title) {
  return AppBar(
    backgroundColor: Color(0xFF6A1B9A).withOpacity(0.3),
    elevation: 0,
    centerTitle: true,
    title: Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    flexibleSpace: ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(0),
        bottomRight: Radius.circular(0),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(color: Colors.black.withOpacity(0.3)),
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFFF7043)),
  );
}

/// AppBar com ações (ícones)
PreferredSizeWidget buildCustomAppBarWithActions({
  required String title,
  required List<Widget> actions,
}) {
  return AppBar(
    backgroundColor: Color(0xFF6A1B9A).withOpacity(0.3),
    elevation: 0,
    centerTitle: true,
    title: Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    flexibleSpace: ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(0),
        bottomRight: Radius.circular(0),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(color: Colors.black.withOpacity(0.3)),
      ),
    ),
    iconTheme: const IconThemeData(color: Color.fromARGB(255, 128, 2, 206)),
    actions: actions,
  );
}
