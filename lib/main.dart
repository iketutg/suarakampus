import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suarakampus/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env.dart';
import 'data/services/auth_service.dart';
import 'data/services/firestore_service.dart';
import 'data/services/storage_service.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/post_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/post_provider.dart';
import 'presentation/providers/profile_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(url: Env.suppabaseUrl, anonKey: Env.suppabaseAnonKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepo = AuthService();
    final UserRepository userRepo = FirestoreService();
    final PostRepository postRepo = FirestoreService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(userRepo)),
        ChangeNotifierProvider(create: (_) => PostProvider(postRepo)),
        Provider<StorageService>(create: (_) => StorageService()),
      ],
      child: MaterialApp(
        title: 'Suara Kampus',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF4C6EF5),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Color(0xFFF7F9FC),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0.5,
            centerTitle: true,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        initialRoute: SplashPage.routeName,
        routes: {
          SplashPage.routeName: (_) => const SplashPage(),
          LoginPage.routeName: (_) => const LoginPage(),
          RegisterPage.routeName: (_) => const RegisterPage(),
          ProfilePage.routeName: (_) => const ProfilePage(),
          DashboardPage.routeName: (_) => const DashboardPage(),
        },
      ),
    );
  }
}
