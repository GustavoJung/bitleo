import 'package:flutter/material.dart';

class ActionCard extends StatefulWidget {
  final Map<String, dynamic> action;
  final bool pode;
  final String reqText;
  final Function() onTap;
  final Function() onInfo;

  const ActionCard({
    super.key,
    required this.action,
    required this.pode,
    required this.reqText,
    required this.onTap,
    required this.onInfo,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final String label = widget.action['label'] as String;
    final String description = widget.action['description'] as String;
    final IconData icon = widget.action['icon'] as IconData;

    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      cursor: widget.pode ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1E2E), Color(0xFF2A004F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.purpleAccent.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: hovering && widget.pode
                ? [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Opacity(
            opacity: widget.pode ? 1.0 : 0.4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          color: Color(0xFFCE93D8),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          color: Colors.white,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: Colors.white70,
                    size: 20,
                  ),
                  tooltip: widget.pode
                      ? 'Saiba mais'
                      : 'Você não pode realizar esta ação.\nRequisitos:\n${widget.reqText}',
                  onPressed: widget.onInfo,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
