import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
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
  /// Max value for the picker.
  static const int _maxGrams = 1000;
  static const int _minGrams = 10;

  final TextEditingController _quantityController = TextEditingController(
    text: '100',
  );

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_onInputChanged);
  }

  void _onInputChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool isQuantityValid = _isInputValid();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // We have to manually add a Semantic node here, otherwise the text is
        // not read
        Semantics(
          value: appLocalizations.portion_calculator_description,
          excludeSemantics: true,
          child: Text(
            appLocalizations.portion_calculator_description,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: MEDIUM_SPACE),
        Container(
          height:
              MediaQuery.textScalerOf(context).scale(SMALL_SPACE * 2 + 15.0) *
                  1.2,
          padding: const EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.3,
                child: Semantics(
                  value:
                      '${_quantityController.text} ${UnitHelper.unitToString(Unit.G)}',
                  hint: appLocalizations.portion_calculator_accessibility,
                  textField: true,
                  excludeSemantics: true,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9]*')),
                    ],
                    enableSuggestions: false,
                    style: const TextStyle(letterSpacing: 5.0),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      suffixText: UnitHelper.unitToString(Unit.G),
                      filled: true,
                      border: const OutlineInputBorder(
                        borderRadius: ANGULAR_BORDER_RADIUS,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: SMALL_SPACE,
                        vertical: SMALL_SPACE,
                      ),
                      hintText: appLocalizations.portion_calculator_hint,
                      hintStyle: const TextStyle(letterSpacing: 1.0),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) {
                      if (_isInputValid()) {
                        _computeAndShow();
                      }
                    },
                    autofocus: false,
                  ),
                ),
              ),
              const SizedBox(width: MEDIUM_SPACE),
              AnimatedOpacity(
                opacity: isQuantityValid ? 1.0 : 0.5,
                duration: SmoothAnimationsDuration.brief,
                child: Tooltip(
                  message: !isQuantityValid
                      ? appLocalizations.portion_calculator_error(
                          _minGrams,
                          _maxGrams,
                        )
                      : '',
                  excludeFromSemantics: isQuantityValid,
                  child: SizedBox(
                    height: double.infinity,
                    child: ElevatedButton(
                      onPressed: isQuantityValid
                          ? () async => _computeAndShow()
                          : null,
                      child: Text(appLocalizations.calculate),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isInputValid() {
    try {
      final int value = int.parse(_quantityController.text);
      return value >= _minGrams && value <= _maxGrams;
    } on FormatException catch (_) {
      return false;
    }
  }

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

    final int quantity = int.parse(_quantityController.text);
    final PortionHelper helper = PortionHelper(
      cache.orderedNutrients.nutrients,
      widget.product.nutriments!,
      quantity,
    );
    if (helper.isEmpty) {
      return;
    }
    await showSmoothDraggableModalSheet<void>(
      context: context,
      header: SmoothModalSheetHeader(
        title: appLocalizations.portion_calculator_result_title(quantity),
      ),
      initHeight: 0.7,
      bodyBuilder: (BuildContext context) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: helper.length,
            (BuildContext context, int position) {
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VERY_LARGE_SPACE,
                      vertical: LARGE_SPACE,
                    ),
                    child: MergeSemantics(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(helper.getName(position)),
                          Text(helper.getValue(position)),
                        ],
                      ),
                    ),
                  ),
                  if (position < helper.length - 1) const Divider(height: 1.0)
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _quantityController.addListener(_onInputChanged);
    super.dispose();
  }
}
