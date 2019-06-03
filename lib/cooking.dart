import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'sliderTheme.dart';
import 'eatingOut.dart';
import 'editRecipe.dart';

const Color kCookingColor1 = Color(0xFF56AB2F);
const Color kCookingColor2 = Color(0xFFA8E063);
const List<Map<String, dynamic>> friedRiceRecipe = [
  {
    'name': 'butter',
    'value': 0.5,
    'unit': 'tablespoon',
  },
  {
    'name': 'chopped onions',
    'value': 0.5,
    'unit': 'cup',
  },
  {
    'name': 'clove garlic, minced',
    'value': 1,
    'unit': '',
  },
  {
    'name': 'cooked rice',
    'value': 190,
    'unit': 'g',
  },
  {
    'name': 'large egg',
    'value': 1,
    'unit': '',
  },
  {
    'name': 'peas',
    'value': 0.5,
    'unit': 'cup',
  },
  {
    'name': 'corn',
    'value': 0.5,
    'unit': 'cup',
  },
  {
    'name': 'soy sauce',
    'value': 1,
    'unit': 'tablespoon',
  },
];

class CookingData extends ChangeNotifier {
  CookingData();
  double _ratio = 1;
  double _hunger = 0;
  double _feedback = 0.5;
  Map<String, dynamic> _suggestions = {};
  Map<String, dynamic> _recipes = {
    'Fried Rice': friedRiceRecipe,
  };

  void resetData() {
    _hunger = 0;
    _feedback = 0.5;
    _suggestions = {};
    notifyListeners();
  }

  void changeRecipes(Map<String, dynamic> newRecipes) {
    _recipes = newRecipes;
    notifyListeners();
  }

  void changeSuggestions(Map<String, dynamic> newSuggestions) {
    _suggestions = newSuggestions;
    notifyListeners();
  }

  void changeHunger(double newHunger) {
    _hunger = newHunger;
    notifyListeners();
  }

