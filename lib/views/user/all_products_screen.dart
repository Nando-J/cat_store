import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import 'detail_product_screen.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Produk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background yang selaras
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),
          // Overlay tipis (opacity 0.1) agar background tetap terlihat jelas
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),
          
          StreamBuilder<List<ProductModel>>(
            stream: dbService.getProducts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }
              final products = snapshot.data!;
              if (products.isEmpty) {
                return const Center(child: Text('Belum ada produk tersedia.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final prod = products[index];
                  return Card(
                    elevation: 6, // Elevasi ditingkatkan agar card terlihat menonjol
                    shadowColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.orange.shade200, width: 1.5), // Border tegas
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: prod.imageUrl.isNotEmpty
                            ? Image.network(
                                prod.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: Colors.orange.shade50,
                                child: const Icon(Icons.pets, color: Colors.orange),
                              ),
                      ),
                      title: Text(
                        prod.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Rp ${prod.price}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          Text('Stok: ${prod.stock}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange.shade400),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailProductScreen(product: prod)),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}