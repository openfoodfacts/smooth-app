import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/utils/UnitHelper.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';
import 'package:smooth_app/pages/product/portion_helper.dart';

/// Displays a portion size selector and a "compute!" button; results as dialog.
class PortionCalculator extends StatefulWidget {
  const PortionCalculator(this.product);

  final Product product;

  @override
  State<PortionCalculator> createState() => _PortionCalculatorState();
}

class _PortionCalculatorState extends State<PortionCalculator> {
  /// Typical size needed for [CupertinoPicker].
  static const double _kItemExtent = DEFAULT_ICON_SIZE;

  /// Max value for the picker.
  static const int _maxGrams = 1000;

  /// Value for the picker, with an initial value.
  int _grams = 100;

  late final FixedExtentScrollController _controllerUnit;

  @override
  void initState() {
    super.initState();
    _controllerUnit = FixedExtentScrollController(
      initialItem: _fromGramsToIndex(_grams),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          appLocalizations.portion_calculator_description,
          textAlign: TextAlign.center,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: _kItemExtent * 2,
              height: _kItemExtent * 5,
              child: CupertinoPicker.builder(
                scrollController: _controllerUnit,
                itemExtent: _kItemExtent,
                onSelectedItemChanged: (final int index) =>
                    _grams = _fromIndexToGrams(index),
                childCount: _fromGramsToIndex(_maxGrams) + 1,
                itemBuilder: (final BuildContext context, final int index) =>
                    Text('${_fromIndexToGrams(index)}'),
              ),
            ),
            Text(UnitHelper.unitToString(Unit.G)!),
            Padding(
              padding: const EdgeInsets.only(left: SMALL_SPACE),
              child: ElevatedButton(
                onPressed: () async => _computeAndShow(),
                child: Text(appLocalizations.calculate),
              ),
            ),
          ],
        ),
      ],
    );
  }

  int _fromIndexToGrams(final int index) => (index + 1) * 10;

  int _fromGramsToIndex(final int grams) => (grams ~/ 10) - 1;

  /// Computes all the nutrients with a portion factor, and displays a dialog.
  Future<void> _computeAndShow() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (widget.product.nutriments == null) {
      return;
    }
    final OrderedNutrientsCache? cache =
        await OrderedNutrientsCache.getCache(context);
    if (cache == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    final PortionHelper helper = PortionHelper(
      cache.orderedNutrients.nutrients,
      widget.product.nutriments!,
      _grams,
    );
    if (helper.isEmpty) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) => SmoothAlertDialog(
        title: appLocalizations.portion_calculator_result_title(_grams),
        body: Column(
          children: List<Widget>.generate(
            helper.length,
            (final int index) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(helper.getName(index)),
                Text(helper.getValue(index)),
              ],
            ),
          ),
        ),
        positiveAction: SmoothActionButton(
          text: appLocalizations.okay,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
