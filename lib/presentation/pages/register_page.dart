import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/user_profile.dart';
import '../../data/services/storage_service.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import 'dashboard_page.dart';

class RegisterPage extends StatefulWidget {
  static const routeName = '/register';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();
  final _nim = TextEditingController();
  final _major = TextEditingController();
  final _batch = TextEditingController();
  Uint8List? _photoBytes;
  String? _photoName;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _photoName = file.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final storage = context.read<StorageService>();
    final profileProvider = context.read<ProfileProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            TextField(controller: _fullName, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
            TextField(controller: _nim, decoration: const InputDecoration(labelText: 'NIM')),
            TextField(controller: _major, decoration: const InputDecoration(labelText: 'Jurusan')),
            TextField(controller: _batch, decoration: const InputDecoration(labelText: 'Angkatan')),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(onPressed: _pickPhoto, child: const Text('Pilih Foto')),
                const SizedBox(width: 8),
                if (_photoBytes != null) const Text('Foto dipilih'),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: auth.loading
                  ? null
                  : () async {
                  final nav = Navigator.of(context);
                  await auth.signUp(_email.text.trim(), _password.text);
                  if (auth.uid != null) {
                    String? photoUrl;
                    if (_photoBytes != null && _photoName != null) {
                      photoUrl = await storage.uploadProfilePhoto(auth.uid!, _photoBytes!, _photoName!);
                    }
                    final now = DateTime.now();
                    final profile = UserProfile(
                      uid: auth.uid!,
                      email: _email.text.trim(),
                      fullName: _fullName.text.trim(),
                      nim: _nim.text.trim().isNotEmpty ? _nim.text.trim() : null,
                      photoUrl: photoUrl,
                      bio: null,
                      major: _major.text.trim().isNotEmpty ? _major.text.trim() : null,
                      batch: _batch.text.trim().isNotEmpty ? _batch.text.trim() : null,
                      fcmToken: null,
                      createdAt: now,
                      updatedAt: now,
                    );
                    await profileProvider.update(profile);
                    nav.pushReplacementNamed(DashboardPage.routeName);
                  }
                },
              child: const Text('Daftar'),
            ),
            if (auth.error != null) Text(auth.error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
