import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/prices/price_button.dart';
import 'package:smooth_app/pages/prices/price_l10n_helper.dart';

/// Price Category display (no price data here).
///
/// See also [PriceProductWidget], that deals with "barcode" products.
class PriceCategoryWidget extends StatefulWidget {
  const PriceCategoryWidget(this.price);

  final Price price;

  @override
  State<PriceCategoryWidget> createState() => _PriceCategoryWidgetState();
}

class _PriceCategoryWidgetState extends State<PriceCategoryWidget> {
  final PriceL10nHelper _helper = PriceL10nHelper();

  @override
  void initState() {
    super.initState();
    _helper.localizeTags(widget.price, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _generateSemanticsLabel(),
      container: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsGeometry.directional(start: 12.0),
        child: Wrap(
          spacing: VERY_SMALL_SPACE,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 0,
          children: <Widget>[
            if (_helper.getCategory() != null)
              AutoSizeText(
                _helper.getCategory()!,
                maxLines: 2,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            if (_helper.getOrigins() != null)
              for (final String tag in _helper.getOrigins()!)
                PriceButton(title: tag, onPressed: () {}),
            if (_helper.getLabels() != null)
              for (final String tag in _helper.getLabels()!)
                PriceButton(title: tag, onPressed: () {}),
          ],
        ),
      ),
    );
  }

  String _generateSemanticsLabel() {
    final StringBuffer result = StringBuffer();
    if (_helper.getCategory() != null) {
      result.write(_helper.getCategory());
    }
    if (_helper.getOrigins()?.isNotEmpty == true) {
      result.write(' - ${_helper.getOrigins()!.join(', ')}');
    }
    if (_helper.getLabels()?.isNotEmpty == true) {
      result.write(' - ${_helper.getLabels()!.join(', ')}');
    }
    return result.toString();
  }
}
