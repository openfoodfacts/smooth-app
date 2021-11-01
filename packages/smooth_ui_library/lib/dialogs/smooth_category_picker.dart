// @dart = 2.12

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';

const double _kCategoryHeight = 35.0;
const double _kMaxCategoryWidth = 200.0;

/// A callback used to find information about the category node at the given
/// `categoryPath`.
typedef CategoryPathSelector<T extends Comparable<T>> = Future<SmoothCategory<T>?> Function(
    Iterable<T> categoryPath);

/// A callback used to notify that the visible path in the [SmoothCategoryPicker]
/// has changed to the given path.
typedef CategoryPathChangedCallback<T extends Object> = void Function(Iterable<T> categoryPath);

/// A callback used to notify that the [SmoothCategoryPicker] has requested a new
/// category to be added at the given path.
typedef AddCategoryCallback<T extends Object> = void Function(List<T> path);

/// A callback used by the [SmoothCategoryPicker] to notify that the set of selected
/// categories has changed.
typedef CategoriesChangedCallback<T extends Object> = void Function(Set<T> categories);

/// A Picker for hierarchical categories or other hierarchical data.
///
/// This is a generic widget for displaying and picking categories out of a
/// hierarchy. It allows adding of items, and editing of the selected categories.
///
/// It displays the list of categories at the top as deletable chips, and a
/// breadcrumb display showing the path to the currently displayed category.
///
/// It is designed to allow random access to the categories by requesting
/// information about a category "path" through the [categoryFinder] callback.
///
/// It can then notify of changes in the path through [onPathChanged], the set of
/// selected categories through [onCategoriesChanged], and request a new category to
/// be added.
class SmoothCategoryPicker<T extends Comparable<T>> extends StatefulWidget {
  SmoothCategoryPicker({
    required this.categoryFinder,
    Set<T>? currentCategories,
    required this.currentPath,
    required this.onCategoriesChanged,
    required this.onAddCategory,
    required this.onPathChanged,
    Key? key,
  })  : assert(currentPath.isNotEmpty),
        currentCategories = currentCategories ?? <T>{},
        super(key: key);

  /// The current set of selected categories.
  ///
  /// This set will be reflected in the UI when the parent's category is visited.
  ///
  /// If this set changes, [onCategoriesChanged] will be called.
  final Set<T> currentCategories;

  /// The "path" to the currently displayed category.
  ///
  /// If the user navigates to a different category, [onPathChanged] will be called.
  final List<T> currentPath;

  /// A callback that is called whenever the user requests a new category via the
  /// floating action button in the chooser.
  final AddCategoryCallback<T> onAddCategory;

  /// A callback used to collect information about the current category to be displayed.
  ///
  /// This is called whenever the chooser navigates a new category in order to know
  /// what to display.
  final CategoryPathSelector<T> categoryFinder;

  /// A callback called when the categories list changes.
  final CategoriesChangedCallback<T> onCategoriesChanged;

  /// A callback called when the selected path changes.
  final CategoryPathChangedCallback<T> onPathChanged;

  @override
  State<SmoothCategoryPicker<T>> createState() => _SmoothCategoryPickerState<T>();
}

