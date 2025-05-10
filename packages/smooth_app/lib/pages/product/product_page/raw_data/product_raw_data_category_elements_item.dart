import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/models/raw_data_element.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/product_raw_data_element_item.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class CategoryElementsListView extends StatefulWidget {
  const CategoryElementsListView({
    required this.elements,
    this.controller,
  });

  final List<ProductRawDataSubCategory> elements;
  final ScrollController? controller;

  @override
  State<StatefulWidget> createState() => _CategoryElementsListViewState();
}

class _CategoryElementsListViewState extends State<CategoryElementsListView> {
  bool extended = false;

  void extendList() {
    setState(() {
      extended = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<ProductRawDataSubCategory> listToShow;
    if (extended) {
      listToShow = widget.elements;
    } else {
      listToShow = _shortenIfTooLong(widget.elements);
    }
    final Color dividerColor =
        context.lightTheme() ? const Color(0xFFF9F9F9) : Colors.white;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 90.0),
      child: ListView.separated(
        controller: widget.controller,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: MEDIUM_SPACE,
        ),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsetsDirectional.only(start: 21),
            child: ProductRawDataElementItem(
              listToShow[index],
              () => extendList(),
            ),
          );
        },
        separatorBuilder: (BuildContext context, _) => Divider(
          color: dividerColor,
        ),
        itemCount: listToShow.length,
      ),
    );
  }

  static const int _SUB_LIST_LENGTH = 3;

  List<ProductRawDataSubCategory> _shortenIfTooLong(
      List<ProductRawDataSubCategory> list) {
    if (list.length > _SUB_LIST_LENGTH) {
      final List<ProductRawDataSubCategory> toReturn =
          <ProductRawDataSubCategory>[
        ...list.sublist(0, _SUB_LIST_LENGTH),
        ProductRawDataSeeMoreButton()
      ];
      return toReturn;
    } else {
      return list;
    }
  }
}
