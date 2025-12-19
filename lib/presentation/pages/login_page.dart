import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'dashboard_page.dart';
import 'register_page.dart';

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
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: 260,
              width: double.infinity,
              child: ClipPath(
                clipper: _WaveClipper(),
                child: Container(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE8F5E9),
                          image: DecorationImage(
                            image: AssetImage('assets/images/orasi.png'),
                            fit: BoxFit.contain, // atau cover sesuai kebutuhan
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 200, 16, 16),
                child: Card(
                  elevation: 1,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Masuk', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _password,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),
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
                        if (auth.error != null) ...[
                          const SizedBox(height: 8),
                          Text(auth.error!, style: const TextStyle(color: Colors.red)),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            const SizedBox(width: 8),
                            Text('atau', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(width: 8),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _SocialButton(
                              label: 'Google',
                              color: Colors.white,
                              textColor: Colors.black87,
                              borderColor: Colors.grey.shade300,
                              leading: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: Text(
                                  'G',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onTap: () {},
                            ),
                            _SocialButton(
                              label: 'Facebook',
                              color: const Color(0xFF1877F2),
                              textColor: Colors.white,
                              borderColor: const Color(0xFF1877F2),
                              leading: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: Text(
                                  'f',
                                  style: TextStyle(
                                    color: Color(0xFF1877F2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamed(RegisterPage.routeName),
                          child: const Text('Belum punya akun? Daftar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height - 40);
    path.quadraticBezierTo(size.width * 0.75, size.height - 80, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final Widget leading;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.borderColor,
    required this.leading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leading,
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
