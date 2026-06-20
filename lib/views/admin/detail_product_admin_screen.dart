import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';

class DetailProductAdminScreen extends StatelessWidget {
  final ProductModel product;
  final Function(ProductModel) onEditRequested;

  const DetailProductAdminScreen({
    super.key,
    required this.product,
    required this.onEditRequested,
  });

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk', style: TextStyle(fontWeight: FontWeight.bold)),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Gambar Utama
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.white,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 80, color: Colors.grey))
                    : const Icon(Icons.pets, size: 80, color: Colors.orange),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card untuk detail agar lebih bersih di atas background
                    Card(
                      color: Colors.white.withOpacity(0.95),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text('Rp ${product.price}', style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Chip(
                              label: Text(product.category),
                              backgroundColor: Colors.orange.shade100,
                            ),
                            const Divider(height: 30),
                            const Text('Stok Tersedia', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${product.stock} pcs', style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 20),
                            const Text('Deskripsi Produk', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(product.description, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Tombol Aksi
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white, width: 2),
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            label: const Text('Edit Produk', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.pop(context);
                              onEditRequested(product);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            onPressed: () => _showDeleteConfirm(context, dbService),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, DatabaseService dbService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: const Text('Apakah Anda yakin ingin menghapus data produk ini secara permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await dbService.deleteProduct(product.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}