import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Additives.dart';
import 'package:smooth_ui_library/widgets/smooth_expandable_card.dart';

class ProductProcessingExpandable extends StatelessWidget {
  const ProductProcessingExpandable(
      {@required this.additives, @required this.novaGroup});

  final Additives additives;
  final int novaGroup;

  @override
  Widget build(BuildContext context) {
    return SmoothExpandableCard(
      collapsedHeader: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                getNovaText(),
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: getNovaColor()),
              ),
            ],
          ),
          const SizedBox(
            height: 6.0,
          ),
          if (additives != null)
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'with ${additives.names.length} additives',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      .copyWith(color: getNovaColor()),
                ),
              ],
            )
          else
            Container(),
        ],
      ),
      content: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: Text(
                    'We\'ve found ${additives.names.length} additives in this product :'),
              )
            ],
          ),
          const SizedBox(
            height: 12.0,
          ),
          Container(
            height: 20.0 * additives.names.length,
            child: ListView.builder(
                itemCount: additives.names.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 20.0,
                    child: Row(
                      children: <Widget>[
                        Text(additives.names[index]),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
      expandedHeader: Text(
        'Product processing',
        style: Theme.of(context).textTheme.headline3,
      ),
    );
  }

  String getNovaText() {
    switch (novaGroup) {
      case 1:
        return 'Unprocessed or minimally processed foods';
        break;
      case 2:
        return 'Processed culinary ingredients';
        break;
      case 3:
        return 'Processed foods';
        break;
      case 4:
        return 'Ultra processed product';
        break;
      default:
        return 'Unknown NOVA group';
        break;
    }
  }

  Color getNovaColor() {
    switch (novaGroup) {
      case 1:
        return Colors.green;
        break;
      case 2:
        return Colors.orangeAccent;
        break;
      case 3:
        return Colors.deepOrangeAccent;
        break;
      case 4:
        return Colors.redAccent;
        break;
      default:
        return Colors.grey;
        break;
    }
  }
}
