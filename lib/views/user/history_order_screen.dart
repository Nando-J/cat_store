import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/order_model.dart';
import '../../services/database_service.dart';

class HistoryOrderScreen extends StatelessWidget {
  const HistoryOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Silakan login terlebih dahulu.')));
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kelola Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.hourglass_empty, size: 18), text: 'Menunggu'),
              Tab(icon: Icon(Icons.local_shipping, size: 18), text: 'Dikirim'),
              Tab(icon: Icon(Icons.check_circle_outline, size: 18), text: 'Selesai'),
              Tab(icon: Icon(Icons.cancel_outlined, size: 18), text: 'Batal'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          // Mengurangi opacity menjadi 0.1 agar background terlihat jelas
          child: Container(
            color: Colors.white.withOpacity(0.1),
            child: StreamBuilder<List<OrderModel>>(
              stream: dbService.getUserOrders(user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final userOrders = snapshot.data!;

                return TabBarView(
                  children: [
                    _buildUserOrderList(context, userOrders.where((o) => o.status == 'Pending').toList(), 'Pending', dbService),
                    _buildUserOrderList(context, userOrders.where((o) => o.status == 'Dikirim').toList(), 'Dikirim', dbService),
                    _buildUserOrderList(context, userOrders.where((o) => o.status == 'Selesai').toList(), 'Selesai', dbService),
                    _buildUserOrderList(context, userOrders.where((o) => o.status == 'Batal').toList(), 'Batal', dbService),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserOrderList(BuildContext context, List<OrderModel> orders, String statusTab, DatabaseService dbService) {
    if (orders.isEmpty) return Center(child: Text('Tidak ada pesanan $statusTab.', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)));

    Color statusColor = statusTab == 'Selesai' ? Colors.green : (statusTab == 'Batal' ? Colors.red : Colors.orange);

    return Column(
      children: [
        if (statusTab == 'Selesai' || statusTab == 'Batal')
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
              icon: const Icon(Icons.delete_sweep),
              label: Text('Hapus Semua $statusTab'),
              onPressed: () async {
                for (var o in orders) await dbService.deleteOrder(o.id);
              },
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final isWithinMinute = DateTime.now().difference(order.createdAt).inSeconds <= 60;

              return Card(
                elevation: 6,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
                            child: Text(statusTab, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('User: ${order.userEmail ?? "user@gmail.com"}'),
                      Text('Jumlah: ${order.quantity} pcs | Total: Rp ${order.totalPrice}'),
                      Row(
                        children: [
                          const Icon(Icons.payment, size: 16, color: Colors.orange),
                          Text(' Metode: ${order.paymentMethod}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.red),
                          Expanded(child: Text(' Alamat: ${order.address ?? "Lokasi tidak tersedia"}')),
                          
                          if (statusTab == 'Selesai' || statusTab == 'Batal')
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => dbService.deleteOrder(order.id),
                            ),
                          
                          if (statusTab == 'Pending' && isWithinMinute)
                            TextButton.icon(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              label: const Text('Batalkan', style: TextStyle(color: Colors.red)),
                              onPressed: () => dbService.updateOrderStatus(order.id, 'Batal'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}