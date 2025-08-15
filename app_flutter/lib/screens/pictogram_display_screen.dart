
import 'package:app_flutter/models/pictogram.dart';
import 'package:app_flutter/screens/phrase_builder_screen.dart';
import 'package:app_flutter/screens/add_pictogram_screen.dart'; // Added this import
import 'package:app_flutter/services/pictogram_service.dart';
import 'package:app_flutter/services/phrase_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ADDED THIS IMPORT

class PictogramDisplayScreen extends StatefulWidget {
  final int? categoryId;

  const PictogramDisplayScreen({super.key, this.categoryId});

  @override
  State<PictogramDisplayScreen> createState() => _PictogramDisplayScreenState();
}

class _PictogramDisplayScreenState extends State<PictogramDisplayScreen> {
  // Corrected: Removed Supabase.instance.client from constructor
  final PictogramService _pictogramService = PictogramService();
  late Future<List<Pictogram>> _pictogramsFuture;

  @override
  void initState() {
    super.initState();
    _pictogramsFuture = _pictogramService.getPictograms(categoryId: widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryId == null ? 'Todos los Pictogramas' : 'Pictogramas de Categoría'),
      ),
      body: FutureBuilder<List<Pictogram>>(
        future: _pictogramsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron pictogramas.'));
          }

          final pictograms = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Adjust for different screen sizes
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: pictograms.length,
            itemBuilder: (context, index) {
              final pictogram = pictograms[index];
              return Card(
                child: InkWell(
                  onTap: () {
                    Provider.of<PhraseProvider>(context, listen: false).addPictogram(pictogram);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Se añadió ${pictogram.name} a la frase')),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.network(
                          pictogram.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported, size: 48);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          pictogram.name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addPictogramFab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPictogramScreen()),
              );
            },
            child: const Icon(Icons.add_a_photo),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'phraseBuilderFab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PhraseBuilderScreen()),
              );
            },
            child: const Icon(Icons.message),
          ),
        ],
      ),
    );
  }
}
