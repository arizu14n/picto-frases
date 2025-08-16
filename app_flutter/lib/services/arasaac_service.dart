
import 'dart:convert';
import 'package:app_flutter/models/pictogram.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class ArasaacService {
  final SupabaseClient _supabaseClient;

  ArasaacService(this._supabaseClient);

  Future<List<Pictogram>> fetchArasaacPictograms(String language) async {
    final response = await http.get(Uri.parse('https://api.arasaac.org/v1/pictograms/all/' + language));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Pictogram.fromArasaacJson(json)).toList();
    } else {
      throw Exception('Failed to load ARASAAC pictograms');
    }
  }

  Future<void> syncArasaacPictograms(String language) async {
    try {
      // 1. Find or create the ARASAAC category
      const categoryName = 'ARASAAC';
      var categoryResponse = await _supabaseClient
          .from('categories')
          .select('id')
          .eq('name', categoryName)
          .maybeSingle();

      int categoryId;
      if (categoryResponse == null) {
        // Category does not exist, create it
        final newCategory = await _supabaseClient
            .from('categories')
            .insert({'name': categoryName})
            .select('id')
            .single();
        categoryId = newCategory['id'];
      } else {
        categoryId = categoryResponse['id'];
      }

      // 2. Fetch pictograms
      final pictograms = await fetchArasaacPictograms(language);
      
      // 3. Prepare pictograms for insertion with the category ID
      final List<Map<String, dynamic>> pictogramsToInsert = pictograms.map((p) => {
        'name': p.name,
        'image_url': p.imageUrl,
        'audio_url': p.audioUrl,
        'category_id': categoryId, // Assign the ARASAAC category ID
        'user_id': p.userId, // Will be null for ARASAAC
      }).toList();

      // 4. Supabase bulk insert with on conflict do nothing
      await _supabaseClient.from('pictograms').upsert(pictogramsToInsert, onConflict: 'name', ignoreDuplicates: true);
      print('ARASAAC pictograms synced successfully!');
    } catch (e) {
      print('Error syncing ARASAAC pictograms: $e');
      rethrow; // Re-throw to be caught by UI
    }
  }
}
