import 'package:flutter/material.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_ui_library/widgets/smooth_expandable_card.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';

class ProductProcessingExpandable extends StatelessWidget {
  const ProductProcessingExpandable(this.product, this.iconWidth);

  final Product product;
  final double iconWidth;

  @override
  Widget build(BuildContext context) {
    final Attribute nova = UserPreferencesModel.getAttribute(
        product, UserPreferencesModel.ATTRIBUTE_NOVA);
    final Attribute additives = UserPreferencesModel.getAttribute(
        product, UserPreferencesModel.ATTRIBUTE_ADDITIVES);
    final List<String> additiveNames = product.additives?.names;
    return SmoothExpandableCard(
      headerHeight: null,
      collapsedHeader: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgCache(additives.iconUrl, width: iconWidth),
          ),
          Text(
              (nova.descriptionShort ?? nova.description) +
                  '\n' +
                  additives.title,
              style: Theme.of(context).textTheme.subtitle2),
        ],
      ),
      content: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: Text(additives.title),
              )
            ],
          ),
          const SizedBox(
            height: 12.0,
          ),
          Container(
            height: 20.0 * additiveNames.length,
            child: ListView.builder(
                itemCount: additiveNames.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 20.0,
                    child: Row(children: <Widget>[Text(additiveNames[index])]),
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
}
