import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  Widget _buildImage(String imageUrl) {
    final String decodedUrl = Uri.decodeFull(imageUrl);

    if (decodedUrl.startsWith('http') || decodedUrl.startsWith('blob:')) {
      return Image.network(
        decodedUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => const Center(
          child: Icon(Icons.broken_image, size: 80, color: Color(0xFFFF8DA1)),
        ),
      );
    }

    if (decodedUrl.startsWith('assets/')) {
      return Image.asset(
        decodedUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => const Center(
          child: Icon(Icons.broken_image, size: 80, color: Color(0xFFFF8DA1)),
        ),
      );
    }

    return kIsWeb
        ? Image.network(
            decodedUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => const Center(
              child: Icon(Icons.broken_image, size: 80, color: Color(0xFFFF8DA1)),
            ),
          )
        : Image.file(
            File(decodedUrl),
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => const Center(
              child: Icon(Icons.broken_image, size: 80, color: Color(0xFFFF8DA1)),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF5D1229)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          product.title,
          style: const TextStyle(
            color: Color(0xFF5D1229),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 320,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFB2C9), width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _buildImage(product.imageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFB2C9), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D1229),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormatter.format(product.price).trim(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9E0038),
                      ),
                    ),
                    const Divider(height: 24, color: Color(0xFFFFB2C9)),
                    const Text(
                      'Deskripsi Produk',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D1229),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (product.description != null && product.description!.trim().isNotEmpty)
                          ? product.description!
                          : 'Tidak ada deskripsi untuk produk ini.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              cartProvider.addToCart(product);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.title} ditambahkan ke keranjang!'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8DA1),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            label: const Text(
              'Tambah ke Keranjang',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}