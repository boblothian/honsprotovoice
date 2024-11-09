import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api_service.dart';
import 'recipe_model.dart';

void main() => runApp(RecipeFinderApp());

class RecipeFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Finder',
      theme: ThemeData(primarySwatch: Colors.green),
      home: RecipeFinderScreen(),
    );
  }
}

class RecipeFinderScreen extends StatefulWidget {
  @override
  _RecipeFinderScreenState createState() => _RecipeFinderScreenState();
}

class _RecipeFinderScreenState extends State<RecipeFinderScreen> {
  final ApiService apiService = ApiService();
  final SpeechToText _speechToText = SpeechToText();
  final TextEditingController ingredientController = TextEditingController();
  List<Recipe> recipes = [];

  bool _speechEnabled = false;
  bool _isListening = false; // Track if we're currently listening
  String _wordsSpoken = "";

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  // Toggle the listening state on button press
  void _toggleListening() async {
    if (_isListening) {
      // Stop listening
      await _speechToText.stop();
    } else {
      // Clear previous words before starting new listening
      _wordsSpoken = "";
      await _speechToText.listen(onResult: _onSpeechResult);
    }

    // Toggle the listening state
    setState(() {
      _isListening = !_isListening;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      // Check if the recognized words have changed
      if (!_wordsSpoken.contains(result.recognizedWords)) {
        if (_wordsSpoken.isEmpty) {
          _wordsSpoken = result.recognizedWords;
        } else {
          _wordsSpoken += ', ' + result.recognizedWords;
        }
        ingredientController.text = _wordsSpoken; // Update TextField
      }
    });
  }

  Future<void> searchRecipes() async {
    final ingredients =
        ingredientController.text.split(',').map((e) => e.trim()).toList();
    final results = await apiService.fetchRecipes(ingredients);
    for (var recipe in results) {
      await apiService.fetchRecipeDetails(recipe);
    }
    setState(() {
      recipes = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Finder'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: ingredientController,
              decoration: InputDecoration(
                labelText: 'Enter ingredients (comma-separated)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _speechEnabled ? _toggleListening : null,
              child:
                  Text(_isListening ? 'Stop Voice Input' : 'Start Voice Input'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: searchRecipes,
              child: Text('Find Recipes'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return Card(
                    child: ListTile(
                      leading: Image.network(recipe.imageUrl,
                          width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(recipe.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(
                              'Required Ingredients:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (recipe.ingredients.isEmpty)
                            Text('No ingredients needed')
                          else
                            ...recipe.ingredients
                                .map((ingredient) => Text(ingredient))
                                .toList(),
                          GestureDetector(
                            onTap: () async {
                              String url = recipe.sourceUrl;
                              if (url.isEmpty) {
                                print('No source URL available');
                                return;
                              }
                              if (!url.startsWith('http')) {
                                url = 'https://' + url;
                              }

                              final Uri uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                print('Could not launch URL: $url');
                              }
                            },
                            child: Text(
                              'See Recipe',
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
