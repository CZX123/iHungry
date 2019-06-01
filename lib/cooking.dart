import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'sliderTheme.dart';
import 'eatingOut.dart';

const Color kCookingColor1 = Color(0xFF3498DB);
const Color kCookingColor2 = Color(0xFF2C3E50);
const List<String> foodGroups = [
  'Food 1',
  'Food 2',
  'Food 3',
  'Food 4',
  'Food 5',
  'Food 6',
];

class CookingData extends ChangeNotifier {
  CookingData();
  double _ratio = 1.0;
  Map<String, dynamic> _data = {
    'hunger': 0.0,
    'suggestions': <String, double>{},
    'feedback': 0.5,
  };

  void resetData() {
    _data = {
      'hunger': 0.0,
      'suggestions': <String, double>{},
      'feedback': 0.5,
    };
    notifyListeners();
  }

  void editData(String key, dynamic value) {
    _data.addAll({key: value});
    notifyListeners();
  }

  void changeRatio(double newRatio) {
    _ratio = newRatio;
    notifyListeners();
  }

  void saveData() {
    getApplicationDocumentsDirectory().then((dir) {
      File cookingFile = File('${dir.path}/cookingData.json');
      Map<String, dynamic> cookingFileContents =
          jsonDecode(cookingFile.readAsStringSync());
      changeRatio(_ratio + 0.2 - _data['feedback'] * 0.4);
      cookingFileContents['ratio'] = double.parse(_ratio.toStringAsFixed(1));
      cookingFileContents['history'][DateTime.now().toString()] = _data;
      cookingFile.writeAsStringSync(jsonEncode(cookingFileContents));
    });
  }

  Map<String, dynamic> get data => _data;
  double get ratio => _ratio;
}

typedef Widget BottomRowBuilder(Widget row);

class CookingScreen extends StatefulWidget {
  final BottomRowBuilder bottomRowBuilder;
  final AnimationController animationController;
  final bool showCookingScreen;
  CookingScreen({
    @required this.bottomRowBuilder,
    @required this.animationController,
    @required this.showCookingScreen,
  });

  @override
  _CookingScreenState createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  PageController pageController = PageController();
  int currentPage = 0;
  bool nextDisabled = true;
  bool savingData = false;

  void onDataSave(AnimationStatus status) {
    CookingData cookingData = Provider.of<CookingData>(context);
    if (status == AnimationStatus.dismissed) {
      cookingData.resetData();
      currentPage = 0;
      pageController.jumpToPage(0);
      savingData = false;
      widget.animationController.removeStatusListener(onDataSave);
    }
  }

