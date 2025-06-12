import 'package:flutter/material.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/models/product_raw_data_element.dart';
import 'package:smooth_app/pages/product/product_page/raw_data/product_raw_data_element_widget.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductRawDataElementsListWidget extends StatefulWidget {
  //rename ProductRawDataElementsListWidget
  const ProductRawDataElementsListWidget({
    required this.elements,
    this.controller,
  });

  final List<ProductRawDataElement> elements;
  final ScrollController? controller;

  @override
  State<StatefulWidget> createState() => _CategoryElementsListViewState();
}

class _CategoryElementsListViewState extends State<ProductRawDataElementsListWidget> {
  bool extended = false;

  void extendList() {
    setState(() {
      extended = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<ProductRawDataElement> listToShow;
    if (extended) {
      listToShow = widget.elements;
    } else {
      listToShow = _shortenIfTooLong(widget.elements);
    }
    final Color dividerColor =
        context.lightTheme() ? const Color(0xFFF9F9F9) : Colors.white;

    return SliverPadding(
      padding: const EdgeInsetsDirectional.only(start: 90.0),
      sliver: SliverList.separated(
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsetsDirectional.only(start: 21),
            child: ProductRawDataElementWidget(
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

  List<ProductRawDataElement> _shortenIfTooLong(
      List<ProductRawDataElement> list) {
    if (list.length > _SUB_LIST_LENGTH) {
      final List<ProductRawDataElement> toReturn = <ProductRawDataElement>[
        ...list.sublist(0, _SUB_LIST_LENGTH),
        ProductRawDataSeeMoreButton()
      ];
      return toReturn;
    } else {
      return list;
    }
  }
}
