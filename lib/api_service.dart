import 'dart:convert';

import 'package:http/http.dart' as http;

import 'recipe_model.dart';

class ApiService {
  static const String apiKey = '80fe357623b047389136bcf74c030cc3';
  static const String apiUrl =
      'https://api.spoonacular.com/recipes/findByIngredients';

  Future<List<Recipe>> fetchRecipes(List<String> ingredients) async {
    final String ingredientsQuery = ingredients.join(',');
    final Uri url = Uri.parse(
        '$apiUrl?ingredients=$ingredientsQuery&number=2&apiKey=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // Fetch recipe details including sourceUrl
  Future<void> fetchRecipeDetails(Recipe recipe) async {
    final Uri url = Uri.parse(
        'https://api.spoonacular.com/recipes/${recipe.id}/information?apiKey=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      recipe.sourceUrl = data['sourceUrl'] ?? ''; // Ensure sourceUrl is set
    } else {
      print('Failed to load recipe details for ID: ${recipe.id}');
    }
  }
}
