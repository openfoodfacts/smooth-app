
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Additives.dart';
import 'package:smooth_ui_library/widgets/smooth_expandable_card.dart';

class ProductProcessingExpandable extends StatelessWidget {

  const ProductProcessingExpandable({@required this.additives, @required this.novaGroup});

  final Additives additives;
  final int novaGroup;

  @override
  Widget build(BuildContext context) {
    return SmoothExpandableCard(
      collapsedHeader: Row(
        children: <Widget>[
          Text('Ultra processed food',  style: Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.redAccent),)
        ],
      ),
      content: Container(),
      expandedHeader: Text('Product processing', style: Theme.of(context).textTheme.headline3,),
    );
  }

}