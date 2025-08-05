import 'package:flutter/material.dart';

class AnimatedStoryItem extends StatelessWidget {
  final String ano;
  final String descricao;

  const AnimatedStoryItem({
    super.key,
    required this.ano,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/quest.png', width: 28, height: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ano,
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
                  descricao,
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedStoryList extends StatefulWidget {
  final List<String> story;
  final GlobalKey<AnimatedListState> listKey;
  final ScrollController? scrollController;

  const AnimatedStoryList({
    Key? key,
    required this.story,
    required this.listKey,
    this.scrollController, // <-- importante!
  }) : super(key: key);

  @override
  State<AnimatedStoryList> createState() => _AnimatedStoryListState();
}

class _AnimatedStoryListState extends State<AnimatedStoryList> {
  @override
  Widget build(BuildContext context) {
    final reversed = widget.story;
    return AnimatedList(
      key: widget.listKey,
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      initialItemCount: reversed.length,
      itemBuilder: (context, index, animation) {
        final texto = reversed[index];
        final partes = texto.split(': ');
        final ano = partes.first;
        final descricao = partes.length > 1 ? partes.sublist(1).join(': ') : '';

        return SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1.0,
          child: AnimatedStoryItem(ano: ano, descricao: descricao),
        );
      },
    );
  }
}
