import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import 'detail_product_admin_screen.dart';

class CrudProductScreen extends StatefulWidget {
  final String initialFilter;
  const CrudProductScreen({super.key, this.initialFilter = 'Semua'});

  @override
  State<CrudProductScreen> createState() => _CrudProductScreenState();
}

class _CrudProductScreenState extends State<CrudProductScreen> {
  final DatabaseService _dbService = DatabaseService();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageController = TextEditingController();
  
  String _selectedCategory = 'Makanan'; 
  String _searchQuery = '';
  late String _activeFilterCategory; 
  
  final List<String> _categories = ['Semua', 'Stok Menipis', 'Makanan', 'Minuman', 'Aksesori', 'Peralatan'];

  @override
  void initState() {
    super.initState();
    _activeFilterCategory = widget.initialFilter;
  }

  @override
  void didUpdateWidget(covariant CrudProductScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilter != widget.initialFilter) {
      setState(() {
        _activeFilterCategory = widget.initialFilter;
      });
    }
  }

  void _showForm(ProductModel? product) {
    if (product != null) {
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
      _descController.text = product.description;
      _stockController.text = product.stock.toString();
      _imageController.text = product.imageUrl;
      _selectedCategory = product.category;
    } else {
      _nameController.clear();
      _priceController.clear();
      _descController.clear();
      _stockController.clear();
      _imageController.clear();
      _selectedCategory = 'Makanan';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, left: 20, right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product == null ? 'Tambah Produk' : 'Edit Produk',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _nameController, 
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ['Makanan', 'Minuman', 'Aksesori', 'Peralatan']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              TextField(
                controller: _priceController, 
                keyboardType: TextInputType.number, 
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                ),
              ),
              TextField(
                controller: _stockController, 
                keyboardType: TextInputType.number, 
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                ),
              ),
              TextField(
                controller: _descController, 
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                ),
              ),
              TextField(
                controller: _imageController, 
                decoration: const InputDecoration(
                  labelText: 'Link URL Gambar (Copy Image Address)',
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () async {
                  final newProduct = ProductModel(
                    id: product?.id ?? '',
                    name: _nameController.text,
                    category: _selectedCategory,
                    price: int.tryParse(_priceController.text) ?? 0,
                    description: _descController.text,
                    stock: int.tryParse(_stockController.text) ?? 0,
                    imageUrl: _imageController.text.trim(),
                  );

                  if (product == null) {
                    await _dbService.addProduct(newProduct);
                  } else {
                    await _dbService.updateProduct(newProduct);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk', style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showForm(null),
            icon: const Icon(Icons.add_circle, size: 28),
            tooltip: 'Tambah Produk Baru',
          ),
          const SizedBox(width: 8),
        ],
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama produk...',
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orange, width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: Colors.white, // Search bar solid putih
                ),
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: _categories.map((category) {
                  final bool isSelected = _activeFilterCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(category),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                      ),
                      selectedColor: Colors.orange,
                      checkmarkColor: Colors.white,
                      side: BorderSide(color: isSelected ? Colors.orange : Colors.grey.shade300),
                      onSelected: (bool value) {
                        setState(() {
                          _activeFilterCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: _dbService.getProducts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orange));
                  
                  final filteredProducts = snapshot.data!.where((prod) {
                    final bool matchesSearch = prod.name.toLowerCase().contains(_searchQuery);
                    
                    bool matchesCategory = false;
                    if (_activeFilterCategory == 'Semua') {
                      matchesCategory = true;
                    } else if (_activeFilterCategory == 'Stok Menipis') {
                      matchesCategory = prod.stock <= 5;
                    } else {
                      matchesCategory = prod.category == _activeFilterCategory;
                    }

                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return const Center(child: Text('Tidak ada produk yang cocok ditemukan.'));
                  }

                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemBuilder: (context, index) {
                      final prod = filteredProducts[index];
                      final bool isLowStock = prod.stock <= 5;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailProductAdminScreen(
                                product: prod,
                                onEditRequested: (productToEdit) {
                                  _showForm(productToEdit);
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          elevation: 4, // Card lebih menonjol
                          color: Colors.white, // Card putih solid
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isLowStock ? Colors.red.withOpacity(0.6) : Colors.orange.shade100,
                              width: isLowStock ? 1.5 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: prod.imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        prod.imageUrl,
                                        width: 55,
                                        height: 55,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                      ),
                                    )
                                  : const Icon(Icons.pets, size: 50, color: Colors.orange),
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Text(
                                      prod.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (isLowStock)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        prod.stock == 0 ? 'HABIS' : 'STOK MENIPIS',
                                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '${prod.category} - Rp ${prod.price}\nStok Saat Ini: ${prod.stock}',
                                  style: TextStyle(
                                    color: isLowStock ? Colors.red.shade800 : Colors.black87,
                                    fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              isThreeLine: true,
                            ),
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
      ),
    );
  }
}