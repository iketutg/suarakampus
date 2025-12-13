import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Masuk')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: auth.loading
                  ? null
                  : () async {
                      final nav = Navigator.of(context);
                      await auth.signIn(_email.text.trim(), _password.text);
                      if (auth.uid != null) {
                        nav.pushReplacementNamed(DashboardPage.routeName);
                      }
                    },
              child: const Text('Masuk'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(RegisterPage.routeName);
              },
              child: const Text('Belum punya akun? Daftar'),
            ),
            if (auth.error != null) Text(auth.error!, style: const TextStyle(color: Colors.red)),
          ],
          ),
        ),
      ),
    );
  }
}
