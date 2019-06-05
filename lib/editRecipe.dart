import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cooking.dart';

class EditRecipeData extends ChangeNotifier {
  EditRecipeData();
  String _name = '';
  List<Map<String, dynamic>> _recipe = [
    {
      'name': '',
      'value': null,
      'unit': '',
    },
    {
      'name': 'E',
      'value': 1,
      'unit': '',
      'removed': 'well yes but actually no',
    }
  ];

  void resetData() {
    _name = '';
    _recipe = [
      {
        'name': '',
        'value': null,
        'unit': '',
      },
      {
        'name': 'E',
        'value': 1,
        'unit': '',
        'removed': 'well yes but actually no',
      }
    ];
    notifyListeners();
  }

  void addAllIngredients(List<Map<String, dynamic>> allIngredients) {
    _recipe = allIngredients;
    _recipe += [
      {
        'name': 'E',
        'value': 1,
        'unit': '',
        'removed': 'well yes but actually no',
      }
    ];
    notifyListeners();
  }

  void changeName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void addIngredient() {
    _recipe.last = {
      'name': '',
      'value': null,
      'unit': '',
    };
    _recipe += [
      {
        'name': 'E',
        'value': 1,
        'unit': '',
        'removed': 'well yes but actually no',
      }
    ];
    notifyListeners();
  }

  void removeIngredient(int index) {
    _recipe[index] = {
      'name': 'E',
      'value': 1,
      'unit': '',
      'removed': 'well yes but actually no',
    };
    notifyListeners();
  }

  void editIngredient(int index, Map<String, dynamic> newIngredient) {
    _recipe[index] = newIngredient;
    notifyListeners();
  }

  String get name => _name;
  List<Map<String, dynamic>> get recipe => _recipe;
}

