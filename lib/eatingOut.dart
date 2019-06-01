import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'cooking.dart';

class EatingOutData extends ChangeNotifier {
  EatingOutData();
  DateTime _lastMeal = DateTime.now().subtract(Duration(hours: 6));
  void changeLastMeal(DateTime newTime) {
    _lastMeal = newTime;
    notifyListeners();
  }

  void saveData() {
    getApplicationDocumentsDirectory().then((dir) {
      File eatingOutFile = File('${dir.path}/eatingOutData.json');
      Map<String, dynamic> eatingOutFileContents =
          jsonDecode(eatingOutFile.readAsStringSync());
      eatingOutFileContents[DateTime.now().toString()] = servingSize;
      eatingOutFile.writeAsStringSync(jsonEncode(eatingOutFileContents));
    });
  }

  DateTime get lastMeal => _lastMeal;
  // Linear eqn, 6h = 360mins = serving size of 1.0
  double get servingSize =>
      double.parse((DateTime.now().difference(_lastMeal).inMinutes / 360)
          .toStringAsFixed(2));
}

class EatingOutScreen extends StatefulWidget {
  final BottomRowBuilder bottomRowBuilder;
  final AnimationController animationController;
  final bool showEatingOutScreen;
  EatingOutScreen({
    @required this.bottomRowBuilder,
    @required this.animationController,
    @required this.showEatingOutScreen,
  });
  @override
  _EatingOutScreenState createState() => _EatingOutScreenState();
}

class _EatingOutScreenState extends State<EatingOutScreen> {
  PageController pageController = PageController();
  int currentPage = 0;
  bool savingData = false;

  void onDataSave(AnimationStatus status) {
    EatingOutData eatingOutData = Provider.of<EatingOutData>(context);
    if (status == AnimationStatus.dismissed) {
      eatingOutData.changeLastMeal(DateTime.now());
      currentPage = 0;
      pageController.jumpToPage(0);
      savingData = false;
      widget.animationController.removeStatusListener(onDataSave);
    }
  }

  @override
  Widget build(BuildContext context) {
    EatingOutData eatingOutData = Provider.of<EatingOutData>(context);
    return Stack(
      children: <Widget>[
        PageView(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            EatingOutFirstScreen(
              animationController: widget.animationController,
              showEatingOutScreen: widget.showEatingOutScreen,
            ),
            EatingOutSecondScreen(
              animationController: widget.animationController,
              showEatingOutScreen: widget.showEatingOutScreen,
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
                    highlightedBorderColor: Colors.amberAccent[200],
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
                    highlightedBorderColor: Colors.amberAccent[200],
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
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                        child: Text(
                          currentPage == 1 ? 'Submit' : 'Next',
                        ),
                      ),
                    ),
                    onPressed: currentPage == 1
                        ? () {
                            widget.animationController
                                .addStatusListener(onDataSave);
                            savingData = true;
                            Navigator.pop(context);
                            Navigator.pop(context);
                            eatingOutData.saveData();
                          }
                        : () {
                            if (currentPage != 1) {
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

class EatingOutFirstScreen extends StatelessWidget {
  final AnimationController animationController;
  final bool showEatingOutScreen;
  const EatingOutFirstScreen({
    @required this.animationController,
    @required this.showEatingOutScreen,
  });

  @override
  Widget build(BuildContext context) {
    EatingOutData eatingOutData = Provider.of<EatingOutData>(context);
    Duration timeElapsed = DateTime.now().difference(eatingOutData.lastMeal);
    String timePassed = timeElapsed.inHours == 0
        ? '${timeElapsed.inMinutes} min' +
            (timeElapsed.inMinutes == 1 ? '' : 's')
        : '${timeElapsed.inHours} hour' +
            (timeElapsed.inHours == 1 ? '' : 's');
    final double windowHeight = MediaQuery.of(context).size.height;
    Tween<Offset> offsetTween2 = Tween<Offset>(
      begin: Offset(0, windowHeight),
      end: Offset(0, 0),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0,
          MediaQuery.of(context).padding.bottom + 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Transform.translate(
            offset: showEatingOutScreen
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
                'Time passed since last meal:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.display2.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
          Transform.translate(
            offset: showEatingOutScreen
                ? offsetTween2
                    .animate(CurvedAnimation(
                      curve: Interval(0.4, 0.9, curve: Curves.easeInOut),
                      parent: animationController,
                    ))
                    .value
                : Offset(0, windowHeight),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 10),
              alignment: Alignment.center,
              child: Text(
                timePassed,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.display3.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EatingOutSecondScreen extends StatelessWidget {
  final AnimationController animationController;
  final bool showEatingOutScreen;
  const EatingOutSecondScreen({
    @required this.animationController,
    @required this.showEatingOutScreen,
  });

  @override
  Widget build(BuildContext context) {
    EatingOutData eatingOutData = Provider.of<EatingOutData>(context);
    final double windowHeight = MediaQuery.of(context).size.height;
    Tween<Offset> offsetTween2 = Tween<Offset>(
      begin: Offset(0, windowHeight),
      end: Offset(0, 0),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0,
          MediaQuery.of(context).padding.bottom + 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Transform.translate(
            offset: showEatingOutScreen
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
                'Recommended serving size:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.display2.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
          Transform.translate(
            offset: showEatingOutScreen
                ? offsetTween2
                    .animate(CurvedAnimation(
                      curve: Interval(0.4, 0.9, curve: Curves.easeInOut),
                      parent: animationController,
                    ))
                    .value
                : Offset(0, windowHeight),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 10),
              alignment: Alignment.center,
              child: Text(
                eatingOutData.servingSize.toStringAsFixed(2),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.display3.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
