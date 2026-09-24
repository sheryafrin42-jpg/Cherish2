import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../helpers/db_helper.dart';

class CartProvider with ChangeNotifier {
  final List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Pink Cheongsam Blouse',
      price: 112000,
      imageUrl: 'assets/images/baju.jpg',
      description: 'Atasan cheongsam bernuansa pink anggun dengan bahan premium yang nyaman dipakai.',
    ),
    Product(
      id: 'p2',
      title: 'Lace Flare Jeans',
      price: 260000,
      imageUrl: 'assets/images/celana.jpg',
      description: 'Celana jeans flare stylish dengan aksen renda cantik.',
    ),
    Product(
      id: 'p3',
      title: 'Pink High Heels',
      price: 260000,
      imageUrl: 'assets/images/heels.jpg',
      description: 'Sepatu heels elegan yang cocok untuk acara formal maupun kasual.',
    ),
    Product(
      id: 'p4',
      title: 'Cute Pink Wallet',
      price: 95000,
      imageUrl: 'assets/images/wallet.jpg',
      description: 'Dompet wanita simpel dan manis dengan banyak slot kartu.',
    ),
  ];

  final Map<String, CartItem> _cartItems = {};

  List<Product> get items => [..._items];
  Map<String, CartItem> get cartItems => {..._cartItems};

  int get itemCount {
    var count = 0;
    _cartItems.forEach((key, cartItem) {
      count += cartItem.quantity;
    });
    return count;
  }

  double get totalAmount {
    var total = 0.0;
    _cartItems.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // --- OPSI PERSISTENSI (MUAT PRODUK & KERANJANG DARI DB) ---

  Future<void> fetchAndSetProducts() async {
    try {
      // 1. Muat Produk Tambahan
      final productList = await DBHelper.getData('user_products');
      for (var item in productList) {
        final prodId = item['id'] as String;
        if (!_items.any((p) => p.id == prodId)) {
          _items.add(
            Product(
              id: prodId,
              title: item['title'] as String,
              price: (item['price'] as num).toDouble(),
              imageUrl: item['imageUrl'] as String,
              description: item['description'] as String,
            ),
          );
        }
      }

      // 2. Muat Keranjang Belanja dari SQLite
      final cartList = await DBHelper.getData('cart_items');
      _cartItems.clear();
      for (var item in cartList) {
        final prodId = item['productId'] as String;
        _cartItems[prodId] = CartItem(
          id: item['id'] as String,
          title: item['title'] as String,
          quantity: item['quantity'] as int,
          price: (item['price'] as num).toDouble(),
          imageUrl: item['imageUrl'] as String,
        );
      }

      notifyListeners();
    } catch (error) {
      debugPrint('Error fetch database: $error');
    }
  }

  Future<void> addProduct(Product product) async {
    final newProduct = Product(
      id: DateTime.now().toString(),
      title: product.title,
      price: product.price,
      imageUrl: product.imageUrl,
      description: product.description,
    );

    _items.add(newProduct);
    notifyListeners();

    await DBHelper.insert('user_products', <String, dynamic>{
      'id': newProduct.id,
      'title': newProduct.title,
      'price': newProduct.price,
      'imageUrl': newProduct.imageUrl,
      'description': newProduct.description,
    });
  }

  // --- KELOLA KERANJANG BELANJA TERPERSISTENSI ---

  Future<void> addToCart(Product product) async {
    if (_cartItems.containsKey(product.id)) {
      _cartItems.update(
        product.id,
        (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          quantity: existing.quantity + 1,
          price: existing.price,
          imageUrl: existing.imageUrl,
        ),
      );
    } else {
      _cartItems.putIfAbsent(
        product.id,
        () => CartItem(
          id: DateTime.now().toString(),
          title: product.title,
          quantity: 1,
          price: product.price,
          imageUrl: product.imageUrl,
        ),
      );
    }
    notifyListeners();

    final item = _cartItems[product.id]!;
    await DBHelper.insert('cart_items', <String, dynamic>{
      'id': item.id,
      'productId': product.id,
      'title': item.title,
      'price': item.price,
      'quantity': item.quantity,
      'imageUrl': item.imageUrl,
    });
  }

  Future<void> addSingleItem(String productId) async {
    if (!_cartItems.containsKey(productId)) return;
    _cartItems.update(
      productId,
      (existing) => CartItem(
        id: existing.id,
        title: existing.title,
        quantity: existing.quantity + 1,
        price: existing.price,
        imageUrl: existing.imageUrl,
      ),
    );
    notifyListeners();

    final item = _cartItems[productId]!;
    await DBHelper.insert('cart_items', <String, dynamic>{
      'id': item.id,
      'productId': productId,
      'title': item.title,
      'price': item.price,
      'quantity': item.quantity,
      'imageUrl': item.imageUrl,
    });
  }

  Future<void> removeSingleItem(String productId) async {
    if (!_cartItems.containsKey(productId)) return;
    if (_cartItems[productId]!.quantity > 1) {
      _cartItems.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          quantity: existing.quantity - 1,
          price: existing.price,
          imageUrl: existing.imageUrl,
        ),
      );
      notifyListeners();

      final item = _cartItems[productId]!;
      await DBHelper.insert('cart_items', <String, dynamic>{
        'id': item.id,
        'productId': productId,
        'title': item.title,
        'price': item.price,
        'quantity': item.quantity,
        'imageUrl': item.imageUrl,
      });
    } else {
      final cartId = _cartItems[productId]!.id;
      _cartItems.remove(productId);
      notifyListeners();

      await DBHelper.delete('cart_items', cartId);
    }
  }

  Future<void> removeItem(String productId) async {
    if (_cartItems.containsKey(productId)) {
      final cartId = _cartItems[productId]!.id;
      _cartItems.remove(productId);
      notifyListeners();

      await DBHelper.delete('cart_items', cartId);
    }
  }

  Future<void> clear() async {
    _cartItems.clear();
    notifyListeners();

    await DBHelper.clearTable('cart_items');
  }
}