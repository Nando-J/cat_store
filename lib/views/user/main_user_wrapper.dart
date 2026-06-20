import 'package:flutter/material.dart';
import 'home_user_screen.dart';
import 'all_products_screen.dart'; // Halaman katalog produk penuh
import 'history_order_screen.dart'; // Halaman booking / riwayat pesanan
import 'profile_screen.dart';

class MainUserWrapper extends StatefulWidget {
  const MainUserWrapper({super.key});

  @override
  State<MainUserWrapper> createState() => _MainUserWrapperState();
}

class _MainUserWrapperState extends State<MainUserWrapper> {
  int _currentIndex = 0;

  // List 4 Halaman Utama User
  final List<Widget> _pages = [
    const HomeUserScreen(),
    const AllProductsScreen(), // Menu Product
    const HistoryOrderScreen(), // Menu Booking
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Product'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}