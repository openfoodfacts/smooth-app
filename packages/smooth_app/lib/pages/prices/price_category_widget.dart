import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/price_header_container.dart';
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
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return PriceHeaderContainer(
      semanticsLabel: _generateSemanticsLabel(),
      imageProvider: null,
      line1: _helper.getCategory()!,
      line2: _helper.getOrigins()?.join(',${appLocalizations.sep}'),
      line3: _helper.getLabels()?.join(',${appLocalizations.sep}'),
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
