import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/user_profile.dart';
import '../../data/services/storage_service.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
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
    final uid = auth.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: uid == null
          ? const Center(child: Text('Belum login'))
          : FutureBuilder(
              future: context.read<ProfileProvider>().load(uid),
              builder: (context, snap) {
                final p = context.watch<ProfileProvider>().profile;
                if (p != null) {
                  _name.text = p.displayName;
                  _bio.text = p.bio ?? '';
                }
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama')),
                      TextField(controller: _bio, decoration: const InputDecoration(labelText: 'Bio')),
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
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          final profileProvider = context.read<ProfileProvider>();
                          String? photoUrl = p?.photoUrl;
                          if (_photoBytes != null && _photoName != null) {
                            photoUrl = await storage.uploadProfilePhoto(uid, _photoBytes!, _photoName!);
                          }
                          final now = DateTime.now();
                          final updated = UserProfile(
                            uid: uid,
                            email: p?.email ?? '',
                            displayName: _name.text.trim(),
                            photoUrl: photoUrl,
                            bio: _bio.text.trim(),
                            createdAt: p?.createdAt ?? now,
                            updatedAt: now,
                          );
                          await profileProvider.update(updated);
                          nav.pop();
                        },
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
