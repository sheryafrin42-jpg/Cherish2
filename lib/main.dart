import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'screens/catalog_screen.dart';

void main() async {
  // Memastikan binding Flutter siap sebelum memanggil database
  WidgetsFlutterBinding.ensureInitialized();
  
  final cartProvider = CartProvider();
  await cartProvider.fetchAndSetProducts(); // Muat data database di awal app

  runApp(
    ChangeNotifierProvider.value(
      value: cartProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cherish App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Lato',
      ),
      home: const CatalogScreen(),
    );
  }
}