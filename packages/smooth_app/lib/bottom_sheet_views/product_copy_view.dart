import 'package:flutter/material.dart';

///The ModalBottomSheet to choose where to copy/add products to
class ProductCopyView extends StatelessWidget {
  const ProductCopyView({
    @required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.9;
    return Material(
      child: Container(
        height: height,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              height: height,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    margin: const EdgeInsets.only(top: 20.0, bottom: 24.0),
                    child: Text(
                      'Copy to:',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  Wrap(
                    direction: Axis.horizontal,
                    children: children,
                    spacing: 8.0,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
