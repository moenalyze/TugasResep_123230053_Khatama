import 'dart:convert';
import 'package:http/http.dart' as http;

class MealApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Map<String, dynamic>>> fetchMealsByCategory(String category) async {
    final uri = Uri.parse('$_baseUrl/filter.php?c=${Uri.encodeComponent(category)}');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List meals = data['meals'] ?? [];
        return meals
            .map<Map<String, dynamic>>((m) => {
                  'id': m['idMeal'] as String,
                  'title': m['strMeal'] as String,
                  'imageUrl': m['strMealThumb'] as String,
                })
            .toList();
      } else {
        throw Exception(
            'Failed to fetch meals. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching meals: $e');
    }
  }

  Future<Map<String, dynamic>> fetchMealDetail(String id) async {
    final uri = Uri.parse('$_baseUrl/lookup.php?i=${Uri.encodeComponent(id)}');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List meals = data['meals'] ?? [];
        if (meals.isEmpty) {
          throw Exception('Meal not found for id: $id');
        }
        return meals.first as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to fetch meal detail. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching meal detail: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchMeals(String query) async {
    final uri = Uri.parse('$_baseUrl/search.php?s=${Uri.encodeComponent(query)}');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List meals = data['meals'] ?? [];
        return meals
            .map<Map<String, dynamic>>((m) => {
                  'id': m['idMeal'] as String,
                  'title': m['strMeal'] as String,
                  'imageUrl': m['strMealThumb'] as String,
                })
            .toList();
      } else {
        throw Exception('Failed to search meals. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching meals: $e');
    }
  }

  Future<List<String>> fetchCategories() async {
    final uri = Uri.parse('$_baseUrl/categories.php');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List categories = data['categories'] ?? [];
        return categories.map<String>((c) => c['strCategory'] as String).toList();
      } else {
        throw Exception('Failed to fetch categories. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}