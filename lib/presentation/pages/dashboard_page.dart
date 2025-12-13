import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../../data/services/storage_service.dart';
import 'profile_page.dart';

class DashboardPage extends StatelessWidget {
  static const routeName = '/';
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final posts = context.watch<PostProvider>().posts;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushNamed(ProfilePage.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final nav = Navigator.of(context);
              await auth.signOut();
              nav.pushNamed('/login');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final p = posts[index];
          return ListTile(
            title: Text(p.content),
            subtitle: Text('Like: ${p.likeCount} • Komentar: ${p.commentCount}'),
            trailing: IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                if (auth.uid != null) {
                  context.read<PostProvider>().toggleLike(p.id, auth.uid!);
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final contentCtrl = TextEditingController();
          XFile? imageFile;
          await showDialog(
            context: context,
            builder: (ctx) {
              final nav = Navigator.of(ctx);
              final storage = ctx.read<StorageService>();
              final postProvider = ctx.read<PostProvider>();
              return AlertDialog(
              title: const Text('Posting Pesan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Isi')),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          imageFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                        },
                        child: const Text('Pilih Gambar'),
                      ),
                      const SizedBox(width: 8),
                      const Text('Opsional'),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => nav.pop(), child: const Text('Batal')),
                TextButton(
                  onPressed: () async {
                    String? imageUrl;
                    if (auth.uid != null && imageFile != null) {
                      final bytes = await imageFile!.readAsBytes();
                      imageUrl = await storage.uploadPostImage(auth.uid!, bytes, imageFile!.name);
                    }
                    if (auth.uid != null) {
                      await postProvider.create(auth.uid!, contentCtrl.text.trim(), imageUrl: imageUrl);
                    }
                    nav.pop();
                  },
                  child: const Text('Kirim'),
                ),
              ],
            );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
