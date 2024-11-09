class Recipe {
  final int id;
  final String title;
  final String imageUrl;
  final List<String> ingredients;
  String sourceUrl;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.sourceUrl,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Extract ingredient names and create a list
    List<String> ingredients = [];
    if (json['missedIngredients'] != null) {
      ingredients = List<String>.from(json['missedIngredients']
          .map((ingredient) => ingredient['name'] ?? ''));
    }

    return Recipe(
      id: json['id'], // Get the id from the API response
      title: json['title'],
      imageUrl: json['image'],
      sourceUrl: json['sourceUrl'] ?? '',
      ingredients: ingredients,
    );
  }
}
