import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import '../user/main_user_wrapper.dart';   // Mengarah ke Wrapper Menu Bawah User
import '../admin/main_admin_wrapper.dart'; // Mengarah ke Wrapper Menu Bawah Admin

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    
    // 1. Proses Autentikasi Login via Firebase Auth
    var user = await _authService.loginWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (user != null) {
      // 2. Ambil data role secara dinamis dari Cloud Firestore berdasarkan UID pengguna
      String role = await _authService.getUserRole(user.uid);
      
      setState(() => _isLoading = false);

      // 3. Alur Navigasi berdasarkan role menuju Wrapper Utama masing-masing
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainAdminWrapper()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainUserWrapper()),
        );
      }
    } else {
      setState(() => _isLoading = false);
      // Jika login gagal, tampilkan pesan error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Gagal! Periksa kembali email & password.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // LAPISAN BACKGROUND UTAMA (PALING BELAKANG)
          // ==========================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // ==========================================
          // LAPISAN KONTEN FORM (MELAYANG DI ATASNYA)
          // ==========================================
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), // 👈 Membuat form tetap bersih dan terbaca jelas
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pets, size: 70, color: Colors.orange),
                    const SizedBox(height: 12),
                    const Text(
                      "CatStore",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email', 
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password', 
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.orange)
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _login,
                            child: const Text("MASUK", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                      },
                      child: const Text("Belum punya akun? Daftar di sini", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}