class EditRecipeScreen extends StatefulWidget {
  final String dishName;
  const EditRecipeScreen({this.dishName});

  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  InputDecoration inputDecoration(String labelText) => InputDecoration(
        errorStyle: const TextStyle(
          height: 0,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Kayak Sans',
          fontSize: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.black26,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[200],
      );

  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    CookingData cookingData = Provider.of<CookingData>(context);
    EditRecipeData editRecipeData = Provider.of<EditRecipeData>(context);
    List<Map<String, dynamic>> ingredients = editRecipeData.recipe;
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: kCookingColor1,
      ),
      child: Form(
        key: formKey,
        onChanged: () {
          FormState state = formKey.currentState;
          if (state.validate()) state.save();
        },
        onWillPop: () async {
          List<Map<String, dynamic>> sortedIngredients = [];
          for (var ingredient in ingredients) {
            if (!ingredient.containsKey('removed'))
              sortedIngredients.add(ingredient);
          }
          if (widget.dishName == null ||
              !cookingData.recipes.containsKey(editRecipeData.name) ||
              cookingData.recipes[editRecipeData.name].toString() !=
                  sortedIngredients.toString()) {
            bool value = await showGeneralDialog<bool>(
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
                    data: ThemeData.light().copyWith(
                      primaryColor: kCookingColor1,
                      accentColor: kCookingColor1,
                    ),
                    child: AlertDialog(
                      titleTextStyle: const TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Kayak Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 21.0,
                      ),
                      contentTextStyle: const TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Kayak Sans',
                        fontSize: 17.0,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text('Are you sure you want to exit?'),
                      content: Text('Your changes have not been saved.'),
                      actions: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              OutlineButton(
                                highlightColor: Colors.black12,
                                splashColor: Colors.black12,
                                highlightedBorderColor: kCookingColor1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Container(
                                  height: 40.0,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'No',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subhead
                                        .copyWith(
                                          color: kCookingColor1,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              OutlineButton(
                                highlightColor: Colors.black12,
                                splashColor: Colors.black12,
                                highlightedBorderColor: kCookingColor1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Container(
                                  height: 40.0,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Yes',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subhead
                                        .copyWith(
                                          color: kCookingColor1,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            );
            return Future.value(value ?? false);
          } else
            return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.dishName != null
                  ? 'Edit ${widget.dishName} Dish'
                  : 'Add Dish',
              style: Theme.of(context).textTheme.title.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  bool value = await showGeneralDialog<bool>(
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
                          data: ThemeData.light().copyWith(
                            primaryColor: kCookingColor1,
                            accentColor: kCookingColor1,
                          ),
                          child: AlertDialog(
                            titleTextStyle: const TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Kayak Sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 21.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(
                                'Delete ${widget.dishName ?? 'new'} dish?'),
                            actions: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    OutlineButton(
                                      highlightColor: Colors.black12,
                                      splashColor: Colors.black12,
                                      highlightedBorderColor: kCookingColor1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                      child: Container(
                                        height: 40.0,
                                        alignment: Alignment.center,
                                        child: Text(
                                          'No',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .copyWith(
                                                color: kCookingColor1,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    OutlineButton(
                                      highlightColor: Colors.black12,
                                      splashColor: Colors.black12,
                                      highlightedBorderColor: kCookingColor1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                      child: Container(
                                        height: 40.0,
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Yes',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .copyWith(
                                                color: kCookingColor1,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                  );
                  if (value != null && value) {
                    String oldName = widget.dishName;
                    CookingData cookingData = Provider.of<CookingData>(context);
                    Map<String, dynamic> recipes = cookingData.recipes;
                    Map<String, dynamic> suggestions = cookingData.suggestions;
                    recipes.remove(oldName);
                    cookingData.changeRecipes(recipes);
                    if (suggestions.containsKey(oldName))
                      cookingData.changeSuggestions({});
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: DefaultTextStyle(
              style: TextStyle(
                color: Colors.black87,
                fontFamily: 'Kayak Sans',
                fontSize: 18,
              ),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      64,
                ),
                padding: EdgeInsets.fromLTRB(
                    16, 16, 0, MediaQuery.of(context).padding.bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: TextFormField(
                            initialValue: widget.dishName ?? '',
                            cursorColor: kCookingColor1,
                            style: const TextStyle(
                              fontFamily: 'Kayak Sans',
                              fontSize: 18,
                            ),
                            decoration: inputDecoration('Name of dish'),
                            onSaved: (text) {
                              editRecipeData.changeName(text);
                            },
                            validator: (text) {
                              if (text.isEmpty) return '';
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Ingredients',
                          style: Theme.of(context).textTheme.subhead.copyWith(
                                fontSize: 18,
                                color: Color.lerp(
                                    Colors.black87, kCookingColor1, 0.1),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        if (ingredients.length > 0)
                          for (int i = 0; i < ingredients.length; i++)
                            AnimatedContainer(
                              curve: Curves.easeInOutCubic,
                              duration: Duration(milliseconds: 200),
                              height: ingredients[i].containsKey('removed')
                                  ? 0
                                  : 66,
                              alignment: Alignment.topCenter,
                              transform: Matrix4.translationValues(
                                  0,
                                  ingredients[i].containsKey('removed')
                                      ? -20
                                      : 0,
                                  0),
                              child: AnimatedOpacity(
                                opacity: ingredients[i].containsKey('removed')
                                    ? 0
                                    : 1,
                                duration: Duration(
                                    milliseconds:
                                        ingredients[i].containsKey('removed')
                                            ? 150
                                            : 200),
                                child: ClipRect(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: IngredientRow(
                                      index: i,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        const SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: OutlineButton(
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
                                    Icons.add,
                                    color: kCookingColor1,
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    'Add Ingredient',
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
                            onPressed: editRecipeData.addIngredient,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            child: OutlineButton(
                              highlightedBorderColor: kCookingColor1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                child: Text(
                                  'Cancel',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subhead
                                      .copyWith(
                                        color: kCookingColor1,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.maybePop(context);
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Builder(builder: (context) {
                              return FlatButton(
                                colorBrightness: Brightness.dark,
                                color: kCookingColor1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Save',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Kayak Sans',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (!formKey.currentState.validate())
                                    return;
                                  else
                                    formKey.currentState.save();
                                  List<Map<String, dynamic>> sortedIngredients =
                                      [];
                                  for (var ingredient in ingredients) {
                                    if (!ingredient.containsKey('removed'))
                                      sortedIngredients.add(ingredient);
                                  }
                                  if (sortedIngredients.length == 0) {
                                    Scaffold.of(context).hideCurrentSnackBar();
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                          'Your dish must have ingredients!'),
                                      action: SnackBarAction(
                                        textColor: kCookingColor2,
                                        label: 'OK',
                                        onPressed: () => Scaffold.of(context)
                                            .hideCurrentSnackBar(),
                                      ),
                                    ));
                                    return;
                                  }
                                  String oldName = widget.dishName;
                                  String newName = editRecipeData.name;
                                  CookingData cookingData =
                                      Provider.of<CookingData>(context);
                                  Map<String, dynamic> recipes =
                                      cookingData.recipes;
                                  Map<String, dynamic> suggestions =
                                      cookingData.suggestions;
                                  recipes.remove(oldName);
                                  recipes.addAll({
                                    newName: sortedIngredients,
                                  });
                                  cookingData.changeRecipes(recipes);
                                  if (suggestions.containsKey(oldName)) {
                                    final List<dynamic> updatedIngredients =
                                        sortedIngredients.map((item) {
                                      num newIngredientValue = num.parse(
                                          (item['value'] *
                                                  cookingData.hunger *
                                                  cookingData.ratio)
                                              .toStringAsFixed(2));
                                      return {
                                        'name': item['name'],
                                        'value': newIngredientValue,
                                        'unit': item['unit'],
                                      };
                                    }).toList();
                                    cookingData.changeSuggestions({
                                      newName: updatedIngredients,
                                    });
                                  }
                                  Navigator.of(context).pop();
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IngredientRow extends StatefulWidget {
  final int index;
  const IngredientRow({this.index});

  @override
  _IngredientRowState createState() => _IngredientRowState();
}

class _IngredientRowState extends State<IngredientRow> {
  String name;
  num value;
  String unit;
  InputDecoration inputDecoration(String labelText) => InputDecoration(
        errorStyle: const TextStyle(
          height: 0,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Kayak Sans',
          fontSize: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.black26,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[200],
      );

  @override
  Widget build(BuildContext context) {
    EditRecipeData editRecipeData = Provider.of<EditRecipeData>(context);
    Map<String, dynamic> ingredient = editRecipeData.recipe[widget.index];
    if (ingredient.containsKey('removed') &&
        widget.index == editRecipeData.recipe.length - 1) return SizedBox();
    return Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: TextFormField(
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
            ),
            initialValue: ingredient['value']?.toString() ?? '',
            cursorColor: kCookingColor1,
            style: const TextStyle(
              fontFamily: 'Kayak Sans',
            ),
            decoration: inputDecoration('Amount'),
            validator: (value) {
              if (ingredient.containsKey('removed')) return null;
              if (value.isEmpty ||
                  num.tryParse(value) == null ||
                  num.parse(value) <= 0) return '';
            },
            onSaved: (text) {
              if (ingredient.containsKey('removed')) return;
              value = num.parse(text);
              editRecipeData.editIngredient(widget.index, {
                'name': name ?? ingredient['name'],
                'value': value,
                'unit': unit ?? ingredient['unit'],
              });
            },
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 4,
          child: TextFormField(
            initialValue: ingredient['unit'],
            cursorColor: kCookingColor1,
            style: const TextStyle(
              fontFamily: 'Kayak Sans',
            ),
            decoration: inputDecoration('Units'),
            onSaved: (text) {
              if (ingredient.containsKey('removed')) return;
              unit = text;
              editRecipeData.editIngredient(widget.index, {
                'name': name ?? ingredient['name'],
                'value': value ?? ingredient['value'],
                'unit': unit,
              });
            },
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 7,
          child: TextFormField(
            initialValue: ingredient['name'],
            cursorColor: kCookingColor1,
            style: const TextStyle(
              fontFamily: 'Kayak Sans',
            ),
            decoration: inputDecoration('Name'),
            validator: (name) {
              if (ingredient.containsKey('removed')) return null;
              if (name.isEmpty) return '';
            },
            onSaved: (text) {
              if (ingredient.containsKey('removed')) return;
              name = text;
              editRecipeData.editIngredient(widget.index, {
                'name': name,
                'value': value ?? ingredient['value'],
                'unit': unit ?? ingredient['unit'],
              });
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => editRecipeData.removeIngredient(widget.index),
        ),
      ],
    );
  }
}
