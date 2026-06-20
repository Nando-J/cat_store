import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna', style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50, 
                  backgroundColor: Colors.orange, 
                  child: Icon(Icons.person, size: 60, color: Colors.white)
                ),
                const SizedBox(height: 20),
                // Card tambahan untuk membungkus info agar lebih rapi di atas background
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text('Email Aktif:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(user?.email ?? 'Tidak Diketahui', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        Text('User ID: ${user?.uid}', style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, 
                    minimumSize: const Size(150, 45)
                  ),
                  onPressed: () async {
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context, 
                        MaterialPageRoute(builder: (context) => const LoginScreen()), 
                        (route) => false
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('KELUAR AKUN', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}