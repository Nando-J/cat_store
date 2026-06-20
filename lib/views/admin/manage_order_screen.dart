import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/database_service.dart';

class ManageOrderScreen extends StatelessWidget {
  const ManageOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

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
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: StreamBuilder<List<OrderModel>>(
            stream: dbService.getAllOrders(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orange));
              final allOrders = snapshot.data!;

              final pendingOrders = allOrders.where((o) => o.status == 'Pending').toList();
              final shippingOrders = allOrders.where((o) => o.status == 'Dikirim').toList();
              final completedOrders = allOrders.where((o) => o.status == 'Selesai').toList();
              final canceledOrders = allOrders.where((o) => o.status == 'Batal').toList();

              return TabBarView(
                children: [
                  _buildOrderList(context, pendingOrders, dbService, currentStatus: 'Pending'),
                  _buildOrderList(context, shippingOrders, dbService, currentStatus: 'Dikirim'),
                  _buildOrderList(context, completedOrders, dbService, currentStatus: 'Selesai'),
                  _buildOrderList(context, canceledOrders, dbService, currentStatus: 'Batal'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<OrderModel> orders, DatabaseService dbService, {required String currentStatus}) {
    if (orders.isEmpty) {
      return const Center(child: Text('Tidak ada data pesanan.', style: TextStyle(color: Colors.white)));
    }

    return Column(
      children: [
        if (currentStatus == 'Selesai' || currentStatus == 'Batal')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.redAccent),
                  icon: const Icon(Icons.delete_sweep),
                  label: Text('Hapus Semua $currentStatus', style: const TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    bool? confirmAll = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Hapus Semua Riwayat $currentStatus?'),
                        content: Text('Apakah Anda yakin ingin menghapus semua pesanan berstatus $currentStatus secara permanen?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Hapus Semua', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );

                    if (confirmAll == true) {
                      for (var order in orders) { await dbService.deleteOrder(order.id); }
                    }
                  },
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 4, // Sama dengan product card
                color: Colors.white, // Solid putih agar tidak transparan
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.orange, width: 0.5),
                ),
                child: ListTile(
                  title: Text(order.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User: ${order.userEmail}\nJumlah: ${order.quantity} pcs | Total: Rp ${order.totalPrice}'),
                      Text('Metode: ${order.paymentMethod}\nStatus: ${order.status}'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.red),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('Alamat: ${order.address}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (currentStatus == 'Pending')
                        TextButton(
                          onPressed: () => dbService.updateOrderStatus(order.id, 'Dikirim'),
                          child: const Text('PROSES', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        )
                      else if (currentStatus == 'Dikirim') ...[
                        TextButton(
                          onPressed: () => dbService.updateOrderStatus(order.id, 'Batal'),
                          child: const Text('BATAL', style: TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () => dbService.updateOrderStatus(order.id, 'Selesai'),
                          child: const Text('SELESAI', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: currentStatus == 'Selesai' ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(order.status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => dbService.deleteOrder(order.id),
                        ),
                      ],
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