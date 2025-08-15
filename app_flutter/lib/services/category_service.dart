import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_flutter/models/category.dart';

class CategoryService {
  final SupabaseClient _supabaseClient;

  CategoryService(this._supabaseClient);

  Future<List<Category>> getCategories() async {
    final response = await _supabaseClient
        .from('categories')
        .select()
        .order('name', ascending: true);

    final List<Category> categories = [];
    for (var categoryData in response) {
      categories.add(Category.fromJson(categoryData));
    }
    return categories;
  }

  Future<void> addCategory({
    required String name,
    required String userId,
  }) async {
    await _supabaseClient.from('categories').insert({
      'name': name,
      'user_id': userId,
    });
  }
}