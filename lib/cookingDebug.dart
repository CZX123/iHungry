import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'cooking.dart';
import 'eatingOut.dart';

class CookingDebugScreen extends StatefulWidget {
  CookingDebugScreen();

  _CookingDebugScreenState createState() => _CookingDebugScreenState();
}

class _CookingDebugScreenState extends State<CookingDebugScreen> {
  @override
  Widget build(BuildContext context) {
    CookingData cookingData = Provider.of<CookingData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cooking Data',
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
                  'Reset Cooking Data',
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                onPressed: () {
                  getApplicationDocumentsDirectory().then((dir) {
                    File cookingFile = File('${dir.path}/cookingData.json');
                    Map<String, dynamic> cookingFileContents = {
                      'ratio': 1.0,
                      'history': {},
                    };
                    cookingFile
                        .writeAsStringSync(jsonEncode(cookingFileContents));
                    cookingData.resetData();
                    cookingData.changeRatio(1.0);
                    DateTime lastMeal;
                    File eatingOutFile = File('${dir.path}/eatingOutData.json');
                    if (eatingOutFile.existsSync()) {
                      Map<String, dynamic> eatingOutFileContents =
                          jsonDecode(eatingOutFile.readAsStringSync());
                      if (eatingOutFileContents.length > 0)
                        lastMeal = DateTime.parse(
                            eatingOutFileContents.keys.toList().last);
                    }
                    Provider.of<EatingOutData>(context).changeLastMeal(
                      lastMeal ?? DateTime.now().subtract(Duration(hours: 6)),
                    );
                  });
                },
              ),
            ),
            FutureBuilder<Directory>(
              future: getApplicationDocumentsDirectory(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                File cookingFile =
                    File('${snapshot.data.path}/cookingData.json');
                if (!cookingFile.existsSync()) return SizedBox();
                Map<String, dynamic> cookingFileContents =
                    jsonDecode(cookingFile.readAsStringSync());
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
                        Text('ratio: ${cookingFileContents['ratio']}'),
                        Text('history:'),
                        for (String i in cookingFileContents['history'].keys)
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('$i:'),
                                for (dynamic j
                                    in cookingFileContents['history'][i].keys)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: j == 'suggestions'
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('suggestions:'),
                                              for (String k
                                                  in cookingFileContents[
                                                              'history'][i]
                                                          ['suggestions']
                                                      .keys)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16),
                                                  child: Text(
                                                      '$k: ${cookingFileContents['history'][i]['suggestions'][k]}'),
                                                ),
                                            ],
                                          )
                                        : Text(
                                            '$j: ${cookingFileContents['history'][i][j]}'),
                                  ),
                              ],
                            ),
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
