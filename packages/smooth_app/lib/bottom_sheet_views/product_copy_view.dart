import 'package:flutter/material.dart';
import 'package:smooth_app/pages/pantry/common/pantry_button.dart';
import 'package:smooth_app/pages/product/common/product_list_button.dart';

///The ModalBottomSheet to choose where to copy/add products to
class ProductCopyView extends StatelessWidget {
  const ProductCopyView({
    @required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              margin: const EdgeInsets.only(top: 20.0, bottom: 24.0),
              child: Text(
                'Add this product',
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                'Lists:',
                style: Theme.of(context).textTheme.headline2,
              ),
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Wrap(
                direction: Axis.horizontal,
                children: children.whereType<ProductListButton>().toList(),
                spacing: 8.0,
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                'Pantries:',
                style: Theme.of(context).textTheme.headline2,
              ),
              width: MediaQuery.of(context).size.width,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Wrap(
                direction: Axis.horizontal,
                children: children.whereType<PantryButton>().toList(),
                spacing: 8.0,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          ],
        ),
      ),
    );
  }
}