class _SmoothCategoryPickerState<T extends Comparable<T>> extends State<SmoothCategoryPicker<T>> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SmoothCategory<T>?>(
        future: widget.categoryFinder(widget.currentPath),
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot<SmoothCategory<T>?> snapshot) {
          final SmoothCategory<T>? category = snapshot.data;
          if (category == null) {
            return Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'No Category Found for ${widget.currentPath.map<String>((T item) => item.toString()).join(' > ')}',
                  ),
                  TextButton(child: const Text('BACK'), onPressed: () {
                    widget.onPathChanged(widget.currentPath.sublist(0, widget.currentPath.length - 1));
                  }),
                ],
              ),
            );
          }
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => widget.onAddCategory(widget.currentPath),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SmoothCategoryDisplay<T>(
                    categories: widget.currentCategories,
                    onDeleted: (T item) {
                      widget.onCategoriesChanged(widget.currentCategories.difference(<T>{item}));
                    },
                  ),
                ),
                const Divider(),
                Row(
                  children: <Widget>[
                    IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      icon: const Icon(Icons.chevron_left),
                      onPressed: category.value != widget.currentPath.first
                          ? () {
                              setState(() {
                                widget.onPathChanged(
                                    widget.currentPath.take(widget.currentPath.length - 1));
                              });
                            }
                          : null,
                    ),
                    Text(widget.currentPath.join(' > ')),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: _CategoryView<T>(
                    currentCategories: widget.currentCategories,
                    currentPath: widget.currentPath,
                    categoryFinder: widget.categoryFinder,
                    onPathChanged: widget.onPathChanged,
                    onChanged: widget.onCategoriesChanged,
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class _CategoryView<T extends Comparable<T>> extends StatefulWidget {
  const _CategoryView({
    Key? key,
    required this.currentCategories,
    required this.currentPath,
    required this.onPathChanged,
    required this.onChanged,
    required this.categoryFinder,
  }) : super(key: key);

  final Set<T> currentCategories;
  final List<T> currentPath;
  final CategoriesChangedCallback<T> onChanged;
  final CategoryPathChangedCallback<T> onPathChanged;
  final CategoryPathSelector<T> categoryFinder;

  @override
  State<_CategoryView<T>> createState() => _CategoryViewState<T>();
}

class _CategoryViewState<T extends Comparable<T>> extends State<_CategoryView<T>> {
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.currentPath.length - 1);
  }

  void animateToPage(int page) {
    controller.animateToPage(
      page,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(_CategoryView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPath.length != oldWidget.currentPath.length) {
      animateToPage(widget.currentPath.length - 1);
    }
  }

  void onDescend(SmoothCategory<T> childCategory) {
    setState(() {
      widget.onPathChanged(<T>[...widget.currentPath, childCategory.value]);
    });
  }

  Stream<_CategoryPage<T>> _generatePages(List<T> path) async* {
    final List<T> accumulator = <T>[];
    for (final T element in path) {
      accumulator.add(element);
      final SmoothCategory<T>? category = await widget.categoryFinder(accumulator);
      if (category != null) {
        yield _CategoryPage<T>(
          currentCategories: widget.currentCategories,
          currentPath: accumulator,
          childCategories: await category.getChildren().toSet(),
          onDescend: onDescend,
          onSelect: widget.onChanged,
        );
      }
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      if (page < widget.currentPath.length) {
        widget.onPathChanged(widget.currentPath.sublist(0, page + 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_CategoryPage<T>>>(
      future: _generatePages(widget.currentPath).toList(),
      // ignore: prefer_const_literals_to_create_immutables
      initialData: <_CategoryPage<T>>[],
      builder: (BuildContext context, AsyncSnapshot<List<_CategoryPage<T>>> snapshot) {
        return PageView(
          onPageChanged: _onPageChanged,
          controller: controller,
          children: snapshot.data!,
        );
      },
    );
  }
}

// A callback used to notify that the category page has asked to descend to a child
// category.
typedef _DescendCategoryCallback<T extends SmoothCategory<dynamic>> = void Function(
    T childCategory);

class _CategoryPage<T extends Comparable<T>> extends StatelessWidget {
  const _CategoryPage({
    Key? key,
    required this.currentCategories,
    required this.currentPath,
    required this.childCategories,
    required this.onDescend,
    required this.onSelect,
  }) : super(key: key);

  final Set<T> currentCategories;
  final List<T> currentPath;
  final Set<SmoothCategory<T>> childCategories;
  final CategoriesChangedCallback<T> onSelect;
  final _DescendCategoryCallback<SmoothCategory<T>> onDescend;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          for (final SmoothCategory<T> category in childCategories) ...<Widget>[
            _CategoryItem<SmoothCategory<T>>(
              selected: currentCategories.contains(category.value),
              category: category,
              onDescend: onDescend,
              onSelect: (bool? value) {
                if (value == true) {
                  onSelect(currentCategories.union(<T>{category.value}));
                } else if (value == false) {
                  onSelect(currentCategories.difference(<T>{category.value}));
                }
              },
            ),
            if (category != childCategories.last) const Divider(),
          ]
        ],
      ),
    );
  }
}

class _CategoryItem<T extends SmoothCategory<dynamic>> extends StatelessWidget {
  const _CategoryItem({
    Key? key,
    required this.selected,
    required this.category,
    required this.onDescend,
    required this.onSelect,
  }) : super(key: key);

  final T category;
  final bool selected;
  final _DescendCategoryCallback<T> onDescend;
  final ValueChanged<bool?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8.0),
      child: FutureBuilder<bool>(
        future: category.hasChildren,
        initialData: false,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          final bool hasChildren = !(snapshot.data ?? false);
          return Row(
            children: <Widget>[
              if (hasChildren)
                Checkbox(value: selected, onChanged: onSelect)
              else
                const SizedBox(width: Checkbox.width + 32.0, height: Checkbox.width),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    if (hasChildren) {
                      onDescend(category);
                    } else {
                      onSelect(!selected);
                    }
                  },
                  child: Text(category.toString()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onDescend(category),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A widget used to display a list of categories (or other items) as a wrapped list
/// of chips.
///
/// If [onDeleted] is supplied, chips can be deleted, and [onDeleted] will be called
/// when they are.
class SmoothCategoryDisplay<T extends Object> extends StatefulWidget {
  SmoothCategoryDisplay({Set<T>? categories, this.onDeleted}) : categories = categories ?? <T>{};

  /// The set of categories to display.
  ///
  /// The type `T` should have a reasonable [toString] method for displaying the
  /// human-readable name of the category.
  final Set<T> categories;

  /// If supplied this will enable the category chips to be deleted (displaying a delete icon), and if they are,
  /// this function will be called.
  final ValueChanged<T>? onDeleted;

  @override
  State<SmoothCategoryDisplay<T>> createState() => _SmoothCategoryDisplayState<T>();
}

class _SmoothCategoryDisplayState<T extends Object> extends State<SmoothCategoryDisplay<T>> {
  Set<T> removedCategories = <T>{};
  Set<T> addedCategories = <T>{};

  @override
  void didUpdateWidget(SmoothCategoryDisplay<T> oldWidget) {
    removedCategories = oldWidget.categories.difference(widget.categories);
    addedCategories = widget.categories.difference(oldWidget.categories);
    scheduleMicrotask(() {
      // This is so that initially added categories start non-visible, and animate in.
      // Once they've been added as non-visible in the previous frame, clearing this set
      // makes them visible which starts them animating in.
      setState(() {
        addedCategories.clear();
      });
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox(height: _kCategoryHeight);
    }
    final List<T> combinedCategories = <T>[
      ...widget.categories,
      ...removedCategories,
    ];
    combinedCategories.sort();
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 8.0,
      runSpacing: 4.0,
      children: <Widget>[
        for (final T category in combinedCategories)
          _AnimatedInputChip(
            key: ValueKey<T>(category),
            visible: !removedCategories.contains(category) && !addedCategories.contains(category),
            label: Text(category.toString()),
            onDeleted: widget.onDeleted != null
                ? () {
                    widget.onDeleted!(category);
                  }
                : null,
            onAnimationEnd: () {
              setState(() {
                if (removedCategories.contains(category)) {
                  removedCategories.remove(category);
                }
              });
            },
          ),
      ],
    );
  }
}

class _AnimatedInputChip extends StatelessWidget {
  const _AnimatedInputChip({
    Key? key,
    this.backgroundColor,
    required this.visible,
    required this.label,
    required this.onDeleted,
    required this.onAnimationEnd,
  }) : super(key: key);

  final Color? backgroundColor;
  final Widget label;
  final bool visible;
  final VoidCallback? onDeleted;
  final VoidCallback? onAnimationEnd;

  @override
  Widget build(BuildContext context) {
    return _AnimatedSqueeze(
      duration: const Duration(milliseconds: 200),
      scale: visible
          ? const Size(_kMaxCategoryWidth, _kCategoryHeight)
          : const Size(0.0, _kCategoryHeight),
      onEnd: onAnimationEnd,
      curve: Curves.easeInOut,
      alignment: Alignment.centerLeft,
      child: InputChip(
        backgroundColor: backgroundColor,
        label: label,
        onDeleted: onDeleted,
        deleteIcon: AnimatedOpacity(
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeOutExpo.flipped,
          opacity: visible ? 1.0 : 0.0,
          child: const Icon(
            Icons.cancel,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _AnimatedSqueeze extends ImplicitlyAnimatedWidget {
  // Creates a widget that animates a "squeeze" effect on its child.
  //
  // The [scale] argument must not be null.
  // The [curve] and [duration] arguments must not be null.
  const _AnimatedSqueeze({
    Key? key,
    this.child,
    required this.scale,
    this.alignment = Alignment.center,
    this.filterQuality,
    Curve curve = Curves.linear,
    required Duration duration,
    VoidCallback? onEnd,
  }) : super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  // The widget below this widget in the tree.
  final Widget? child;

  // The target scale, in each dimension.
  final Size scale;

  // The alignment of the origin of the coordinate system in which the scale
  // takes place, relative to the size of the box.
  //
  // For example, to set the origin of the scale to bottom middle, you can use
  // an alignment of (0.0, 1.0).
  final Alignment alignment;

  // The filter quality with which to apply the transform as a bitmap operation.
  final FilterQuality? filterQuality;

  @override
  ImplicitlyAnimatedWidgetState<_AnimatedSqueeze> createState() => _AnimatedSqueezeState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Size>('scale', scale));
    properties.add(
        DiagnosticsProperty<Alignment>('alignment', alignment, defaultValue: Alignment.center));
    properties.add(EnumProperty<FilterQuality>('filterQuality', filterQuality, defaultValue: null));
  }
}

class _AnimatedSqueezeState extends ImplicitlyAnimatedWidgetState<_AnimatedSqueeze> {
  Tween<Size>? _scale;
  late Animation<Size> _scaleAnimation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _scale = visitor(_scale, widget.scale, (dynamic value) => Tween<Size>(begin: value as Size))
        as Tween<Size>?;
  }

  @override
  void didUpdateTweens() {
    _scaleAnimation = animation.drive(_scale!);
  }

  @override
  Widget build(BuildContext context) {
    return _SqueezeTransition(
      scale: _scaleAnimation,
      alignment: widget.alignment,
      filterQuality: widget.filterQuality,
      child: widget.child,
    );
  }
}

class _SqueezeTransition extends AnimatedWidget {
  // Creates a squeeze transition to be used to animate a squeeze effect on the
  // child.
  //
  // The [scale] argument must not be null. The [alignment] argument defaults
  // to [Alignment.center].
  const _SqueezeTransition({
    Key? key,
    required Animation<Size> scale,
    this.alignment = Alignment.center,
    this.filterQuality,
    this.child,
  }) : super(key: key, listenable: scale);

  // The animation that controls the scale of the child.
  //
  // If the current value of the scale animation is v, the child will be
  // painted v times its normal size.
  Animation<Size> get scale => listenable as Animation<Size>;

  // The alignment of the origin of the coordinate system in which the scale
  // takes place, relative to the size of the box.
  //
  // For example, to set the origin of the scale to bottom middle, you can use
  // an alignment of (0.0, 1.0).
  final Alignment alignment;

  // The filter quality with which to apply the transform as a bitmap operation.
  final FilterQuality? filterQuality;

  // The widget below this widget in the tree.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: scale.value.width,
        maxHeight: scale.value.height,
      ),
      child: child,
    );
  }
}

/// The base class for data provided to the [SmoothCategoryPicker].
///
/// Subclasses should override the [getLabel] accessor to give a human-readable version
/// of this category for display in the UI.
abstract class SmoothCategory<T extends Comparable<T>> {
  const SmoothCategory(this.value);

  /// The value of this node.
  final T value;

  /// This returns a depth-first iterable over the descendants of this node.
  Stream<SmoothCategory<T>> getDescendants() async* {
    await for (final SmoothCategory<T> child in getChildren()) {
      yield* child.getDescendants();
      yield child;
    }
  }

  /// Whether or not this node has children.
  Future<bool> get hasChildren async => !(await getChildren().isEmpty);

  /// Returns an iterable of the parents of this node.
  Stream<SmoothCategory<T>> getParents();

  /// Gets the list of children of this node.
  Stream<SmoothCategory<T>> getChildren();

  /// Returns true if this node has a child with the given value.
  Future<bool> containsChildWithValue(T childValue) async {
    return await getChild(childValue) != null;
  }

  void addChild(covariant SmoothCategory<T> newChild);

  /// Returns the child node with the value given.
  Future<SmoothCategory<T>?> getChild(T childValue) async {
    final List<SmoothCategory<T>> results = await
        getChildren().where((SmoothCategory<T> child) => child.value == childValue).toList();
    if (results.isEmpty) {
      debugPrint('Child $childValue not found.');
      return null;
    }
    debugPrint('Returning child ${results.single}');
    return results.single;
  }

  Future<SmoothCategory<T>?> findInDescendants(T value) async {
    final List<SmoothCategory<T>> results =
        await getDescendants().where((SmoothCategory<T> child) => child.value == value).toList();
    if (results.isEmpty) {
      return null;
    }
    return results.single;
  }

  /// Returns a human-readable label that will be displayed in the UI
  String getLabel(OpenFoodFactsLanguage language);

  @override
  String toString() => getLabel(OpenFoodFactsLanguage.ENGLISH);
}
