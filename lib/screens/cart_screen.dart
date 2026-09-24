import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Widget _buildProductImage(String imageUrl) {
    final String decodedUrl = Uri.decodeFull(imageUrl);

    if (decodedUrl.startsWith('http') || decodedUrl.startsWith('blob:')) {
      return Image.network(
        decodedUrl,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        errorBuilder: (ctx, err, stack) =>
            const Icon(Icons.broken_image, color: Colors.pink, size: 30),
      );
    }

    if (decodedUrl.startsWith('assets/')) {
      return Image.asset(
        decodedUrl,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        errorBuilder: (ctx, err, stack) =>
            const Icon(Icons.broken_image, color: Colors.pink, size: 30),
      );
    }

    return kIsWeb
        ? Image.network(
            decodedUrl,
            fit: BoxFit.cover,
            width: 60,
            height: 60,
            errorBuilder: (ctx, err, stack) =>
                const Icon(Icons.broken_image, color: Colors.pink, size: 30),
          )
        : Image.file(
            File(decodedUrl),
            fit: BoxFit.cover,
            width: 60,
            height: 60,
            errorBuilder: (ctx, err, stack) =>
                const Icon(Icons.broken_image, color: Colors.pink, size: 30),
          );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5D1229)),
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(
            color: Color(0xFF5D1229),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (ctx, cart, child) {
          final cartItemsList = cart.cartItems.values.toList();
          final cartProductIds = cart.cartItems.keys.toList();

          return Column(
            children: [
              Expanded(
                child: cartItemsList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 80,
                              color: Colors.pink.shade200,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Keranjang kamu masih kosong',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF5D1229),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItemsList.length,
                        itemBuilder: (ctx, index) {
                          final item = cartItemsList[index];
                          final prodId = cartProductIds[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: Color(0xFFFFB2C9),
                                width: 1,
                              ),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _buildProductImage(item.imageUrl),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF5D1229),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          currencyFormatter.format(item.price),
                                          style: const TextStyle(
                                            color: Color(0xFF9E0038),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Kontrol Tombol Plus & Min
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7F8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFFFB2C9),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove, size: 18),
                                          color: const Color(0xFF5D1229),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          onPressed: () {
                                            cart.removeSingleItem(prodId);
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF5D1229),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 18),
                                          color: const Color(0xFF5D1229),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          onPressed: () {
                                            cart.addSingleItem(prodId);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      cart.removeItem(prodId);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Card Total Pembayaran & Checkout
              if (cartItemsList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D1229),
                            ),
                          ),
                          Text(
                            currencyFormatter.format(cart.totalAmount),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9E0038),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8DA1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            // aksi checkout
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pesanan berhasil dibuat!'),
                                backgroundColor: Color(0xFF5D1229),
                              ),
                            );
                            cart.clear();
                          },
                          child: const Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}