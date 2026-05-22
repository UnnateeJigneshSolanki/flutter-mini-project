import 'package:flutter/material.dart';
import '../services/auth_service.dart';
const Color neonPurple = Color.fromARGB(255, 109, 24, 166);
const Color neonPink = Color.fromARGB(200, 171, 4, 171);
const Color neonBlue = Color.fromARGB(185, 90, 199, 199);
class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});
  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}
class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  final AuthService _authService = AuthService();
  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
  }

  Future<void> _submit() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (username.isEmpty || password.isEmpty) return;

    setState(() => _loading = true);
    bool ok;

    if (_isLogin) {
      ok = await _authService.login(username, password);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password')),
        );
      }
    } else {
      ok = await _authService.register(username, password);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username already exists')),
        );
      }
    }

    setState(() => _loading = false);
    if (ok) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
             
              Icon(
                Icons.shield_outlined,
                size: 72,
                color: neonBlue,
                shadows: [
                  Shadow(color: neonPink.withOpacity(0.5), blurRadius: 9),
                  Shadow(color: neonPurple.withOpacity(0.8), blurRadius: 6),
                ],
              ),
              const SizedBox(height: 20),

            
              Text(
                _isLogin ? 'Login' : 'Register',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: neonPink,
                  shadows: [
                    Shadow(color: neonBlue, blurRadius: 2),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildTextField('Username', _usernameCtrl),

              const SizedBox(height: 16),

              _buildTextField('Password', _passwordCtrl, obscure: true),

              const SizedBox(height: 24),

              _loading
                  ? const CircularProgressIndicator(color: neonPurple)
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonPurple,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _isLogin ? 'Login' : 'Register',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

              const SizedBox(height: 16),
            
  TextButton(
  onPressed: _toggleMode,
  child: RichText(
    text: TextSpan(
      style: const TextStyle(
        fontSize: 14,color: neonBlue, 
      ),
      children: [
        TextSpan(
          text: _isLogin ? "Don't have an account? "
              : "Already have an account? ",
        ),
        TextSpan(
          text: _isLogin ? "Register" : "Login",
          style: const TextStyle(
            color: Colors.white, 
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: neonPurple.withOpacity(0.7).let((c) => TextStyle(color: c)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: neonBlue, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: neonPink, width: 2.5),
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: const Color(0xFF111111),
        filled: true,
      ),
    );
  }
}

extension Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
