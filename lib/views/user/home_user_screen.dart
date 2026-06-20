import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import 'detail_product_screen.dart';

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({super.key});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  final DatabaseService _dbService = DatabaseService();
  String _currentCategory = 'Semua';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CatStore Nando', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),
          
          // Overlay tipis agar teks tetap terbaca (opacity 0.1 agar hampir tidak terlihat buram)
          Positioned.fill(child: Container(color: Colors.white.withOpacity(0.1))),
          
          Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase().trim()),
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search, color: Colors.orange),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),

              // Filter Kategori
              Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['Semua', 'Makanan', 'Minuman', 'Aksesori', 'Peralatan'].map((category) {
                    final isSelected = _currentCategory == category;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: Colors.orange,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                        onSelected: (val) => setState(() => _currentCategory = category),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Produk Grid
              Expanded(
                child: StreamBuilder<List<ProductModel>>(
                  stream: _dbService.getProducts(category: _currentCategory),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orange));
                    
                    final products = snapshot.data!.where((prod) => prod.name.toLowerCase().contains(_searchQuery)).toList();

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, 
                        childAspectRatio: 0.75, 
                        crossAxisSpacing: 12, 
                        mainAxisSpacing: 12
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final prod = products[index];
                        return InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailProductScreen(product: prod))),
                          child: Card(
                            elevation: 6,
                            shadowColor: Colors.black45,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.orange.shade200, width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                    child: prod.imageUrl.isNotEmpty
                                        ? Image.network(prod.imageUrl, width: double.infinity, fit: BoxFit.cover)
                                        : const Center(child: Icon(Icons.pets, size: 50, color: Colors.orange)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text('Rp ${prod.price}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}