
import 'package:app_flutter/models/category.dart';
import 'package:app_flutter/services/category_service.dart';
import 'package:app_flutter/services/pictogram_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPictogramScreen extends StatefulWidget {
  const AddPictogramScreen({super.key});

  @override
  State<AddPictogramScreen> createState() => _AddPictogramScreenState();
}

class _AddPictogramScreenState extends State<AddPictogramScreen> {
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  Category? _selectedCategory;
  List<Category> _categories = [];
  bool _isLoading = false;

  final CategoryService _categoryService = CategoryService(Supabase.instance.client);
  final PictogramService _pictogramService = PictogramService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar categorías: $e')),
      );
    }
  }

  Future<void> _addPictogram() async {
    setState(() {
      _isLoading = true;
    });

    if (_nameController.text.isEmpty || _imageUrlController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await _pictogramService.addPictogram(
        name: _nameController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        categoryId: _selectedCategory!.id,
        userId: Supabase.instance.client.auth.currentUser!.id, // Associate with current user
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pictograma añadido con éxito!')),
        );
        _nameController.clear();
        _imageUrlController.clear();
        setState(() {
          _selectedCategory = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir pictograma: $e')),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Nuevo Pictograma'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Pictograma',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL de la Imagen',
                      hintText: 'Ej: https://ejemplo.com/imagen.png',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<Category>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Selecciona una categoría'),
                    onChanged: (Category? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    items: _categories.map((Category category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _addPictogram,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text('Añadir Pictograma'),
                  ),
                ],
              ),
            ),
    );
  }
}
