// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_category_picker.dart';

void main() {
  timeDilation = 1.0;
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: ExampleApp(),
      ),
    ),
  );
}

class Fruit implements Comparable<Fruit> {
  const Fruit(this.name);
  final String name;

  @override
  int compareTo(Fruit other) => name.compareTo(other.name);

  @override
  String toString() => name;
}

class FruitCategory extends SmoothCategory<Fruit> {
  FruitCategory(Fruit value, [Iterable<FruitCategory>? children])
      : children = children?.toSet() ?? <FruitCategory>{},
        super(value);

  Set<FruitCategory> children;

  @override
  void addChild(FruitCategory newChild) => children.add(newChild);

  @override
  Future<FruitCategory?> getChild(Fruit childValue) async {
    return await super.getChild(childValue) as FruitCategory?;
  }

  @override
  String getLabel(OpenFoodFactsLanguage language) => value.name;

  @override
  Stream<SmoothCategory<Fruit>> getChildren() async* {
    for (final SmoothCategory<Fruit> child in children) {
      yield child;
    }
  }

  @override
  Stream<SmoothCategory<Fruit>> getParents() async* {}
}

FruitCategory categories = FruitCategory(
  const Fruit('fruit'),
  <FruitCategory>{
    FruitCategory(
      const Fruit('apple'),
      <FruitCategory>{
        FruitCategory(
          const Fruit('red'),
          <FruitCategory>[
            FruitCategory(const Fruit('Red Delicious')),
            FruitCategory(const Fruit('Fuji')),
            FruitCategory(const Fruit('Crispin')),
            FruitCategory(const Fruit('Pink Lady')),
          ],
        ),
        FruitCategory(
          const Fruit('yellow'),
          <FruitCategory>[
            FruitCategory(const Fruit('Yellow Delicious')),
            FruitCategory(const Fruit('Ginger Gold')),
          ],
        ),
        FruitCategory(
          const Fruit('green'),
          <FruitCategory>[
            FruitCategory(const Fruit('Granny Smith')),
          ],
        ),
      },
    ),
    FruitCategory(
      const Fruit('berry'),
      <FruitCategory>{
        FruitCategory(const Fruit('blueberry')),
        FruitCategory(const Fruit('raspberry')),
      },
    ),
  },
);

Future<FruitCategory?> getCategory(Iterable<Fruit> path) async {
  if (path.isEmpty) {
    return null;
  }
  FruitCategory? result = categories.value == path.first ? categories : null;
  final List<Fruit> followPath = path.skip(1).toList();
  while (result != null && followPath.isNotEmpty) {
    result = await result.getChild(followPath.first);
    followPath.removeAt(0);
  }
  return result;
}

class ExampleApp extends StatefulWidget {
  const ExampleApp();

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  Set<Fruit> currentCategories = <Fruit>{
    const Fruit('raspberry'),
    const Fruit('Fuji')
  };
  List<Fruit> currentCategoryPath = <Fruit>[
    const Fruit('fruit'),
    const Fruit('apple'),
  ];

  Widget _addCategoryDialog(BuildContext context, FruitCategory parent) {
    final TextEditingController controller = TextEditingController();
    void addCategory(String name) {
      Navigator.of(context)
          .pop(name.isNotEmpty ? FruitCategory(Fruit(name)) : null);
    }

    return AlertDialog(
      content: TextField(
        autofocus: true,
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Enter new category name',
        ),
        onSubmitted: addCategory,
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () => addCategory(controller.text),
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        backgroundColor: Colors.lightGreenAccent,
        canvasColor: Colors.lightGreenAccent,
        scaffoldBackgroundColor: Colors.lightGreenAccent,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.green,
          foregroundColor: Colors.black,
        ),
        checkboxTheme: CheckboxTheme.of(context).copyWith(
          fillColor:
              MaterialStateColor.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.green;
            }
            return Colors.black38;
          }),
        ),
        chipTheme:
            ChipTheme.of(context).copyWith(backgroundColor: Colors.green),
      ),
      child: Scaffold(
        body: SmoothCategoryPicker<Fruit>(
          categoryFinder: getCategory,
          currentPath: currentCategoryPath,
          currentCategories: currentCategories,
          onCategoriesChanged: (Set<Fruit> value) {
            setState(() {
              currentCategories = value;
            });
          },
          onPathChanged: (Iterable<Fruit> path) {
            setState(() {
              currentCategoryPath = path.toList();
            });
          },
          onAddCategory: (Iterable<Fruit> path) {
            getCategory(path).then((FruitCategory? currentCategory) {
              if (currentCategory != null) {
                showDialog<FruitCategory>(
                        builder: (BuildContext context) =>
                            _addCategoryDialog(context, currentCategory),
                        context: context)
                    .then<void>((FruitCategory? category) {
                  if (category != null) {
                    setState(() {
                      // Remove the parent from the set of assigned categories,
                      // since it isn't a leaf anymore.
                      currentCategories.remove(currentCategory.value);
                      currentCategory.addChild(category);
                      // If they added a new category, they must mean that the
                      // category applies.
                      currentCategories.add(category.value);
                    });
                  }
                });
              }
            });
          },
        ),
      ),
    );
  }
}
