import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardAdminScreen extends StatelessWidget {
  final VoidCallback onTotalProductTap;
  final VoidCallback onLowStockTap;

  const DashboardAdminScreen({
    super.key,
    required this.onTotalProductTap,
    required this.onLowStockTap,
  });

  Stream<int> _getCount(String collectionPath) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _getNewOrdersCount() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _getLowStockCount() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('stock', isLessThanOrEqualTo: 5)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<Map<String, int>> _getSalesStats() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'Selesai')
        .snapshots()
        .map((snapshot) {
      int totalEarnings = 0;
      int totalItemsSold = 0;
      for (var doc in snapshot.docs) {
        totalEarnings += (doc.data()['totalPrice'] as int? ?? 0);
        totalItemsSold += (doc.data()['quantity'] as int? ?? 0);
      }
      return {'earnings': totalEarnings, 'itemsSold': totalItemsSold};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Baris 1
                Row(
                  children: [
                    Expanded(child: StreamBuilder<int>(
                      stream: _getCount('products'),
                      builder: (context, snapshot) => GestureDetector(
                        onTap: onTotalProductTap,
                        child: _buildStatCard('Total Produk', '${snapshot.data ?? 0}', Icons.inventory, Colors.blue),
                      ),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: StreamBuilder<int>(
                      stream: _getNewOrdersCount(),
                      builder: (context, snapshot) => _buildStatCard('Pesanan Baru', '${snapshot.data ?? 0}', Icons.notification_important, Colors.orange),
                    )),
                  ],
                ),
                const SizedBox(height: 12),

                // Baris 2
                StreamBuilder<Map<String, int>>(
                  stream: _getSalesStats(),
                  builder: (context, snapshot) {
                    final stats = snapshot.data ?? {'earnings': 0, 'itemsSold': 0};
                    return Row(
                      children: [
                        Expanded(child: _buildStatCard('Terjual', '${stats['itemsSold']} pcs', Icons.assignment_turned_in, Colors.teal)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Omset', 'Rp ${stats['earnings']}', Icons.monetization_on, Colors.green)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Baris 3
                StreamBuilder<int>(
                  stream: _getLowStockCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return GestureDetector(
                      onTap: onLowStockTap,
                      child: _buildStatCard('Stok Menipis (<= 5)', '$count', Icons.warning_amber_rounded, count > 0 ? Colors.red : Colors.grey),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}