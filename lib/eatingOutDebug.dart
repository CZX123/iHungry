import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'eatingOut.dart';

class EatingOutDebugScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    EatingOutData eatingOutData = Provider.of<EatingOutData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Eating Out Data',
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
                  'Reset Eating Out Data',
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                onPressed: () {
                  getApplicationDocumentsDirectory().then((dir) {
                    File eatingOutFile = File('${dir.path}/eatingOutData.json');
                    Map<String, double> eatingOutFileContents = {};
                    eatingOutFile
                        .writeAsStringSync(jsonEncode(eatingOutFileContents));
                    eatingOutData.changeLastMeal(
                      DateTime.now().subtract(Duration(hours: 6)),
                    );
                  });
                  getApplicationDocumentsDirectory().then((dir) {
                    File cookingFile = File('${dir.path}/cookingData.json');
                    File eatingOutFile = File('${dir.path}/eatingOutData.json');
                    DateTime lastMeal;
                    if (cookingFile.existsSync()) {
                      Map<String, dynamic> cookingFileContents =
                          jsonDecode(cookingFile.readAsStringSync());
                      if (cookingFileContents['history'].length > 0)
                        lastMeal = DateTime.parse(
                            cookingFileContents['history'].keys.toList().last);
                    }
                    Map<String, double> eatingOutFileContents = {};
                    eatingOutFile
                        .writeAsStringSync(jsonEncode(eatingOutFileContents));
                    eatingOutData.changeLastMeal(
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
                File eatingOutFile =
                    File('${snapshot.data.path}/eatingOutData.json');
                if (!eatingOutFile.existsSync()) return SizedBox();
                Map<String, dynamic> eatingOutFileContents =
                    jsonDecode(eatingOutFile.readAsStringSync());
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
                        for (String i in eatingOutFileContents.keys)
                          Text('$i: ${eatingOutFileContents[i]}'),
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
