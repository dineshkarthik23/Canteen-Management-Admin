class AuthService {
  static const String adminUsername = 'admin';
  static const String adminPassword = 'admin@123';

  bool authenticate({required String username, required String password}) {
    return username.trim() == adminUsername && password.trim() == adminPassword;
  }
}
