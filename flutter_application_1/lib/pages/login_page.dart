import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoginMode = true;
  String _errorMessage = '';

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    _clearError();

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        _setError('Veuillez remplir tous les champs');
        return;
      }

      if (_isLoginMode) {
        try {
          final response = await supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );

          if (mounted && response.user != null) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } on AuthException {
          _setError('Email ou mot de passe incorrect');
        }
      } else {
        try {
          final response = await supabase.auth.signUp(
            email: email,
            password: password,
          );

          if (response.user != null && mounted) {
            await Future.delayed(const Duration(milliseconds: 500));

            final session = supabase.auth.currentSession;
            
            if (session != null && mounted) {
              // Session automatique créée, rediriger
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Inscription réussie!'),
                ),
              );
              Navigator.of(context).pushReplacementNamed('/home');
            } else if (mounted) {
              // Pas de session automatique, essayer de se connecter
              try {
                await supabase.auth.signInWithPassword(
                  email: email,
                  password: password,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inscription réussie!'),
                    ),
                  );
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              } catch (loginError) {
                _setError('Compte créé! Veuillez vous connecter avec vos identifiants.');
                setState(() => _isLoginMode = true);
                _emailController.clear();
                _passwordController.clear();
              }
            }
          }
        } on AuthException catch (e) {
          if (e.message.contains('already') || e.message.contains('exists')) {
            // Le compte existe, essayer de se connecter
            try {
              await supabase.auth.signInWithPassword(
                email: email,
                password: password,
              );

              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            } catch (e2) {
              _setError('Mot de passe incorrect');
            }
          } else {
            _setError('Erreur: ${e.message}');
          }
        }
      }
    } catch (error) {
      _setError('Une erreur est survenue: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setError(String message) {
    setState(() => _errorMessage = message);
  }

  void _clearError() {
    setState(() => _errorMessage = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Row(
          children: [
            const Icon(Icons.lock, color: Color.fromARGB(255, 7, 226, 255)),
            const SizedBox(width: 8),
            Text(
              _isLoginMode ? 'Connexion' : 'Inscription',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Color.fromARGB(255, 7, 226, 255),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Mot de passe
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Mot de passe',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Color.fromARGB(255, 7, 226, 255),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Message d'erreur
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              const SizedBox(height: 16),

              // Bouton connexion/inscription
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 7, 226, 255),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Text(
                        _isLoginMode
                            ? 'Se connecter'
                            : "S'inscrire",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Basculer entre connexion et inscription
              TextButton(
                onPressed: () {
                  _clearError();
                  setState(() => _isLoginMode = !_isLoginMode);
                },
                child: Text(
                  _isLoginMode
                      ? "Vous n'avez pas de compte? S'inscrire"
                      : 'Vous avez un compte? Se connecter',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
