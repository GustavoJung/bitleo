import 'package:bitleo/services/atributos_storage.dart';
import 'package:bitleo/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/conquista.dart'; // Ajuste o import se o helper estiver em outro local

class ConquistasScreen extends StatefulWidget {
  const ConquistasScreen({super.key});

  @override
  State<ConquistasScreen> createState() => _ConquistasScreenState();
}

class _ConquistasScreenState extends State<ConquistasScreen> {
  List<Conquista> conquistas = ConquistaHelper.getListaConquistas();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    FirestoreService.marcarTelaVisitada(uid, 'conquistas');
    _carregarConquistas();
  }

  Future<void> _carregarConquistas() async {
    final desbloqueadas = await FirestoreService.conquistasDesbloqueadas(uid);
    final resgatadas = await FirestoreService.conquistasResgatadas(uid);
    final progresso = await FirestoreService.progressoConquistas(
      uid,
    ); // Implemente para progresso acumulativo

    setState(() {
      for (var c in conquistas) {
        c.desbloqueada = desbloqueadas.contains(c.titulo);
        c.podeResgatar = c.desbloqueada && !resgatadas.contains(c.titulo);

        // Atualiza o progresso, se tiver
        if (c.progressoNecessario != null) {
          c.progressoAtual = progresso[c.titulo] ?? 0; // aqui puxa do banco!
        }
      }
    });
  }

  Future<bool> _verificarResgate(String titulo) async {
    final resgatadas = await FirestoreService.conquistasResgatadas(uid);
    return resgatadas.contains(titulo);
  }

  Future<void> _resgatarRecompensa(String titulo) async {
    int pontosAtuais = await AtributosStorageFirestore.carregarPontos();
    await AtributosStorageFirestore.salvarPontos(pontosAtuais + 1);
    await FirestoreService.registrarResgateConquista(uid, titulo);

    setState(() {
      for (var c in conquistas) {
        if (c.titulo == titulo) {
          c.podeResgatar = false;
          break;
        }
      }
    });
    final contextDoCard = context;
    Future.delayed(const Duration(milliseconds: 100), () {
      final state = contextDoCard
          .findAncestorStateOfType<_ConquistaCardState>();
      state?.triggerPulse();
    });
  }

  void _mostrarDetalhes(Conquista conquista) async {
    final jaResgatado = await _verificarResgate(conquista.titulo);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar popup de conquista',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scale = Tween<double>(begin: 0.85, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );
        final opacity = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        bool ehSecreta = conquista.secreta && !conquista.desbloqueada;

        return FadeTransition(
          opacity: opacity,
          child: ScaleTransition(
            scale: scale,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: ehSecreta
                        ? const LinearGradient(
                            colors: [Color(0xFF2A004F), Color(0xFF1E1E2E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF1E1E2E), Color(0xFF2A004F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              conquista.desbloqueada
                                  ? Icons.emoji_events
                                  : Icons.lock_outline,
                              color: conquista.desbloqueada
                                  ? Colors.amber
                                  : Colors.grey[400],
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ehSecreta ? '???' : conquista.titulo,
                                style: TextStyle(
                                  color: conquista.desbloqueada
                                      ? Colors.amberAccent
                                      : Colors.grey[400],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ehSecreta
                              ? (conquista.dica ??
                                    'Conquista secreta, tente desbloquear!')
                              : conquista.descricao,
                          style: TextStyle(
                            color: conquista.desbloqueada
                                ? Colors.white70
                                : Colors.grey[500],
                            fontSize: 15,
                            height: 1.5,
                            fontStyle: ehSecreta ? FontStyle.italic : null,
                          ),
                        ),
                        if (!ehSecreta && conquista.progressoNecessario != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value:
                                  (conquista.progressoAtual ?? 0) /
                                  (conquista.progressoNecessario!),
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.amberAccent,
                              ),
                            ),
                          ),
                        if (!ehSecreta && conquista.progressoNecessario != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${conquista.progressoAtual ?? 0} / ${conquista.progressoNecessario}',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (!jaResgatado && conquista.desbloqueada)
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/Recompensa.png',
                                width: 28,
                                height: 28,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '+1 ponto de atributo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (conquista.desbloqueada && !jaResgatado)
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await _resgatarRecompensa(conquista.titulo);
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.deepPurple,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 3),
                                      content: const Text(
                                        'Recompensa resgatada com sucesso!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                },

                                label: const Text(
                                  'Resgatar',
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amberAccent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Fechar',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final desbloqueadas = conquistas.where((c) => c.desbloqueada).length;
    final total = conquistas.length;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: buildCustomAppBar('Conquistas'),
        backgroundColor: const Color(0xFF3B1E5C),
        body: Container(
          width: double.infinity,
          color: const Color(0xFF3B1E5C),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '$desbloqueadas de $total conquistas desbloqueadas',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: conquistas.map((conquista) {
                        return MouseRegion(
                          cursor: conquista.desbloqueada
                              ? SystemMouseCursors.click
                              : SystemMouseCursors.basic,
                          child: GestureDetector(
                            onTap: () => _mostrarDetalhes(conquista),
                            child: ConquistaCard(conquista: conquista),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConquistaCard extends StatefulWidget {
  final Conquista conquista;

  const ConquistaCard({super.key, required this.conquista});

  @override
  State<ConquistaCard> createState() => _ConquistaCardState();
}

class _ConquistaCardState extends State<ConquistaCard>
    with TickerProviderStateMixin {
  late AnimationController pulseController;
  late AnimationController blinkController;
  late Animation<double> scaleAnimation;
  late Animation<double> opacityAnimation;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeOutBack),
    );

    opacityAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: blinkController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    pulseController.dispose();
    blinkController.dispose();
    super.dispose();
  }

  void triggerPulse() {
    pulseController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final desbloqueada = widget.conquista.desbloqueada;
    final podeResgatar = widget.conquista.podeResgatar;
    final secreta = widget.conquista.secreta && !desbloqueada;

    // Aqui fica o cálculo do progresso certinho:
    final int progresso = desbloqueada
        ? (widget.conquista.progressoNecessario ?? 0)
        : (widget.conquista.progressoAtual ?? 0);

    final cardContent = Container(
      width: 220,
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: desbloqueada
            ? const LinearGradient(
                colors: [Color(0xFF1E1E2E), Color(0xFF2A004F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF2A2A2A), Color(0xFF1C1C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: desbloqueada ? Colors.amber.withOpacity(0.6) : Colors.white24,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: desbloqueada
                ? Colors.purpleAccent.withOpacity(0.4)
                : Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                desbloqueada ? Icons.emoji_events : Icons.lock_outline,
                color: desbloqueada ? Colors.amber : Colors.grey[500],
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                secreta ? '???' : widget.conquista.titulo,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: desbloqueada ? Colors.white : Colors.grey[400],
                  fontStyle: secreta ? FontStyle.italic : null,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  secreta
                      ? (widget.conquista.dica ??
                            'Conquista secreta, tente desbloquear!')
                      : widget.conquista.descricao,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: desbloqueada ? Colors.white70 : Colors.grey[500],
                    fontStyle: secreta ? FontStyle.italic : null,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!secreta && widget.conquista.progressoNecessario != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value:
                        (progresso) / (widget.conquista.progressoNecessario!),
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.amberAccent,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '$progresso / ${widget.conquista.progressoNecessario}',
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (!desbloqueada)
            const Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.lock, color: Colors.grey, size: 20),
            ),
          if (podeResgatar)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Image.asset('assets/images/Recompensa.png'),
                ),
              ),
            ),
        ],
      ),
    );

    Widget animated = ScaleTransition(
      scale: scaleAnimation,
      child: podeResgatar
          ? FadeTransition(opacity: opacityAnimation, child: cardContent)
          : cardContent,
    );

    return animated;
  }

  void animatePulseExternamente() => triggerPulse();
}
