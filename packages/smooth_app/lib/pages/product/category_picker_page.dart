import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/product/category_cache.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';

/// Category picker page.
class CategoryPickerPage extends StatefulWidget {
  CategoryPickerPage({
    required this.barcode,
    required this.initialMap,
    required this.initialTree,
    required this.categoryCache,
  }) {
    initialTag = initialTree[initialTree.length - 1];
    initialFatherTag = initialTree[initialTree.length - 2];
    // TODO(monsieurtanuki): manage roots (that have no father)
  }

  final String barcode;
  final Map<String, TaxonomyCategory> initialMap;
  final List<String> initialTree;
  final CategoryCache categoryCache;
  late final String initialFatherTag;
  late final String initialTag;

  @override
  State<CategoryPickerPage> createState() => _CategoryPickerPageState();
}

class _CategoryPickerPageState extends State<CategoryPickerPage> {
  final Map<String, TaxonomyCategory> _map = <String, TaxonomyCategory>{};
  final List<String> _tags = <String>[];
  String? _fatherTag;
  TaxonomyCategory? _fatherCategory;

  @override
  void initState() {
    super.initState();
    _refresh(widget.initialMap, widget.initialFatherTag);
  }

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.category_picker_page_appbar_text),
      ),
      body: ListView.builder(
        itemBuilder: (final BuildContext context, final int index) {
          final String tag = _tags[index];
          final TaxonomyCategory category = _map[tag]!;
          final bool isInTree = widget.initialTree.contains(tag);
          final bool selected = widget.initialTree.last == tag;
          final bool isFather = tag == _fatherTag;
          final bool hasFather = _fatherCategory!.parents?.isNotEmpty == true;
          final Future<void> Function()? mainAction;
          if (isFather) {
            mainAction = () async => _displaySiblingsAndFather(fatherTag: tag);
          } else {
            mainAction = () async => _select(tag, localDatabase);
          }
          return ListTile(
            onTap: mainAction,
            selected: isInTree,
            title: Text(
              widget.categoryCache.getBestCategoryName(category) ?? tag,
            ),
            trailing: isFather
                ? null
                : category.children == null
                    ? null
                    : IconButton(
                        icon: const Icon(CupertinoIcons.arrow_down_right),
                        onPressed: () async => _displaySiblingsAndFather(
                          fatherTag: tag,
                        ),
                      ),
            leading: isFather
                ? !hasFather
                    ? null
                    : IconButton(
                        icon: const Icon(CupertinoIcons.arrow_up_left),
                        onPressed: () async {
                          final String fatherTag =
                              _fatherCategory!.parents!.last;
                          final Map<String, TaxonomyCategory>? map =
                              await widget.categoryCache
                                  .getCategorySiblingsAndFather(
                            fatherTag: fatherTag,
                          );
                          if (map == null) {
                            // TODO(monsieurtanuki): what shall we do?
                            return;
                          }
                          setState(() => _refresh(map, fatherTag));
                        },
                      )
                : selected
                    ? IconButton(
                        icon: const Icon(Icons.radio_button_checked),
                        onPressed: () {},
                      )
                    : IconButton(
                        icon: const Icon(Icons.radio_button_off),
                        onPressed: mainAction,
                      ),
          );
        },
        itemCount: _tags.length,
      ),
    );
  }

  void _refresh(final Map<String, TaxonomyCategory> map, final String father) {
    final List<String> tags = <String>[];
    tags.addAll(map.keys);
    // TODO(monsieurtanuki): sort by category name?
    _fatherTag = father;
    _fatherCategory = map[father];
    tags.remove(father); // we don't need the father here.
    tags.insert(0, father);
    _tags.clear();
    _tags.addAll(tags);
    _map.clear();
    _map.addAll(map);
  }

  /// Goes up one level
  Future<void> _displaySiblingsAndFather({
    required final String fatherTag,
  }) async {
    final Map<String, TaxonomyCategory>? map =
        await widget.categoryCache.getCategorySiblingsAndFather(
      fatherTag: fatherTag,
    );
    if (map == null) {
      // TODO(monsieurtanuki): what shall we do?
      return;
    }
    setState(() => _refresh(map, fatherTag));
  }

  Future<void> _select(
    final String tag,
    final LocalDatabase localDatabase,
  ) async {
    if (tag == widget.initialTag) {
      Navigator.of(context).pop();
      return;
    }
    final Product product = Product(barcode: widget.barcode);
    product.categoriesTags = <String>[
      tag
    ]; // TODO(monsieurtanuki): is the last leaf good enough or should we go down to the roots?

    final bool savedAndRefreshed = await ProductRefresher().saveAndRefresh(
      context: context,
      localDatabase: localDatabase,
      product: product,
    );
    if (savedAndRefreshed) {
      Navigator.of(context).pop(tag);
    }
  }
}
