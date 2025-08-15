import 'package:app_flutter/screens/category_selection_screen.dart';
import 'package:app_flutter/services/arasaac_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  final ArasaacService _arasaacService = ArasaacService(Supabase.instance.client);

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¡Bienvenido!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategorySelectionScreen()),
                );
              },
              child: const Text('Ir a la Biblioteca de Pictogramas'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sincronizando pictogramas ARASAAC...')),
                  );
                  await _arasaacService.syncArasaacPictograms('es');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pictogramas ARASAAC sincronizados con éxito!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al sincronizar ARASAAC: $e')),
                  );
                }
              },
              child: const Text('Sincronizar ARASAAC'),
            ),
          ],
        ),
      ),
    );
  }
}