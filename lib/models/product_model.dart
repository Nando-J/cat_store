import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String category;
  final int price;
  final String description;
  final int stock;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.stock,
    required this.imageUrl,
  });

  // Konversi dari DocumentSnapshot Firestore ke Model (FIXED)
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: data['price'] ?? 0,
      description: data['description'] ?? '',
      stock: data['stock'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Konversi dari Model ke Map untuk disimpan di Firestore (FIXED)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }
}