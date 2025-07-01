import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'splash_screen.dart';
import 'dart:ui';
import 'package:animated_background/animated_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> with TickerProviderStateMixin {
  final _nomeController = TextEditingController();
  final _idadeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String? _clubeSelecionado;

  final List<String> clubes = [
    'LEO Clube Alpha',
    'LEO Clube Beta',
    'LEO Clube Gama',
    'Outro',
  ];

  bool _loading = false;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _registerEmail() async {
    final nome = _nomeController.text.trim();
    final idade = _idadeController.text.trim();
    final clube = _clubeSelecionado;
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (nome.isEmpty ||
        idade.isEmpty ||
        clube == null ||
        email.isEmpty ||
        senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
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
          'idade': int.parse(idade),
          'clube': clube,
          'email': email,
          'criadoEm': FieldValue.serverTimestamp(),
        },
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao registrar: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loginEmail() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe e-mail e senha!')));
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.signInWithEmail(email, senha);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao fazer login: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() => _loading = true);
    try {
      final userCredential = await _authService.signInWithGoogle();
      final uid = userCredential.user!.uid;

      final doc = await _firestoreService.getUserDocument(uid);

      if (!doc.exists) {
        await _firestoreService.createUserDocument(
          uid: uid,
          data: {
            'nome': userCredential.user!.displayName ?? '',
            'email': userCredential.user!.email ?? '',
            'criadoEm': FieldValue.serverTimestamp(),
          },
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao fazer login: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: Colors.white24,
            spawnOpacity: 0.0,
            opacityChangeRate: 0.25,
            minOpacity: 0.1,
            maxOpacity: 0.4,
            spawnMinSpeed: 30.0,
            spawnMaxSpeed: 70.0,
            spawnMinRadius: 1.0,
            spawnMaxRadius: 4.0,
            particleCount: 40,
          ),
        ),
        vsync: this,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6A1B9A), Color(0xFF121212)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
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
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/Logo_rgb_Leo_2C.png',
                            width: 140,
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Simulador de Vida de LEO Clube',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _nomeController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Digite seu nome'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _idadeController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Digite sua idade'),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _clubeSelecionado,
                            dropdownColor: Colors.black87,
                            decoration: _inputDecoration('Selecione seu clube'),
                            items: clubes
                                .map(
                                  (clube) => DropdownMenuItem(
                                    value: clube,
                                    child: Text(
                                      clube,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _clubeSelecionado = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
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
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: _buttonStyle(),
                                        onPressed: _registerEmail,
                                        child: const Text('Registrar conta'),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: _buttonStyle(),
                                        onPressed: _loginEmail,
                                        child: const Text('Entrar com e-mail'),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        style: _buttonStyleOutlined(),
                                        icon: const Icon(Icons.login),
                                        label: const Text('Entrar com Google'),
                                        onPressed: _loginGoogle,
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
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54, fontFamily: 'Poppins'),
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
    );
  }

  ButtonStyle _buttonStyleOutlined() {
    return OutlinedButton.styleFrom(
      side: const BorderSide(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(vertical: 14),
      foregroundColor: Colors.white,
    );
  }
}
