import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Tienda',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF145DA0)),
        useMaterial3: true,
      ),
      home: const StorePage(),
    );
  }
}

class Product {
  final String id;
  final String productType;
  final String name;
  final String size;
  final double price;
  final int amount;
  final String blobName;

  const Product({
    required this.id,
    required this.productType,
    required this.name,
    required this.size,
    required this.price,
    required this.amount,
    required this.blobName,
  });

  String get imageUrl => 'https://prueba-api-dmoz.onrender.com/image/$blobName';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      productType: json['product_type'] as String,
      name: json['product_name'] as String,
      size: json['size'] as String,
      price: (json['price'] as num).toDouble(),
      amount: (json['amount'] as num).toInt(),
      blobName: json['blob_name'] as String,
    );
  }
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late Future<List<Product>> _futureProducts;
  String? _selectedType; // e.g. 'pants', 'tshirt', 'shirt', 'shoes', 'belt', 'cap'
  static const List<String> _types = ['pants', 'shirt', 'tshirt', 'belt', 'shoes', 'cap'];
  static const List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _imageUrlCtrl = TextEditingController();
  final TextEditingController _blobNameCtrl = TextEditingController();
  String? _newType;
  String? _newSize;

  @override
  void initState() {
    super.initState();
    _futureProducts = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final uri = Uri.parse('https://prueba-api-dmoz.onrender.com/get_productos');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error al cargar productos (${response.statusCode})');
    }
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  void _setFilter(String? type) {
    setState(() {
      _selectedType = type;
    });
    Navigator.of(context).maybePop();
  }

  bool _isSelected(String? type) => _selectedType == type;

  BoxDecoration _drawerItemDecoration(bool selected) {
    return BoxDecoration(
      color: Colors.white.withOpacity(selected ? 0.20 : 0.05),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: selected ? const Color(0xFF4FC3F7) : Colors.white),
    );
  }

  Future<void> _openAddProductModal() async {
    _newType = null;
    _newSize = null;
    _nameCtrl.clear();
    _priceCtrl.clear();
    _amountCtrl.clear();
    _imageUrlCtrl.clear();
    _blobNameCtrl.clear();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C3E50),
          title: const Text('Agregar producto', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setInner) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Tipo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _types.map((t) {
                          final selected = _newType == t;
                          return ChoiceChip(
                            label: Text(
                              t,
                              style: TextStyle(
                                color: selected ? Colors.white : const Color.fromARGB(255, 7, 39, 54),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: selected,
                            selectedColor: const Color(0xFF145DA0),
                            backgroundColor: const Color(0xFF145DA0).withOpacity(0.18),
                            side: BorderSide(color: selected ? const Color(0xFF4FC3F7) : const Color(0xFF1976D2)),
                            onSelected: (_) => setInner(() => _newType = t),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      const Text('Talla', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _sizes.map((s) {
                          final selected = _newSize == s;
                          return ChoiceChip(
                            label: Text(
                              s,
                              style: TextStyle(
                                color: selected ? Colors.white : const Color.fromARGB(255, 7, 39, 54),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: selected,
                            selectedColor: const Color(0xFF145DA0),
                            backgroundColor: const Color(0xFF145DA0).withOpacity(0.18),
                            side: BorderSide(color: selected ? const Color(0xFF4FC3F7) : const Color(0xFF1976D2)),
                            onSelected: (_) => setInner(() => _newSize = s),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(_nameCtrl, label: 'Nombre', keyboardType: TextInputType.text),
                      const SizedBox(height: 8),
                      _buildTextField(_priceCtrl, label: 'Precio', keyboardType: TextInputType.number),
                      const SizedBox(height: 8),
                      _buildTextField(_amountCtrl, label: 'Cantidad', keyboardType: TextInputType.number),
                      const SizedBox(height: 8),
                      _buildTextField(_imageUrlCtrl, label: 'Imagen URL (SAS)'),
                      const SizedBox(height: 8),
                      _buildTextField(_blobNameCtrl, label: 'Blob name'),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: _submitNewProduct,
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, {required String label, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Requerido';
        if (controller == _priceCtrl || controller == _amountCtrl) {
          final parsed = num.tryParse(v);
          if (parsed == null) return 'Número inválido';
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.4))),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4FC3F7))),
      ),
    );
  }

  Future<void> _submitNewProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newType == null || _newSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona tipo y talla')));
      return;
    }
    final uri = Uri.parse('https://prueba-api-dmoz.onrender.com/productos');
    final body = jsonEncode({
      'product_type': _newType,
      'product_name': _nameCtrl.text.trim(),
      'size': _newSize,
      'price': double.parse(_priceCtrl.text.trim()),
      'amount': int.parse(_amountCtrl.text.trim()),
      'image_url': _imageUrlCtrl.text.trim(),
      'blob_name': _blobNameCtrl.text.trim(),
    });
    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto agregado')));
        }
        setState(() {
          _futureProducts = _fetchProducts();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al agregar (${resp.statusCode})')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de red: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFF2C3E50);
    final cardHeaderHeight = 200.0;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF145DA0),
        title: const Text(
          'MI TIENDA',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            tooltip: 'Agregar producto',
            onPressed: _openAddProductModal,
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF2C3E50),
        child: SafeArea(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                color: const Color(0xFF145DA0),
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Menú',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _setFilter(null),
                  child: Container(
                  width: 300,
                  height: 50,
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: _drawerItemDecoration(_isSelected(null)),
                  child: const Text(
                    'Todos los productos',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                    softWrap: false,
                  ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _setFilter('pants'),
                  child: Container(
                width: 300,
                height: 50,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                  decoration: _drawerItemDecoration(_isSelected('pants')),
                child: const Text(
                  'Pantalones',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                  softWrap: false,
                ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _setFilter('tshirt'),
                  child: Container(
                width: 300,
                height: 50,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                  decoration: _drawerItemDecoration(_isSelected('tshirt')),
                child: const Text(
                  'Playeras',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                  softWrap: false,
                ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _setFilter('shirt'),
                  child: Container(
                width: 300,
                height: 50,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                  decoration: _drawerItemDecoration(_isSelected('shirt')),
                child: const Text(
                  'Camisas',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                  softWrap: false,
                ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _setFilter('shoes'),
                  child: Container(
                width: 300,
                height: 50,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                  decoration: _drawerItemDecoration(_isSelected('shoes')),
                child: const Text(
                  'Calzado',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                  softWrap: false,
                ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _setFilter('belt'),
                  child: Container(
                width: 300,
                height: 50,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                  decoration: _drawerItemDecoration(_isSelected('belt')),
                child: const Text(
                  'Cinturones',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                  softWrap: false,
                ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _setFilter('cap'),
                  child: Container(
                width: 300,
                height: 50,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                  decoration: _drawerItemDecoration(_isSelected('cap')),
                child: const Text(
                  'Gorras',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                  softWrap: false,
                ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: FutureBuilder<List<Product>>(
          future: _futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Ocurrió un error: ${snapshot.error}'),
              );
            }
            final productsAll = snapshot.data ?? [];
            final products = productsAll.where((p) {
              if (_selectedType == null) return true;
              // Acepta equivalencias ('pant' en API vs 'pants' solicitado)
              if (_selectedType == 'pants') return p.productType == 'pants' || p.productType == 'pant';
              return p.productType == _selectedType;
            }).toList();
            if (products.isEmpty) {
              return const Center(
                child: Text(
                  'No hay productos disponibles',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              );
            }
            return SingleChildScrollView(
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                children: products.map((p) {
                  return _ProductCard(product: p, headerHeight: cardHeaderHeight);
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final double headerHeight;

  const _ProductCard({required this.product, required this.headerHeight});

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.white.withOpacity(0.6);
    return Container(
      width: 255,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.network(
              product.imageUrl,
              height: headerHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF5D6D7E).withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Precio: ${product.price.toStringAsFixed(0)} MXN',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Cantidad: ${product.amount}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
