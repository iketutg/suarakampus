# Panduan Pengembangan Suara Kampus dengan Clean Architecture

Dokumen ini adalah panduan langkah demi langkah untuk membangun aplikasi Suara Kampus dari nol menggunakan prinsip **clean architecture**.

## 1. Persiapan Project & Konfigurasi

### 1.1 Create Project
Buat project flutter baru:
```bash
flutter create suarakampus
cd suarakampus
```

### 1.2 Konfigurasi Firebase
Pastikan Anda sudah memiliki project di Firebase Console.
Jalankan perintah ini di terminal root project untuk mengonfigurasi aplikasi dengan Firebase:
```bash
flutterfire configure
```
*Pilih platform yang ingin didukung (Android, iOS) dan ikuti instruksi di layar. File `firebase_options.dart` akan otomatis dibuat di `lib/`.*

### 1.3 Struktur Folder (Clean Architecture)
Kita akan membagi kode berdasarkan **Layers** (Lapisan) untuk memisahkan tanggung jawab. Hapus semua isi `lib/` dan buat struktur berikut:

```text
lib/
├── core/                   # Kode inti yang shared (Config, Constants, Utils)
│   ├── env.dart            # Environment variables (API Keys)
│   └── constants.dart      # Warna, gaya text
├── data/                   # LOGIC & DATA (Implementasi)
│   ├── models/             # Representasi data dari API/DB (fromJson/toJson)
│   ├── services/           # External Data Source (Firebase, Supabase API calls)
│   └── repositories/       # Implementasi repository (Jembatan Data -> Domain)
├── domain/                 # BISNIS LOGIC (Abstraksi Murni)
│   ├── entities/           # Class object murni yang dipakai di UI
│   └── repositories/       # Interface (Kontrak) repository
├── presentation/           # UI & STATE MANAGEMENT
│   ├── pages/              # Screen/Halaman
│   ├── widgets/            # Komponen kecil reusable
│   └── providers/          # State Management (ChangeNotifier)
└── main.dart               # Entry point
```

---

## 2. Penjelasan Layer (Konsep)

1.  **Domain Layer (Jantung Aplikasi)**:
    *   **Entities**: Object Dart murni. Contoh: `UserEntity` yang punya nama, email, foto. Tidak boleh ada code Firebase/Json parsing di sini.
    *   **Repositories (Interface)**: Kontrak abstrak. Contoh: "Harus ada fungsi login", tapi tidak peduli *bagaimana* caranya (pakai Firebase atau API lain).

2.  **Data Layer (Otak Teknis)**:
    *   **Services**: Code yang kotor dan teknis. Langsung ngobrol sama Firebase/Supabase.
    *   **Models**: Turunan dari Entity, tapi punya kemampuan transformasi data (JSON serializing).
    *   **Repositories (Impl)**: Implementasi kontrak dari Domain. Di sini kita panggil Service lalu ubah Model jadi Entity.

3.  **Presentation Layer (Wajah)**:
    *   **Pages/Widgets**: Tampilan.
    *   **Providers**: Lem yang menyambungkan UI dengan Domain. UI minta data ke Provider -> Provider minta ke Repository -> Repository ambil dari Service.

---

## 3. Implementasi: Fondasi

### 3.1 `lib/main.dart`
Setup awal dan Dependency Injection (menyiapkan service agar bisa dipakai).

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Init Firebase & Supabase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(url: Env.url, anonKey: Env.key);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 2. Dependency Injection (Manual)
    // Buat service dulu
    final authService = AuthService(); // Data Layer
    final firestoreService = FirestoreService(); // Data Layer
    
    // Inject ke Provider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(firestoreService)),
        // ... provider lain
      ],
      child: MaterialApp(
        title: 'Suara Kampus',
        home: SplashPage(),
        routes: { ... }, // Definisikan rute
      ),
    );
  }
}
```

### 3.2 Splash Screen (`presentation/pages/splash_page.dart`)
Halaman pengecekan sesi login.

```dart
class SplashPage extends StatefulWidget { ... }

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    // Tunggu sebentar untuk animasi
    await Future.delayed(Duration(seconds: 2));
    
    // Cek apakah user sedang login via Provider/Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  // Build UI dengan Logo di tengah...
}
```

---

## 4. Implementasi: Fitur Auth (Register & Login)

### 4.1 Domain Layer
**Entity (`domain/entities/user_entity.dart`)**:
```dart
class UserEntity {
  final String uid;
  final String email;
  final String displayName;
  // Constructor...
}
```

**Repository Interface (`domain/repositories/auth_repository.dart`)**:
```dart
abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password);
  Future<void> logout();
}
```

### 4.2 Data Layer
**Service (`data/services/auth_service.dart`)**:
Mengimplementasikan `AuthRepository`.
```dart
class AuthService implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<UserEntity> login(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email, password: password
    );
    // Convert FirebaseUser ke UserEntity
    return UserEntity(
      uid: credential.user!.uid, 
      email: credential.user!.email!,
      // ...
    );
  }
  // Implement register & logout...
}
```

### 4.3 Presentation Layer
**Provider (`presentation/providers/auth_provider.dart`)**:
```dart
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo; // Bergantung pada Interface, bukan implementasi langsung!
  
  AuthProvider(this._repo);

  bool isLoading = false;
  UserEntity? _currentUser;

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _repo.login(email, password);
    } catch (e) {
      // Handle error
    }
    isLoading = false;
    notifyListeners();
  }
}
```

**UI (`presentation/pages/login_page.dart`)**:
```dart
// Di dalam tombol login
ElevatedButton(
  onPressed: () {
    context.read<AuthProvider>().login(emailController.text, passController.text);
  },
  child: Text("Login"),
)
```

---

## 5. Implementasi: Profile & Post

### 5.1 Profile Provider
Mirip dengan Auth, tapi fokus ke data User (Firestore).

1.  **Repository**: `UserRepository` punya fungsi `getUserProfile(uid)` dan `updateProfile(uid, data)`.
2.  **Service**: `FirestoreService` implementasi baca/tulis ke collection `users`.
3.  **Provider**: `ProfileProvider` memanggil `getUserProfile` saat halaman profile dimuat.

### 5.2 Add Post (Fitur Baru)
Flow lengkap untuk menambah postingan:

1.  **Entity**: `PostEntity` (id, caption, imageUrl, userId).
2.  **Repository**: `PostRepository` -> `createPost(PostEntity post, File image)`.
3.  **Service**:
    *   Upload gambar ke **Supabase Storage** dapatkan *Public URL*.
    *   Simpan data post + URL gambar ke **Firestore**.
4.  **Provider**: `PostProvider` -> fungsi `uploadPost`.
5.  **UI**: Halaman dengan `TextField` (caption) dan tombol untuk pick image (`image_picker`). Saat submit dipencet, panggil `PostProvider.uploadPost`.

---

## Ringkasan Alur Kerja
Setiap kali Anda membuat fitur baru (misal: "Komentar"), ikuti urutan ini:
1.  **Definisikan Data (Domain)**: Buat `CommentEntity`.
2.  **Tentukan Kontrak (Domain)**: Buat `CommentRepository` (addComment, deleteComment).
3.  **Implementasi Teknis (Data)**: Buat `CommentService`, tulis logic ke Firestore.
4.  **State Management (Presentation)**: Buat `CommentProvider` untuk handle loading & data list.
5.  **Tampilan (UI)**: Buat Widget List Komentar & Input.
