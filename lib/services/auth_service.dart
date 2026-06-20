import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // 1. Ambil Role secara dinamis dari Firestore berdasarkan UID
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['role'] ?? 'user'; // Jika field role kosong, default ke 'user'
      }
    } catch (e) {
      print("Error mengambil role: $e");
    }
    return 'user'; // Default jika terjadi error atau data tidak ditemukan
  }

  // Logika Register (Akun baru otomatis menjadi 'user')
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Semua yang registrasi dari aplikasi otomatis bertindak sebagai 'user' biasa
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'role': 'user', 
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      print("Error Register: ${e.toString()}");
      return null;
    }
  }

  // Logika Login
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Error Login: ${e.toString()}");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}