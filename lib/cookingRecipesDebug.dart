import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'cooking.dart';

class CookingRecipesDebugScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CookingData cookingData = Provider.of<CookingData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cooking Recipes Data',
          style: Theme.of(context).textTheme.title.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 16,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: FlatButton(
                child: Text(
                  'Reset Cooking Recipes Data',
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                onPressed: () {
                  cookingData.changeRecipes({
                    'Fried Rice': friedRiceRecipe,
                  });
                  if (cookingData.suggestions.containsKey('Fried Rice'))
                    cookingData.changeSuggestions({
                      'Fried Rice': friedRiceRecipe,
                    });
                  else
                    cookingData.changeSuggestions({});
                },
              ),
            ),
            FutureBuilder<Directory>(
              future: getApplicationDocumentsDirectory(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                File cookingRecipesFile =
                    File('${snapshot.data.path}/cookingRecipes.json');
                if (!cookingRecipesFile.existsSync()) return SizedBox();
                Map<String, dynamic> cookingRecipesFileContents =
                    jsonDecode(cookingRecipesFile.readAsStringSync());
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.body1.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        for (String dishName in cookingRecipesFileContents.keys)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('$dishName:'),
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    for (var ingredient
                                        in cookingRecipesFileContents[dishName])
                                      Text(
                                          '${ingredient['value']} ${ingredient['unit']}${ingredient['unit'] == '' ? '' : ' of '}${ingredient['name']}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
