import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String cleanText = newValue.text.replaceAll('.', '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    double value = double.tryParse(cleanText) ?? 0;
    String formattedText = _formatter.format(value).trim();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  XFile? _pickedImage;
  String? _webImageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _pickedImage = image;
      _webImageUrl = image.path;
    });
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImage == null && _webImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih foto produk terlebih dahulu!')),
      );
      return;
    }

    final cleanPriceText = _priceController.text.replaceAll('.', '');
    final price = double.tryParse(cleanPriceText) ?? 0;

    final newProduct = Product(
      id: DateTime.now().toString(),
      title: _titleController.text,
      price: price,
      imageUrl: _webImageUrl ?? 'assets/images/baju.jpg',
      description: _descriptionController.text.isEmpty
          ? 'Deskripsi produk ${_titleController.text}.'
          : _descriptionController.text,
    );

    Provider.of<CartProvider>(context, listen: false).addProduct(newProduct);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8DA1),
        title: const Text(
          'Tambah Produk Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama produk tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Produk',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Klik kotak di bawah untuk upload foto:',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFB2C9), width: 1.5),
                    ),
                    child: _pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: kIsWeb
                                ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                                : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                          )
                        : const Icon(
                            Icons.add_a_photo_outlined,
                            size: 40,
                            color: Color(0xFFFF8DA1),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8DA1),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Simpan Produk',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}