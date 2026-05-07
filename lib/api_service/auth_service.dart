import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUsername = 'auth_username';
  static const String _keyPassword = 'auth_password';
  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyLoggedInUser = 'auth_logged_in_user';

  Future<String?> register(String username, String password, String confirmPassword) async {
    if (username.trim().isEmpty) return 'Username tidak boleh kosong.';
    if (password.isEmpty) return 'Password tidak boleh kosong.';
    if (password.length < 6) return 'Password minimal 6 karakter.';
    if (password != confirmPassword) return 'Konfirmasi password tidak cocok.';

    final prefs = await SharedPreferences.getInstance();
    final existingUser = prefs.getString(_keyUsername);
    if (existingUser != null && existingUser == username.trim()) {
      return 'Username sudah terdaftar. Silakan gunakan username lain.';
    }

    await prefs.setString(_keyUsername, username.trim());
    await prefs.setString(_keyPassword, password);
    return null;
  }

  Future<String?> login(String username, String password) async {
    if (username.trim().isEmpty) return 'Username tidak boleh kosong.';
    if (password.isEmpty) return 'Password tidak boleh kosong.';

    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString(_keyUsername);
    final savedPassword = prefs.getString(_keyPassword);

    if (savedUsername == null || savedPassword == null) {
      return 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
    }
    if (savedUsername != username.trim() || savedPassword != password) {
      return 'Username atau password salah.';
    }

    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyLoggedInUser, username.trim());
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyLoggedInUser);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedInUser);
  }
}
