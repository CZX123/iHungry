import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cooking.dart';

typedef void EditIngredient(int position, Map<String, dynamic> newValue);

class EditRecipeScreen extends StatefulWidget {
  final String dishName;
  const EditRecipeScreen({this.dishName});

  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  bool textChanged = false;
  TextEditingController nameController;
  String name;
  dynamic ingredients;
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
  bool autovalidate;

  void firstEdit() {
    setState(() {
      textChanged = true;
    });
  }

  void editIngredient(int position, Map<String, dynamic> newValue) {
    if (newValue == null) {
      setState(() => ingredients.removeAt(position));
      print(ingredients);
    } else if (position < ingredients.length) ingredients[position] = newValue;
  }

  @override
  void initState() {
    super.initState();
    autovalidate = widget.dishName != null;
    name = widget.dishName ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.dishName != null) {
      CookingData cookingData = Provider.of<CookingData>(context);
      List<Map<String, dynamic>> newIngredients = [];
      for (Map<String, dynamic> i in cookingData.recipes[widget.dishName]) {
        newIngredients.add(i);
      }
      ingredients = newIngredients;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: kCookingColor1,
      ),
      child: Form(
        onChanged: firstEdit,
        autovalidate: autovalidate,
        onWillPop: textChanged
            ? () {
                return showGeneralDialog<bool>(
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
                              contentPadding:
                                  EdgeInsets.fromLTRB(24, 20, 24, 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text('Are you sure you want to exit?'),
                              content:
                                  Text('Your changes have not been saved.'),
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
                    ) ??
                    false;
              }
            : null,
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
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                16, 16, 0, MediaQuery.of(context).padding.bottom + 16),
            child: DefaultTextStyle(
              style: TextStyle(
                color: Colors.black87,
                fontFamily: 'Kayak Sans',
                fontSize: 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: TextFormField(
                      cursorColor: kCookingColor1,
                      style: const TextStyle(
                        fontFamily: 'Kayak Sans',
                        fontSize: 18,
                      ),
                      initialValue: widget.dishName,
                      decoration: inputDecoration('Name of dish'),
                      validator: (text) {
                        name = text;
                        if (text.isEmpty) return '';
                        return null;
                      },
                      onEditingComplete: () {
                        setState(() {});
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
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  if (ingredients != null)
                    for (int i = 0; i < ingredients.length; i++)
                      IngredientRow(
                        position: i,
                        editIngredient: editIngredient,
                        ingredients: ingredients,
                        firstEdit: firstEdit,
                      )
                  else
                    IngredientRow(),
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
                              style:
                                  Theme.of(context).textTheme.subhead.copyWith(
                                        color: kCookingColor1,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        ingredients.add({'value': '', 'name': '', 'unit': ''});
                        firstEdit();
                      },
                    ),
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
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: FlatButton(
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
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            onPressed: () {},
                          ),
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
    );
  }
}

class IngredientRow extends StatelessWidget {
  final int position;
  final ingredients;
  final EditIngredient editIngredient;
  final VoidCallback firstEdit;
  const IngredientRow(
      {this.position, this.ingredients, this.editIngredient, this.firstEdit});

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
    Map<String, dynamic> ingredient = ingredients[position];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: TextFormField(
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
              ),
              initialValue: ingredient['value'].toString(),
              cursorColor: kCookingColor1,
              style: const TextStyle(
                fontFamily: 'Kayak Sans',
              ),
              decoration: inputDecoration('Amount'),
              validator: (value) {
                if (value.isEmpty || num.parse(value) == 0) return '';
                ingredient['value'] = num.parse(value);
                editIngredient(position, ingredient);
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
              validator: (unit) {
                ingredient['unit'] = unit;
                editIngredient(position, ingredient);
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
                ingredient['name'] = name;
                editIngredient(position, ingredient);
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              editIngredient(position, null);
            },
          ),
        ],
      ),
    );
  }
}