  void changeFeedback(double newFeedback) {
    _feedback = newFeedback;
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
      changeRatio(_ratio + 0.2 - _feedback * 0.4);
      cookingFileContents['ratio'] = double.parse(_ratio.toStringAsFixed(1));
      cookingFileContents['history'][DateTime.now().toString()] = {
        'hunger': _hunger,
        'suggestions': _suggestions,
        'feedback': _feedback,
      };
      cookingFile.writeAsStringSync(jsonEncode(cookingFileContents));
    });
  }

  double get ratio => _ratio;
  double get hunger => _hunger;
  double get feedback => _feedback;
  Map<String, dynamic> get suggestions => _suggestions;
  Map<String, dynamic> get recipes => _recipes;
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
    nextDisabled = currentPage == 0 && cookingData.hunger == 0.0 ||
        currentPage == 1 && cookingData.suggestions.length == 0;
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
                                Provider.of<EatingOutData>(context)
                                    .changeLastMeal(DateTime.now());
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
    double hungerValue = cookingData.hunger;
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
                    cookingData.changeHunger(newValue);
                    final Map<String, dynamic> suggestions =
                        cookingData.suggestions;
                    if (suggestions.length > 0) {
                      final String dishName = suggestions.keys.toList()[0];
                      final List<dynamic> ingredients =
                          cookingData.recipes[dishName];
                      final List<dynamic> updatedIngredients =
                          ingredients.map((item) {
                        num newIngredientValue = num.parse(
                            (item['value'] * newValue * cookingData.ratio)
                                .toStringAsFixed(2)); // * ratio
                        return {
                          'name': item['name'],
                          'value': newIngredientValue,
                          'unit': item['unit'],
                        };
                      }).toList();
                      cookingData
                          .changeSuggestions({dishName: updatedIngredients});
                    }
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
    final Map<String, dynamic> recipes = cookingData.recipes;
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
            padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
            alignment: Alignment.center,
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                for (String dishName in recipes.keys)
                  DishButton(
                    dishName: dishName,
                  ),
                OutlineButton(
                  highlightedBorderColor: Colors.lightGreenAccent,
                  borderSide: BorderSide(
                    color: Theme.of(context).disabledColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      Container(
                        height: 48.0,
                        padding: EdgeInsets.only(left: 8),
                        alignment: Alignment.center,
                        child: Text(
                          'Add Dish',
                          style: Theme.of(context).textTheme.subhead.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DishButton extends StatefulWidget {
  final String dishName;
  const DishButton({@required this.dishName});

  @override
  _DishButtonState createState() => _DishButtonState();
}

class _DishButtonState extends State<DishButton> {
  bool buttonPressed = false;
  @override
  Widget build(BuildContext context) {
    CookingData cookingData = Provider.of<CookingData>(context);
    final Map<String, dynamic> recipes = cookingData.recipes;
    Map<String, dynamic> suggestions = cookingData.suggestions;
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        border: Border.all(
          color: buttonPressed
              ? Colors.lightGreenAccent
              : Theme.of(context).disabledColor,
        ),
        color: suggestions.containsKey(widget.dishName)
            ? Colors.white
            : Colors.white.withOpacity(0),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: ButtonTheme(
          colorScheme: suggestions.containsKey(widget.dishName)
              ? ColorScheme.light()
              : ColorScheme.dark(),
          child: InkWell(
            borderRadius: BorderRadius.circular(6.0),
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.subhead.copyWith(
                      color: suggestions.containsKey(widget.dishName)
                          ? Colors.green
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                child: Text(widget.dishName),
              ),
            ),
            onLongPress: () {
              showGeneralDialog(
                barrierLabel: 'Dismiss',
                barrierDismissible: true,
                transitionDuration: Duration(milliseconds: 200),
                barrierColor: Colors.black.withOpacity(0.5),
                context: context,
                transitionBuilder: (context, anim1, anim2, child) =>
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: anim1,
                        curve: Interval(0, 0.5),
                      ),
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.5,
                          end: 1,
                        ).animate(CurvedAnimation(
                          parent: anim1,
                          curve: Curves.fastLinearToSlowEaseIn,
                        )),
                        child: child,
                      ),
                    ),
                pageBuilder: (context, anim1, anim2) => Theme(
                      data: ThemeData.light(),
                      child: Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.dishName,
                                style: Theme.of(context)
                                    .textTheme
                                    .display1
                                    .copyWith(
                                      color: kCookingColor1,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                'Ingredients',
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(
                                      fontSize: 18,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              for (dynamic ingredient
                                  in recipes[widget.dishName])
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    '${ingredient['value']} ${ingredient['unit']}${ingredient['unit'] == '' ? '' : ' of '}${ingredient['name']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subhead
                                        .copyWith(
                                          fontSize: 18,
                                          color: Colors.black87,
                                        ),
                                  ),
                                ),
                              const SizedBox(
                                height: 8,
                              ),
                              OutlineButton(
                                highlightedBorderColor: kCookingColor1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Container(
                                  height: 48.0,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.edit,
                                        color: kCookingColor1,
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        'Edit Ingredients',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .copyWith(
                                              color: kCookingColor1,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (_) => EditRecipeScreen(
                                              dishName: widget.dishName,
                                            ),
                                      ));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              );
              setState(() {
                buttonPressed = false;
              });
            },
            onTapCancel: () {
              setState(() {
                buttonPressed = false;
              });
            },
            onTapDown: (_) {
              setState(() {
                buttonPressed = true;
              });
            },
            onTap: () {
              setState(() {
                buttonPressed = false;
              });
              if (suggestions.containsKey(widget.dishName))
                suggestions = {};
              else {
                final List<dynamic> ingredients = recipes[widget.dishName];
                final List<dynamic> updatedIngredients =
                    ingredients.map((item) {
                  num newIngredientValue = num.parse(
                      (item['value'] * cookingData.hunger * cookingData.ratio)
                          .toStringAsFixed(2));
                  return {
                    'name': item['name'],
                    'value': newIngredientValue,
                    'unit': item['unit'],
                  };
                }).toList();
                suggestions = {widget.dishName: updatedIngredients};
              }
              cookingData.changeSuggestions(suggestions);
            },
          ),
        ),
      ),
    );
  }
}

class CookingThirdScreen extends StatelessWidget {
  const CookingThirdScreen();
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> suggestions =
        Provider.of<CookingData>(context).suggestions;
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
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (suggestions.length > 0)
                  for (dynamic ingredient in suggestions.values.toList()[0])
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '${ingredient['value']} ${ingredient['unit']}${ingredient['unit'] == '' ? '' : ' of '}${ingredient['name']}',
                        style: Theme.of(context).textTheme.display1.copyWith(
                              height: 0.8,
                              fontSize: 24,
                              color: Colors.white,
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
    double feedbackValue = cookingData.feedback;
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
                    cookingData.changeFeedback(newValue);
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
