# Panduan Pengembangan Aplikasi Suara Kampus

## 1. Penjelasan Code `storage_service.dart`

File `storage_service.dart` berfungsi sebagai penghubung (service) antara aplikasi Flutter Anda dengan layanan penyimpanan file (Storage) dari Supabase. Berikut adalah penjelasan detailnya:

### Import
```dart
import 'dart:typed_data'; // Untuk tipe data Uint8List (byte data gambar)
import 'package:supabase_flutter/supabase_flutter.dart'; // SDK Supabase
import '../../core/env.dart'; // Variabel lingkungan untuk konfigurasi (Bucket names)
```

### Class `StorageService`
Class ini membungkus semua logika upload agar rapi dan mudah digunakan ulang.

- **`_client`**: Mengambil instance global Supabase client yang sudah diinisialisasi di `main.dart`.
- **`uploadProfilePhoto`**:
    - Menerima `uid` (ID user), `bytes` (data gambar), dan `filename`.
    - Menyusun path penyimpanan: `$uid/$filename`.
    - Mengupload file ke bucket `Env.storageBucketProfile` menggunakan `upsert: true` (menimpa jika file sudah ada).
    - Setelah upload sukses, mengambil **Public URL** agar gambar bisa ditampilkan di aplikasi.
- **`uploadPostImage`**:
    - Mirip dengan profil, tapi mengupload ke bucket posts (`Env.storageBucketPost`).

## 2. Cara Membuat Aplikasi Ini dari Awal (Step-by-Step)

Berikut adalah langkah-langkah untuk membangun fondasi aplikasi seperti ini:

### Langkah 1: Persiapan Project Flutter
1.  Buka terminal.
2.  Jalankan perintah:
    ```bash
    flutter create suarakampus
    cd suarakampus
    ```
3.  Buka project di VS Code.

### Langkah 2: Tambahkan Dependencies
Buka file `pubspec.yaml` dan tambahkan package penting:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.7    # Untuk Database & Storage
  firebase_core: ^3.6.0       # Jika menggunakan Firebase
  provider: ^6.1.2            # State Management
  image_picker: ^1.1.2        # Mengambil gambar dari galeri/kamera
```
Jalankan `flutter pub get` di terminal.

### Langkah 3: Setup Backend (Supabase)
1.  Pergi ke [Supabase.com](https://supabase.com) dan buat project baru.
2.  Di dashboard Supabase, masuk ke menu **Storage**.
3.  Buat Bucket baru (misalnya: `kampushub-images`).
    - Pastikan bucket bersifat **Public** agar gambar bisa diakses via URL.
4.  Copy **URL** dan **Anon Key** dari menu Settings > API.

### Langkah 4: Setup Environment & Konfigurasi
Buat file `lib/core/env.dart` untuk menyimpan kunci rahasia agar tidak tersebar di semua file code.

```dart
class Env {
  static const suppabaseUrl = 'YOUR_SUPABASE_URL';
  static const suppabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const storageBucketProfile = 'kampushub-images';
}
```

### Langkah 5: Inisialisasi di Main
Edit `lib/main.dart` untuk menginisialisasi plugin sebelum aplikasi jalan.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Init Supabase
  await Supabase.initialize(
    url: Env.suppabaseUrl,
    anonKey: Env.suppabaseAnonKey,
  );

  runApp(const MyApp());
}
```

### Langkah 6: Buat Struktur Folder
Gunakan arsitektur yang rapi (misal: Clean Architecture atau MVVM sederhana):
- `lib/data/services/` (Tempat `storage_service.dart` dan service lain)
- `lib/presentation/pages/` (Halaman UI)
- `lib/presentation/providers/` (State Management)

### Langkah 7: Implementasi Fitur Upload (Contoh)
1.  **Service**: Buat `StorageService` seperti yang Anda miliki.
2.  **Provider**: Buat provider untuk memanggil service tersebut dan mengatur loading state.
    ```dart
    class ProfileProvider extends ChangeNotifier {
      final StorageService _storageService = StorageService();
      bool isLoading = false;

      Future<void> updatePhoto(String uid, XFile file) async {
        isLoading = true;
        notifyListeners();
        
        final bytes = await file.readAsBytes();
        final url = await _storageService.uploadProfilePhoto(uid, bytes, file.name);
        
        // Simpan URL ke database user profile Anda di sini
        
        isLoading = false;
        notifyListeners();
      }
    }
    ```
3.  **UI**: Gunakan `ImagePicker` di halaman profil untuk memilih foto, lalu panggil fungsi di Provider.

### Langkah 8: Jalankan Aplikasi
Tekan F5 atau jalankan `flutter run` untuk mengetes aplikasi di Emulator.
