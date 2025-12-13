import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/comment.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../../data/services/storage_service.dart';
import 'profile_page.dart';
import '../providers/profile_provider.dart';
import '../../domain/entities/user_profile.dart';

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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserName(userId: p.userId),
                const SizedBox(height: 4),
                Text(p.content),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.photoUrl != null) Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.network(p.photoUrl!, height: 120, fit: BoxFit.cover),
                ),
                Row(
                  children: [
                    FutureBuilder<int>(
                      future: context.read<PostProvider>().likeCountFor(p.id),
                      builder: (ctx, snap) => Text('Like: ${snap.data ?? 0}'),
                    ),
                    const SizedBox(width: 12),
                    FutureBuilder<int>(
                      future: context.read<PostProvider>().commentCountFor(p.id),
                      builder: (ctx, snap) => Text('Komentar: ${snap.data ?? 0}'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        _showCommentsSheet(context, p.id);
                      },
                      child: const Text('Lihat komentar'),
                    ),
                  ],
                ),
              ],
            ),
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

class _UserName extends StatelessWidget {
  final String userId;
  const _UserName({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: context.read<ProfileProvider>().getById(userId),
      builder: (ctx, snap) {
        final name = snap.data?.fullName ?? 'Mahasiswa';
        return Text(name, style: const TextStyle(fontWeight: FontWeight.bold));
      },
    );
  }
}

void _showCommentsSheet(BuildContext context, String postId) {
  final auth = context.read<AuthProvider>();
  final postProvider = context.read<PostProvider>();
  final commentCtrl = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.6,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Komentar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: StreamBuilder<List<Comment>>(
                  stream: postProvider.commentsFor(postId),
                  builder: (ctx, snap) {
                    final comments = snap.data ?? [];
                    if (comments.isEmpty) {
                      return const Center(child: Text('Belum ada komentar'));
                    }
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (ctx, i) {
                        final c = comments[i];
                        return ListTile(
                          title: Row(
                            children: [
                              Expanded(child: _UserName(userId: c.userId)),
                              Text(
                                c.createdAt.toLocal().toString(),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          subtitle: Text(c.content),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Tulis komentar...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (auth.uid != null && commentCtrl.text.trim().isNotEmpty) {
                          await postProvider.addComment(postId, auth.uid!, commentCtrl.text.trim());
                          commentCtrl.clear();
                        }
                      },
                      child: const Text('Kirim'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
