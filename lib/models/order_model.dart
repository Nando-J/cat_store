import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final String productName;
  final int totalPrice;
  final int quantity;
  final String status;
  final DateTime createdAt;
  final String address; 
  final String paymentMethod; 

  OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.productName,
    required this.totalPrice,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.address, 
    required this.paymentMethod, 
  });

  // Konversi dari DocumentSnapshot Firestore ke Model
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      productName: data['productName'] ?? '',
      totalPrice: data['totalPrice'] ?? 0,
      quantity: data['quantity'] ?? 0,
      status: data['status'] ?? 'Pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      address: data['address'] ?? 'Alamat tidak diisi', 
      paymentMethod: data['paymentMethod'] ?? 'Transfer Bank',
    );
  }

  // Konversi dari Model ke Map untuk disimpan di Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'productName': productName,
      'totalPrice': totalPrice,
      'quantity': quantity,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'address': address,
      'paymentMethod': paymentMethod,
    };
  }
}