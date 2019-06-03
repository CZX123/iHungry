import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'cooking.dart';
import 'eatingOut.dart';
import 'cookingDebug.dart';
import 'eatingOutDebug.dart';

const Color kColor1 = Color(0xFFDA4453);
const Color kColor2 = Color(0xFF89216B);

void main() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (_) => CookingData(),
        ),
        ChangeNotifierProvider(
          builder: (_) => EatingOutData(),
        ),
      ],
      child: MaterialApp(
        title: 'iHungry',
        theme: ThemeData(
          fontFamily: 'Kayak Sans',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.blueGrey[800],
          primarySwatch: Colors.yellow,
        ),
        home: Home(
          windowHeight: 600, //MediaQuery.of(context).size.height,
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  final double windowHeight;
  const Home({@required this.windowHeight});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int homeCode = 0;
  int previousHomeCode = 0;
  AnimationController controller;
  double windowHeight;
  ColorTween color1Tween;
  ColorTween color2Tween;
  Tween<Offset> offsetTween1;
  Tween<Offset> offsetTween2;

  void changeState() {
    setState(() {});
  }

  void changeHomeCode(int newCode) {
    previousHomeCode = homeCode;
    if (newCode == 0)
      controller.reverse();
    else
      controller.forward();
    homeCode = newCode;
  }

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((dir) {
      File cookingFile = File('${dir.path}/cookingData.json');
      File cookingRecipesFile = File('${dir.path}/cookingRecipes.json');
      File eatingOutFile = File('${dir.path}/eatingOutData.json');
      CookingData cookingData = Provider.of<CookingData>(context);
      DateTime lastMeal;
      if (cookingFile.existsSync()) {
        Map<String, dynamic> cookingFileContents =
            jsonDecode(cookingFile.readAsStringSync());
        if (cookingFileContents['history'].length > 0)
          lastMeal =
              DateTime.parse(cookingFileContents['history'].keys.toList().last);
        cookingData.changeRatio(cookingFileContents['ratio']);
      } else {
        Map<String, dynamic> cookingFileContents = {
          'ratio': 1.0,
          'history': {},
        };
        cookingFile.writeAsStringSync(jsonEncode(cookingFileContents));
      }
      if (cookingRecipesFile.existsSync()) {
        Map<String, dynamic> cookingRecipes =
            jsonDecode(cookingRecipesFile.readAsStringSync());
        cookingData.changeRecipes(cookingRecipes);
      } else {
        Map<String, dynamic> cookingRecipes = cookingData.recipes;
        cookingRecipesFile.writeAsStringSync(jsonEncode(cookingRecipes));
      }
      if (eatingOutFile.existsSync()) {
        Map<String, dynamic> eatingOutFileContents =
            jsonDecode(eatingOutFile.readAsStringSync());
        if (eatingOutFileContents.length > 0) {
          DateTime lastOutsideMeal =
              DateTime.parse(eatingOutFileContents.keys.toList().last);
          if (lastMeal == null || lastOutsideMeal.isAfter(lastMeal))
            lastMeal = lastOutsideMeal;
        }
      } else
        eatingOutFile.writeAsStringSync(jsonEncode(<String, dynamic>{}));
      if (lastMeal != null)
        Provider.of<EatingOutData>(context).changeLastMeal(lastMeal);
    });
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    controller.addListener(changeState);
    color1Tween = ColorTween(
      begin: kColor1,
    );
    color2Tween = ColorTween(
      begin: kColor2,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    windowHeight = MediaQuery.of(context).size.height;
    offsetTween1 = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -windowHeight),
    );
    offsetTween2 = Tween<Offset>(
      begin: Offset(0, windowHeight),
      end: Offset(0, 0),
    );
  }

  @override
  void dispose() {
    controller.removeListener(changeState);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showCookingScreen = homeCode == 1 || previousHomeCode == 1;
    final bool showEatingOutScreen = homeCode == 2 || previousHomeCode == 2;
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          children: <Widget>[
            const SizedBox(
              height: 16,
            ),
            ListTile(
              leading: SizedBox(),
              title: Text(
                'Debugging',
                style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.restaurant),
              title: Text(
                'View Cooking Data',
                style: Theme.of(context).textTheme.body1.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CookingDebugScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text(
                'View Eating Out Data',
                style: Theme.of(context).textTheme.body1.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EatingOutDebugScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color1Tween.animate(controller).value,
              color2Tween.animate(controller).value
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + 8,
                    16,
                    MediaQuery.of(context).padding.bottom + 8),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Transform.translate(
                        offset: offsetTween1
                            .animate(CurvedAnimation(
                              curve: Interval(0, 0.5, curve: Curves.easeInOut),
                              parent: controller,
                            ))
                            .value,
                        child: Center(
                          child: Text(
                            'iHungry',
                            style: Theme.of(context).textTheme.display2,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Transform.translate(
                        offset: offsetTween1
                            .animate(CurvedAnimation(
                              curve:
                                  Interval(0.1, 0.6, curve: Curves.easeInOut),
                              parent: controller,
                            ))
                            .value,
                        child: HomeButton(
                          name: 'Cooking',
                          iconData: Icons.restaurant,
                          onPressed: () {
                            color1Tween.end = kCookingColor1;
                            color2Tween.end = kCookingColor2;
                            changeHomeCode(1);
                            ModalRoute.of(context)
                                .addLocalHistoryEntry(LocalHistoryEntry(
                              onRemove: () {
                                changeHomeCode(0);
                              },
                            ));
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Transform.translate(
                        offset: offsetTween1
                            .animate(CurvedAnimation(
                              curve:
                                  Interval(0.2, 0.7, curve: Curves.easeInOut),
                              parent: controller,
                            ))
                            .value,
                        child: HomeButton(
                          name: 'Eating Out',
                          iconData: Icons.fastfood,
                          onPressed: () {
                            color1Tween.end = kEatingOutColor1;
                            color2Tween.end = kEatingOutColor2;
                            changeHomeCode(2);
                            ModalRoute.of(context)
                                .addLocalHistoryEntry(LocalHistoryEntry(
                              onRemove: () {
                                changeHomeCode(0);
                              },
                            ));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                ignoring: homeCode != 1,
                child: CookingScreen(
                  animationController: controller,
                  showCookingScreen: showCookingScreen,
                  bottomRowBuilder: (row) => Transform.translate(
                        offset: showCookingScreen
                            ? offsetTween2
                                .animate(CurvedAnimation(
                                  curve:
                                      Interval(0.5, 1, curve: Curves.easeInOut),
                                  parent: controller,
                                ))
                                .value
                            : Offset(0, windowHeight),
                        child: row,
                      ),
                ),
              ),
              IgnorePointer(
                ignoring: homeCode != 2,
                child: EatingOutScreen(
                  animationController: controller,
                  showEatingOutScreen: showEatingOutScreen,
                  bottomRowBuilder: (row) => Transform.translate(
                        offset: showEatingOutScreen
                            ? offsetTween2
                                .animate(CurvedAnimation(
                                  curve:
                                      Interval(0.5, 1, curve: Curves.easeInOut),
                                  parent: controller,
                                ))
                                .value
                            : Offset(0, windowHeight),
                        child: row,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeButton extends StatefulWidget {
  final String name;
  final IconData iconData;
  final VoidCallback onPressed;
  const HomeButton(
      {@required this.name, @required this.iconData, @required this.onPressed});

  _HomeButtonState createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton> {
  bool buttonPressed = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTapDown: (_) {
            setState(() {
              buttonPressed = true;
            });
          },
          onTapCancel: () {
            setState(() {
              buttonPressed = false;
            });
          },
          onTap: () {
            setState(() {
              buttonPressed = false;
            });
            widget.onPressed();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: Border.all(
                color: buttonPressed
                    ? Colors.pinkAccent[100]
                    : Theme.of(context).disabledColor,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            width: double.infinity,
            child: AnimatedOpacity(
              opacity: buttonPressed ? 1 : 0.54,
              duration: const Duration(milliseconds: 200),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    widget.iconData,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  Text(
                    widget.name,
                    style: Theme.of(context).textTheme.display1.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
