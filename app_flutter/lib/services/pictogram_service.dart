
import 'package:app_flutter/models/pictogram.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PictogramService {
  final _supabase = Supabase.instance.client;

  Future<List<Pictogram>> getPictograms({int? categoryId}) async {
    try {
      PostgrestFilterBuilder query = _supabase.from('pictograms').select();

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query;
      
      final pictograms = (response as List)
          .map((item) => Pictogram.fromMap(item as Map<String, dynamic>))
          .toList();
          
      return pictograms;
    } catch (e) {
      // In a real app, you'd handle this error more gracefully.
      // For now, we'll just print it and return an empty list.
      print('Error fetching pictograms: $e');
      return [];
    }
  }

  Future<void> addPictogram({
    required String name,
    required String imageUrl,
    required int categoryId,
    required String userId,
  }) async {
    await _supabase.from('pictograms').insert({
      'name': name,
      'image_url': imageUrl,
      'category_id': categoryId,
      'user_id': userId,
    });
  }
}
