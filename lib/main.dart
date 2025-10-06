import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFF2C3E50);
    final cardHeaderHeight = 200.0;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF145DA0),
        title: const Text(
          'MI TIENDA',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF2C3E50),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: const Color(0xFF145DA0),
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Menú',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                color: const Color(0xFF145DA0),
                child:Text(
                  'Pantalones',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                )
              )
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
            final products = snapshot.data ?? [];
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
      width: 260,
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
