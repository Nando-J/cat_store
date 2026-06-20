import 'package:flutter/material.dart';
import 'dashboard_admin_screen.dart'; // Tab 1: Home (Ringkasan info)
import 'crud_product_screen.dart';    // Tab 2: Product (CRUD Produk)
import 'manage_order_screen.dart';   // Tab 3: Booking (Pesanan Masuk)
import '../user/profile_screen.dart';  // Tab 4: Profile

class MainAdminWrapper extends StatefulWidget {
  const MainAdminWrapper({super.key});

  @override
  State<MainAdminWrapper> createState() => _MainAdminWrapperState();
}

class _MainAdminWrapperState extends State<MainAdminWrapper> {
  int _currentIndex = 0;
  String _initialProductFilter = 'Semua'; 

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardAdminScreen(
        onTotalProductTap: () {
          setState(() {
            _initialProductFilter = 'Semua';
            _currentIndex = 1; 
          });
        },
        onLowStockTap: () {
          setState(() {
            _initialProductFilter = 'Stok Menipis';
            _currentIndex = 1; 
          });
        },
      ), 
      CrudProductScreen(initialFilter: _initialProductFilter),    
      const ManageOrderScreen(),   
      const ProfileScreen(),        
    ];

    return Scaffold(
      extendBody: true, // 👈 WAJIB: Agar konten halaman anak memanjang hingga ke dasar layar
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92), // Transparansi tipis agar background bawah sedikit mengintip
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.15), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              if (index == 1) _initialProductFilter = 'Semua'; 
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // 👈 Ubah ke transparan agar menyatu
          elevation: 0,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Product'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Booking'),
            BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}