import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'edit_product_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  Widget _buildProductImage(String imageUrl) {
    final String decodedUrl = Uri.decodeFull(imageUrl);

    if (decodedUrl.startsWith('http') || decodedUrl.startsWith('blob:')) {
      return Image.network(
        decodedUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (ctx, err, stack) =>
            const Icon(Icons.broken_image, color: Colors.pink, size: 40),
      );
    }

    if (decodedUrl.startsWith('assets/')) {
      return Image.asset(
        decodedUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (ctx, err, stack) =>
            const Icon(Icons.broken_image, color: Colors.pink, size: 40),
      );
    }

    return kIsWeb
        ? Image.network(
            decodedUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (ctx, err, stack) =>
                const Icon(Icons.broken_image, color: Colors.pink, size: 40),
          )
        : Image.file(
            File(decodedUrl),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (ctx, err, stack) =>
                const Icon(Icons.broken_image, color: Colors.pink, size: 40),
          );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return Consumer<CartProvider>(
      builder: (ctx, cart, child) {
        final products = cart.items;

        return Scaffold(
          backgroundColor: const Color(0xFFFFF7F8),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFF8DA1), // Warna Background Pink Sesuai Gambar
            elevation: 0,
            title: const Text(
              'CHERISH',
              style: TextStyle(
                color: Colors.white, // Teks Putih
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white, // Ikon Belanja Putih
                      size: 26,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF5D1229),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (ctx, i) {
                final product = products[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFB2C9),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFFFF7F8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildProductImage(product.imageUrl),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF5D1229),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            currencyFormatter.format(product.price),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF9E0038),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 34,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFFFF8DA1),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                cart.addToCart(product);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.title} ditambahkan ke keranjang!'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: const Color(0xFF5D1229),
                                  ),
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 16,
                                    color: Color(0xFFFF8DA1),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Tambah',
                                    style: TextStyle(
                                      color: Color(0xFFFF8DA1),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFFFF8DA1),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const EditProductScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}