  @override
  Widget build(BuildContext context) {
    CookingData cookingData = Provider.of<CookingData>(context);
    nextDisabled = currentPage == 0 && cookingData.data['hunger'] == 0.0 ||
        currentPage == 1 && cookingData.data['suggestions'].length == 0;
    return Stack(
      children: <Widget>[
        PageView(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            CookingFirstScreen(
              animationController: widget.animationController,
              showCookingScreen: widget.showCookingScreen,
            ),
            const CookingSecondScreen(),
            const CookingThirdScreen(),
            CookingFourthScreen(
              animationController: widget.animationController,
              showCookingScreen: widget.showCookingScreen,
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).padding.bottom,
          height: 96,
          child: widget.bottomRowBuilder(
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 24,
                ),
                Expanded(
                  child: OutlineButton(
                    highlightedBorderColor: Colors.lightGreenAccent,
                    borderSide: BorderSide(
                      color: Theme.of(context).disabledColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Container(
                      height: 48.0,
                      alignment: Alignment.center,
                      child: Text(
                        'Previous',
                        style: Theme.of(context).textTheme.subhead.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(
                  width: 24,
                ),
                Expanded(
                  child: OutlineButton(
                    highlightedBorderColor: Colors.lightGreenAccent,
                    borderSide: BorderSide(
                      color: Theme.of(context).disabledColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Container(
                      height: 48.0,
                      alignment: Alignment.center,
                      child: AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 200),
                        style: Theme.of(context).textTheme.subhead.copyWith(
                              color: nextDisabled
                                  ? Theme.of(context).disabledColor
                                  : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                        child: Text(
                          currentPage == 3 ? 'Submit' : 'Next',
                        ),
                      ),
                    ),
                    onPressed: nextDisabled
                        ? null
                        : currentPage == 3
                            ? () {
                                widget.animationController
                                    .addStatusListener(onDataSave);
                                savingData = true;
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                cookingData.saveData();
                                Provider.of<EatingOutData>(context).changeLastMeal(DateTime.now());
                              }
                            : () {
                                if (currentPage != 3) {
                                  currentPage += 1;
                                  ModalRoute.of(context)
                                      .addLocalHistoryEntry(LocalHistoryEntry(
                                    onRemove: () {
                                      if (!savingData) {
                                        pageController.previousPage(
                                          duration: Duration(milliseconds: 200),
                                          curve: Curves.easeInOut,
                                        );
                                        currentPage -= 1;
                                        setState(() {});
                                      }
                                    },
                                  ));
                                }
                                pageController.nextPage(
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                );
                                setState(() {});
                              },
                  ),
                ),
                const SizedBox(
                  width: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CookingFirstScreen extends StatelessWidget {
  final AnimationController animationController;
  final bool showCookingScreen;
  const CookingFirstScreen({
    @required this.animationController,
    @required this.showCookingScreen,
  });

  @override
  Widget build(BuildContext context) {
    double windowHeight = MediaQuery.of(context).size.height;
    Tween<Offset> offsetTween2 = Tween<Offset>(
      begin: Offset(0, windowHeight),
      end: Offset(0, 0),
    );
    const List<String> hungerLabels = [
      'Not hungry at all',
      'Just a tiny bit',
      'Slightly hungry',
      'Moderately hungry',
      'Very hungry',
      'Starving!'
    ];
    String hungerLabel;
    CookingData cookingData = Provider.of<CookingData>(context);
    double hungerValue = cookingData.data['hunger'];
    switch ((hungerValue * 100).toInt()) {
      case 20:
        hungerLabel = hungerLabels[1];
        break;
      case 40:
        hungerLabel = hungerLabels[2];
        break;
      case 60:
        hungerLabel = hungerLabels[3];
        break;
      case 80:
        hungerLabel = hungerLabels[4];
        break;
      case 100:
        hungerLabel = hungerLabels[5];
        break;
      default:
        hungerLabel = hungerLabels[0];
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0,
          MediaQuery.of(context).padding.bottom + 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Transform.translate(
            offset: showCookingScreen
                ? offsetTween2
                    .animate(CurvedAnimation(
                      curve: Interval(0.3, 0.8, curve: Curves.easeInOut),
                      parent: animationController,
                    ))
                    .value
                : Offset(0, windowHeight),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 10),
              alignment: Alignment.center,
              child: Text(
                'How hungry\nare you?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.display2.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
          Transform.translate(
            offset: showCookingScreen
                ? offsetTween2
                    .animate(CurvedAnimation(
                      curve: Interval(0.4, 0.9, curve: Curves.easeInOut),
                      parent: animationController,
                    ))
                    .value
                : Offset(0, windowHeight),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              child: SliderTheme(
                data: customSliderTheme(context),
                child: Slider(
                  label: hungerLabel,
                  activeColor: Colors.white,
                  value: hungerValue,
                  divisions: 5,
                  onChanged: (newValue) {
                    Map<String, double> suggestions =
                        cookingData.data['suggestions'];
                    suggestions.updateAll((key, value) {
                      return double.parse(
                          (newValue * cookingData.ratio / suggestions.length)
                              .toStringAsFixed(2));
                    });
                    // Reorder the map and sort it by the order in foodGroups
                    Map<String, double> sortedSuggestions = {};
                    for (String i in foodGroups) {
                      if (suggestions.containsKey(i))
                        sortedSuggestions.addAll({i: suggestions[i]});
                    }
                    cookingData.editData('hunger', newValue);
                    cookingData.editData('suggestions', sortedSuggestions);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CookingSecondScreen extends StatelessWidget {
  const CookingSecondScreen();
  @override
  Widget build(BuildContext context) {
    CookingData cookingData = Provider.of<CookingData>(context);
    Map<String, double> suggestions = cookingData.data['suggestions'];
    double foodWidth = (MediaQuery.of(context).size.width - 80) / 3;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0,
          MediaQuery.of(context).padding.bottom + 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 10),
            alignment: Alignment.center,
            child: Text(
              'What do you want to cook?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.display2.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
            alignment: Alignment.center,
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                for (String i in foodGroups)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: suggestions.containsKey(i)
                          ? Colors.white
                          : Colors.white.withOpacity(0),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ButtonTheme(
                        colorScheme: suggestions.containsKey(i)
                            ? ColorScheme.light()
                            : ColorScheme.dark(),
                        child: OutlineButton(
                          padding: EdgeInsets.zero,
                          highlightedBorderColor: Colors.lightGreenAccent,
                          borderSide: BorderSide(
                            color: Theme.of(context).disabledColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Container(
                            height: 64.0,
                            width: foodWidth,
                            alignment: Alignment.center,
                            child: AnimatedDefaultTextStyle(
                              duration: Duration(milliseconds: 200),
                              style:
                                  Theme.of(context).textTheme.subhead.copyWith(
                                        color: suggestions.containsKey(i)
                                            ? Colors.green
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                              child: Text(i),
                            ),
                          ),
                          onPressed: () {
                            if (suggestions.containsKey(i))
                              suggestions.remove(i);
                            else
                              suggestions.addAll({i: 0.0});
                            suggestions.updateAll((key, value) {
                              return double.parse((cookingData.data['hunger'] *
                                      cookingData.ratio /
                                      suggestions.length)
                                  .toStringAsFixed(2));
                            });
                            // Reorder the map and sort it by the order in foodGroups
                            Map<String, double> sortedSuggestions = {};
                            for (String i in foodGroups) {
                              if (suggestions.containsKey(i))
                                sortedSuggestions.addAll({i: suggestions[i]});
                            }
                            cookingData.editData(
                                'suggestions', sortedSuggestions);
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CookingThirdScreen extends StatelessWidget {
  const CookingThirdScreen();
  @override
  Widget build(BuildContext context) {
    Map<String, double> foodSuggestions =
        Provider.of<CookingData>(context).data['suggestions'];
    return Padding(
      padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0,
          MediaQuery.of(context).padding.bottom + 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 10),
            alignment: Alignment.center,
            child: Text(
              "Here's how much you should eat:",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.display2.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                for (String i in foodSuggestions.keys)
                  Text(
                    // Edit the equation here
                    '${foodSuggestions[i]} servings of $i',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.display1.copyWith(
                          height: 1.2,
                          fontSize: 28,
                          color: Colors.white,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CookingFourthScreen extends StatelessWidget {
  final AnimationController animationController;
  final bool showCookingScreen;
  const CookingFourthScreen({
    @required this.animationController,
    @required this.showCookingScreen,
  });
  @override
  Widget build(BuildContext context) {
    double windowHeight = MediaQuery.of(context).size.height;
    Tween<Offset> offsetTween2 = Tween<Offset>(
      begin: Offset(0, windowHeight),
      end: Offset(0, 0),
    );
    const List<String> feedbackLabels = [
      'Still starving!',
      'Still can eat more',
      'Just nice!',
      'Slightly too much',
      "I'm bloated!",
    ];
    String feedbackLabel;
    CookingData cookingData = Provider.of<CookingData>(context);
    double feedbackValue = cookingData.data['feedback'];
    switch ((feedbackValue * 100).toInt()) {
      case 25:
        feedbackLabel = feedbackLabels[1];
        break;
      case 50:
        feedbackLabel = feedbackLabels[2];
        break;
      case 75:
        feedbackLabel = feedbackLabels[3];
        break;
      case 100:
        feedbackLabel = feedbackLabels[4];
        break;
      default:
        feedbackLabel = feedbackLabels[0];
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0,
          MediaQuery.of(context).padding.bottom + 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Transform.translate(
            offset: showCookingScreen
                ? offsetTween2
                    .animate(CurvedAnimation(
                      curve: Interval(0.3, 0.8, curve: Curves.easeInOut),
                      parent: animationController,
                    ))
                    .value
                : Offset(0, windowHeight),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 10),
              alignment: Alignment.center,
              child: Text(
                'How full are you after the meal?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.display2.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
          Transform.translate(
            offset: showCookingScreen
                ? offsetTween2
                    .animate(CurvedAnimation(
                      curve: Interval(0.4, 0.9, curve: Curves.easeInOut),
                      parent: animationController,
                    ))
                    .value
                : Offset(0, windowHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SliderTheme(
                data: customSliderTheme(context),
                child: Slider(
                  label: feedbackLabel,
                  activeColor: Colors.white,
                  value: feedbackValue,
                  divisions: 4,
                  onChanged: (newValue) {
                    cookingData.editData('feedback', newValue);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
