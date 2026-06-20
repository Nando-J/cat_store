import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // MANAJEMEN PRODUK (USER & ADMIN)
  // ==========================================

  /// Stream untuk mengambil data produk (Bisa difilter berdasarkan kategori)
  Stream<List<ProductModel>> getProducts({String category = 'Semua'}) {
    if (category == 'Semua') {
      return _db.collection('products').snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
    } else {
      return _db
          .collection('products')
          .where('category', isEqualTo: category)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList());
    }
  }

  /// Tambah Produk Baru (Admin)
  Future<void> addProduct(ProductModel product) async {
    try {
      await _db.collection('products').add(product.toFirestore());
    } catch (e) {
      print("Gagal menambah produk: $e");
      rethrow;
    }
  }

  /// Update Data Produk (Admin)
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _db
          .collection('products')
          .doc(product.id)
          .update(product.toFirestore());
    } catch (e) {
      print("Gagal mengupdate produk: $e");
      rethrow;
    }
  }

  /// Hapus Produk (Admin)
  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection('products').doc(productId).delete();
    } catch (e) {
      print("Gagal menghapus produk: $e");
      rethrow;
    }
  }

  // ==========================================
  // MANAJEMEN TRANSAKSI / BOOKING
  // ==========================================

  /// Membuat Pesanan Baru (User)
  Future<void> createOrder(OrderModel order) async {
    try {
      // 1. Simpan data pesanan ke Firestore
      await _db.collection('orders').add(order.toFirestore());
    } catch (e) {
      print("Gagal membuat pesanan: $e");
      rethrow;
    }
  }

  /// Stream Riwayat Pesanan Spesifik Per User (User)
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
  }

  /// Stream Semua Pesanan Masuk (Admin)
  Stream<List<OrderModel>> getAllOrders() {
    return _db
        .collection('orders')
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt)); 
          return docs;
        });
  }

  /// UPDATE STATUS PESANAN DAN MANAJEMEN STOK (DIREVISI SESUAI ALUR BARU)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      DocumentReference orderRef = _db.collection('orders').doc(orderId);

      await _db.runTransaction((transaction) async {
        DocumentSnapshot orderSnapshot = await transaction.get(orderRef);
        if (!orderSnapshot.exists) return;

        String currentStatus = orderSnapshot.get('status') ?? 'Pending';
        String productName = orderSnapshot.get('productName') ?? '';
        int quantityToBuy = orderSnapshot.get('quantity') ?? 0;

        // 1. JIKA DIAKTIFKAN 'PROSES' (Pending -> Dikirim): Potong Stok Produk
        if (newStatus == 'Dikirim' && currentStatus == 'Pending') {
          QuerySnapshot productQuery = await _db
              .collection('products')
              .where('name', isEqualTo: productName)
              .limit(1)
              .get();

          if (productQuery.docs.isNotEmpty) {
            DocumentReference productRef = productQuery.docs.first.reference;
            int currentStock = productQuery.docs.first.get('stock') ?? 0;

            if (currentStock >= quantityToBuy) {
              int newStock = currentStock - quantityToBuy;
              transaction.update(productRef, {'stock': newStock});
            } else {
              throw Exception('Stok tidak mencukupi!');
            }
          }
        }

        // 2. JIKA PESANAN DIBATALKAN (Dikirim -> Batal): Kembalikan stok yang sempat dipotong
        if (newStatus == 'Batal' && currentStatus == 'Dikirim') {
          QuerySnapshot productQuery = await _db
              .collection('products')
              .where('name', isEqualTo: productName)
              .limit(1)
              .get();

          if (productQuery.docs.isNotEmpty) {
            DocumentReference productRef = productQuery.docs.first.reference;
            int currentStock = productQuery.docs.first.get('stock') ?? 0;
            
            transaction.update(productRef, {'stock': currentStock + quantityToBuy});
          }
        }

        // Jalankan update status dokumen order utama
        transaction.update(orderRef, {'status': newStatus});
      });
    } catch (e) {
      print("Gagal memperbarui status dan stok: $e");
      rethrow;
    }
  }

  /// Hapus Dokumen Pesanan Permanen (Admin & User)
  Future<void> deleteOrder(String orderId) async {
    try {
      await _db.collection('orders').doc(orderId).delete();
    } catch (e) {
      print("Gagal menghapus data pesanan: $e");
      rethrow;
    }
  }
}