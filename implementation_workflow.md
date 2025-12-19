# Workflow Implementasi Fitur Suara Kampus

Dokumen ini memandu urutan pengerjaan fitur dari awal setelah konfigurasi Firebase (`flutterfire configure`). Kita akan mengerjakan dari fondasi (Backend/Logic) ke UI agar tidak bolak-balik.

## Urutan Pengerjaan Global
1.  **Auth Foundation** (Repository & Service) - *Pondasi*
2.  **Splash Screen** (Logic Cek Sesi) - *Pintu Masuk*
3.  **Register Page** (Buat User & Simpan ke Firestore)
4.  **Login Page**
5.  **Dashboard** (Menampilkan Post)
6.  **Profile** (Menampilkan & Edit Data User)

---

## Step 1: Auth Foundation (Logic Dulu)
Sebelum membuat UI Login/Splash, kita butuh logic untuk cek status login.

### 1. Buat `domain/entities/user_entity.dart`
```dart
class UserEntity {
  final String uid;
  final String email;
  final String displayName;
  
  UserEntity({required this.uid, required this.email, required this.displayName});
}
```

### 2. Buat `domain/repositories/auth_repository.dart`
```dart
abstract class AuthRepository {
  Future<UserEntity?> register(String email, String password, String name);
  Future<UserEntity?> login(String email, String password);
  Future<void> logout();
  UserEntity? getCurrentUser(); // Penting untuk Splash Screen
  Stream<UserEntity?> get onAuthStateChanged; // Opsional, untuk real-time auth check
}
```

### 3. Buat `data/services/auth_service_impl.dart`
Implementasikan logic Firebase Auth di sini.

```dart
class AuthService implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Butuh ini untuk simpan data user baru

  @override
  UserEntity? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserEntity(uid: user.uid, email: user.email!, displayName: user.displayName ?? '');
  }

  // Implementasi Register + Simpan data tambahan ke Firestore 'users' collection
  @override
  Future<UserEntity?> register(String email, String password, String name) async {
    // 1. Create Auth
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    // 2. Simpan ke Firestore (PENTING untuk fitur Profile!)
    await _firestore.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return UserEntity(uid: cred.user!.uid, email: email, displayName: name);
  }
}
```

### 4. Buat `presentation/providers/auth_provider.dart`
Jembatan untuk dipanggil UI.
```dart
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  bool isLoading = false;

  AuthProvider(this._repo);

  bool checkSession() {
    return _repo.getCurrentUser() != null;
  }
  
  // Fungsi login & register...
}
```

---

## Step 2: Splash Screen (Satpam Aplikasi)
Sekarang logic sudah siap, kita buat penentunya.

### 1. Buat UI `presentation/pages/splash_page.dart`
```dart
// Logic di initState
void checkLogin() async {
  // Delay sebentar untuk logo
  await Future.delayed(Duration(seconds: 2));
  
  // Cek Provider
  final isLoggedIn = context.read<AuthProvider>().checkSession();
  
  if (isLoggedIn) {
    Navigator.pushReplacementNamed(context, '/dashboard');
  } else {
    Navigator.pushReplacementNamed(context, '/login'); 
    // Atau ke '/register' jika ingin opsi lain
  }
}
```

---

## Step 3: Register Page
Kita buat Register dulu sebelum Login agar punya data user untuk dites.

### 1. Buat UI `presentation/pages/register_page.dart`
- Form: Nama, Email, Password.
- Button Register memanggil:
  ```dart
  await context.read<AuthProvider>().register(
     emailController.text, 
     passController.text, 
     nameController.text
  );
  // Jika sukses -> Navigasi ke Dashboard atau Login
  ```

---

## Step 4: Login Page
### 1. Buat UI `presentation/pages/login_page.dart`
- Form: Email, Password.
- Button Login memanggil:
  ```dart
  await context.read<AuthProvider>().login(emailController.text, passController.text);
  // Jika sukses -> ke Dashboard
  ```
- Tambah tombol text "Belum punya akun? Daftar" yang mengarah ke `/register`.

---

## Step 5: Dashboard & Posts
Inti aplikasi.

### Logic (Domain & Data)
1.  **Entity**: `PostEntity` (caption, imageUrl, authorName).
2.  **Repository**: `PostRepository` (fetchPosts, addPost).
3.  **Service**: `FirestoreService` (Read collection 'posts').

### UI
1.  **DashboardPage**: Gunakan `ListView.builder`.
2.  **PostProvider**: Ambil data dari Repository dan simpan di List `_posts`.
3.  **Add Post FloatingActionButton**:
    - Buka halaman baru / Dialog.
    - Upload Image ke Supabase (StorageService).
    - Simpan URL + Caption ke Firestore.

---

## Step 6: Profile Page
Menampilkan data diri user yang sedang login.

### Logic
1.  Ambil `uid` user yang sedang login (dari `AuthRepository`).
2.  Ambil data detail dari Firestore collection `users` berdasarkan `uid`.

### UI
1.  Tampilkan Foto, Nama, Email.
2.  Tombol **Logout** -> panggil `AuthProvider.logout()` -> Navigasi balik ke `LoginPage`.

---

## Checklist Urutan Pengerjaan
1.  [ ] **Auth Logic**: Entity, Repository Interface, Service Implementation, Provider.
2.  [ ] **Main & Routes**: Daftarkan Provider dan Routes di `main.dart`.
3.  [ ] **Splash Page**: UI & Logic Redirect.
4.  [ ] **Register Page**: UI & Logic ke Provider.
5.  [ ] **Login Page**: UI & Logic ke Provider.
6.  [ ] **Post Feature**: Repository, Service (Supabase+Firestore), Provider, UI Dashboard.
7.  [ ] **Profile Feature**: Get User Data, Logout.
