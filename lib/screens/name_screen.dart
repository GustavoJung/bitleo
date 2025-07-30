import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'splash_screen.dart';
import 'dart:ui';
import 'package:animated_background/animated_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> with TickerProviderStateMixin {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _loading = false;
  bool _isCreatingAccount = false;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  var _animationController;
  var _logoAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    _logoAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _checkLoggedIn();
  }

  Future<void> _checkLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _goToSplash();
    }
  }

  Future<void> _registerEmail() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();
    final emailRegex = RegExp(r"^[^@]+@[^@]+\.[^@]+$");

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      _showMessage('Preencha todos os campos!');
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      _showMessage('Informe um e-mail válido!');
      return;
    }

    setState(() => _loading = true);

    try {
      final userCredential = await _authService.signUpWithEmail(email, senha);
      final uid = userCredential.user!.uid;

      await _firestoreService.createUserDocument(
        uid: uid,
        data: {
          'nome': nome,
          'email': email,
          'criadoEm': FieldValue.serverTimestamp(),
        },
      );

      await _firestoreService.updateUserName(uid, nome);

      _goToSplash();
    } catch (e) {
      _showFirebaseError(e, 'Erro ao registrar.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loginEmail() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();
    final emailRegex = RegExp(r"^[^@]+@[^@]+\.[^@]+$");

    if (email.isEmpty || senha.isEmpty) {
      _showMessage('Informe e-mail e senha!');
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      _showMessage('Informe um e-mail válido!');
      return;
    }

    setState(() => _loading = true);

    try {
      final userCredential = await _authService.signInWithEmail(email, senha);
      final uid = userCredential.user!.uid;

      final doc = await _firestoreService.getUserDocument(uid);
      final nome = (doc.data()?['nome'] as String?) ?? '';

      if (nome.isNotEmpty) {
        await _firestoreService.updateUserName(uid, nome);
      }

      _goToSplash();
    } catch (e) {
      _showFirebaseError(e, 'Erro ao fazer login.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() => _loading = true);
    try {
      final userCredential = await _authService.signInWithGoogle();
      final uid = userCredential.user!.uid;
      final nome = userCredential.user!.displayName ?? '';

      final doc = await _firestoreService.getUserDocument(uid);

      if (!doc.exists) {
        await _firestoreService.createUserDocument(
          uid: uid,
          data: {
            'nome': nome,
            'email': userCredential.user!.email ?? '',
            'criadoEm': FieldValue.serverTimestamp(),
          },
        );
      } else {
        await _firestoreService.updateUserName(uid, nome);
      }

      _goToSplash();
    } catch (e) {
      _showFirebaseError(e, 'Erro ao fazer login com Google.');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _goToSplash() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Navigator.canPop(context)) {
        Navigator.popAndPushNamed(context, '/splash');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMessageSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showFirebaseError(Object e, String defaultMessage) {
    String mensagem = defaultMessage;

    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          mensagem = 'O e-mail informado é inválido.';
          break;
        case 'user-disabled':
          mensagem = 'Este usuário foi desativado.';
          break;
        case 'user-not-found':
          mensagem = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          mensagem = 'Senha incorreta.';
          break;
        case 'email-already-in-use':
          mensagem = 'Este e-mail já está em uso.';
          break;
        case 'operation-not-allowed':
          mensagem = 'Operação não permitida.';
          break;
        case 'weak-password':
          mensagem = 'A senha é muito fraca.';
          break;
        default:
          mensagem =
              "Falha ao fazer login. Verifique suas credenciais ou contato um administrador.";
      }
    }

    _showMessage(mensagem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A1B9A), Color(0xFF121212)],
          ),
        ),
        child: AnimatedBackground(
          behaviour: RacingLinesBehaviour(
            direction: LineDirection.Ttb,
            numLines: 40,
          ),
          vsync: this,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: _logoAnimation,
                            child: Image.asset(
                              'assets/images/Logo_rgb_Leo_2C.png',
                              width: 140,
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Pronto(a) para liderar e servir no \nMundo do LEO Clube',
                            style: TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          if (_isCreatingAccount) ...[
                            TextField(
                              controller: _nomeController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration('Digite seu nome'),
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('E-mail'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _senhaController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Senha'),
                          ),
                          const SizedBox(height: 20),
                          _loading
                              ? const CircularProgressIndicator()
                              : Column(
                                  children: [
                                    if (_isCreatingAccount) ...[
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: _buttonStyle(),

                                          onPressed: _registerEmail,
                                          child: const Text('Criar Conta'),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.resolveWith<
                                                Color
                                              >((Set<MaterialState> states) {
                                                if (states.contains(
                                                  MaterialState.hovered,
                                                )) {
                                                  return const Color.fromARGB(
                                                    60,
                                                    103,
                                                    51,
                                                    114,
                                                  ); // Fundo no hover
                                                }
                                                return Colors
                                                    .transparent; // Fundo padrão
                                              }),
                                          foregroundColor:
                                              MaterialStateProperty.resolveWith<
                                                Color
                                              >((Set<MaterialState> states) {
                                                if (states.contains(
                                                  MaterialState.hovered,
                                                )) {
                                                  return Colors
                                                      .white; // Texto no hover
                                                }
                                                return Colors
                                                    .white; // Texto padrão
                                              }),
                                          padding: MaterialStateProperty.all(
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isCreatingAccount = false;
                                          });
                                        },
                                        child: const Text(
                                          'Voltar ao login',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: _buttonStyle(),
                                          onPressed: _loginEmail,
                                          child: const Text(
                                            'Entrar com e-mail',
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      TextButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.resolveWith<
                                                Color
                                              >((Set<MaterialState> states) {
                                                if (states.contains(
                                                  MaterialState.hovered,
                                                )) {
                                                  return const Color.fromARGB(
                                                    60,
                                                    103,
                                                    51,
                                                    114,
                                                  ); // Fundo no hover
                                                }
                                                return Colors
                                                    .transparent; // Fundo padrão
                                              }),
                                          foregroundColor:
                                              MaterialStateProperty.resolveWith<
                                                Color
                                              >((Set<MaterialState> states) {
                                                if (states.contains(
                                                  MaterialState.hovered,
                                                )) {
                                                  return Colors
                                                      .white; // Texto no hover
                                                }
                                                return Colors
                                                    .white; // Texto padrão
                                              }),
                                          padding: MaterialStateProperty.all(
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isCreatingAccount = true;
                                          });
                                        },
                                        child: const Text('Criar nova conta'),
                                      ),
                                      // adicione dentro da função build, logo abaixo do botão "Entrar com e-mail":
                                      TextButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.resolveWith<
                                                Color
                                              >((Set<MaterialState> states) {
                                                if (states.contains(
                                                  MaterialState.hovered,
                                                )) {
                                                  return const Color.fromARGB(
                                                    60,
                                                    103,
                                                    51,
                                                    114,
                                                  ); // Fundo no hover
                                                }
                                                return Colors
                                                    .transparent; // Fundo padrão
                                              }),
                                          foregroundColor:
                                              MaterialStateProperty.resolveWith<
                                                Color
                                              >((Set<MaterialState> states) {
                                                if (states.contains(
                                                  MaterialState.hovered,
                                                )) {
                                                  return Colors
                                                      .white; // Texto no hover
                                                }
                                                return Colors
                                                    .white; // Texto padrão
                                              }),
                                          padding: MaterialStateProperty.all(
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          final email = _emailController.text
                                              .trim();
                                          if (email.isEmpty) {
                                            _showMessage(
                                              'Informe um e-mail para redefinir a senha.',
                                            );
                                            return;
                                          }

                                          try {
                                            await FirebaseAuth.instance
                                                .sendPasswordResetEmail(
                                                  email: email,
                                                );
                                            _showMessageSuccess(
                                              'E-mail de redefinição enviado com sucesso.',
                                            );

                                            // Limpa os campos e volta ao modo login
                                            setState(() {
                                              _isCreatingAccount = false;
                                              _emailController.clear();
                                              _senhaController.clear();
                                              _nomeController.clear();
                                            });
                                          } catch (e) {
                                            _showFirebaseError(
                                              e,
                                              'Erro ao enviar e-mail de redefinição.',
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Esqueci minha senha',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white54,
        fontFamily: 'PressStart2P',
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6A1B9A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shadowColor: Colors.white,
    );
  }
}
