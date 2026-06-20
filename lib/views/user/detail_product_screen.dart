import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';

class DetailProductScreen extends StatefulWidget {
  final ProductModel product;
  const DetailProductScreen({super.key, required this.product});

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  int _quantity = 1;
  final TextEditingController _alamatCtrl = TextEditingController();
  final List<String> _paymentMethods = ['Transfer Bank', 'E-Wallet (OVO/Dana)', 'COD'];
  String _selectedPayment = 'Transfer Bank';

  @override
  void dispose() {
    _alamatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background tetap tajam
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),
          // Overlay tipis (opacity 0.1)
          Positioned.fill(child: Container(color: Colors.white.withOpacity(0.1))),

          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Produk
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: widget.product.imageUrl.isNotEmpty
                        ? Image.network(widget.product.imageUrl, fit: BoxFit.cover)
                        : const Icon(Icons.pets, size: 100, color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 20),

                // Card Info Produk
                Card(
                  elevation: 6,
                  color: Colors.white.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.orange.shade200, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Kategori: ${widget.product.category}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 10),
                        Text('Rp ${widget.product.price}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                        const Divider(height: 30),
                        const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(widget.product.description),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Pengatur Jumlah
                if (widget.product.stock > 0)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('Jumlah: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove, color: Colors.orange)),
                        Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(onPressed: _quantity < widget.product.stock ? () => setState(() => _quantity++) : null, icon: const Icon(Icons.add, color: Colors.orange)),
                        const Spacer(),
                        Text('Total: Rp ${widget.product.price * _quantity}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Tombol Beli
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size.fromHeight(55)),
                  onPressed: widget.product.stock < 1 ? null : () => _showCheckoutBottomSheet(context),
                  child: Text(widget.product.stock < 1 ? 'Stok Habis' : 'BELI SEKARANG', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Konfirmasi Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: _alamatCtrl, decoration: const InputDecoration(labelText: 'Alamat Pengiriman', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedPayment,
              decoration: const InputDecoration(
                labelText: 'Metode Pembayaran',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment, color: Colors.orange),
              ),
              items: _paymentMethods.map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedPayment = val!);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size.fromHeight(50)),
              onPressed: () async {
                final currentUser = _authService.currentUser;
                if (currentUser == null) return;
                
                final order = OrderModel(
                  id: '', userId: currentUser.uid, userEmail: currentUser.email ?? '',
                  productName: widget.product.name, totalPrice: (widget.product.price * _quantity).toInt(),
                  quantity: _quantity, status: 'Pending', createdAt: DateTime.now(), address: _alamatCtrl.text.trim(),
                  paymentMethod: _selectedPayment,
                );

                await _dbService.createOrder(order);
                if (mounted) Navigator.pop(context);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('KONFIRMASI', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}