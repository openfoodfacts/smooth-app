import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/data_models/up_to_date_manager.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/text_input_formatters_helper.dart';
import 'package:smooth_app/pages/product/common/product_buttons.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/product/nutrition_add_nutrient_button.dart';
import 'package:smooth_app/pages/product/nutrition_container.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';
import 'package:smooth_app/pages/product/simple_input_number_field.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Actual nutrition page, with data already loaded.
class NutritionPageLoaded extends StatefulWidget {
  const NutritionPageLoaded(
    this.product,
    this.orderedNutrients, {
    required this.isLoggedInMandatory,
  });

  final Product product;
  final OrderedNutrients orderedNutrients;
  final bool isLoggedInMandatory;

  @override
  State<NutritionPageLoaded> createState() => _NutritionPageLoadedState();

  /// Shows the nutrition page after loading the ordered nutrient list.
  static Future<void> showNutritionPage({
    required final Product product,
    required final bool isLoggedInMandatory,
    required final BuildContext context,
  }) async {
    if (isLoggedInMandatory) {
      if (!await ProductRefresher().checkIfLoggedIn(context)) {
        return;
      }
    }
    if (context.mounted) {
      final OrderedNutrientsCache? cache =
          await OrderedNutrientsCache.getCache(context);
      if (context.mounted) {
        if (cache == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).nutrition_cache_loading_error,
              ),
            ),
          );
          return;
        }
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => NutritionPageLoaded(
              product,
              cache.orderedNutrients,
              isLoggedInMandatory: isLoggedInMandatory,
            ),
            fullscreenDialog: true,
          ),
        );
      }
    }
  }
}

class _NutritionPageLoadedState extends State<NutritionPageLoaded> {
  late final UpToDateManager _upToDateManager;
  String get _barcode => _upToDateManager.barcode;
  Product get _product => _upToDateManager.product;

  late final NumberFormat _decimalNumberFormat;
  late final NutritionContainer _nutritionContainer;

  final Map<Nutrient, TextEditingControllerWithInitialValue> _controllers =
      <Nutrient, TextEditingControllerWithInitialValue>{};
  TextEditingControllerWithInitialValue? _servingController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _upToDateManager = UpToDateManager(
      widget.product,
      context.read<LocalDatabase>(),
    );
    _nutritionContainer = NutritionContainer(
      orderedNutrients: widget.orderedNutrients,
      product: _upToDateManager.initialProduct,
    );
    _decimalNumberFormat =
        SimpleInputNumberField.getNumberFormat(decimal: true);
  }

  @override
  void dispose() {
    _upToDateManager.dispose();
    for (final TextEditingControllerWithInitialValue controller
        in _controllers.values) {
      controller.dispose();
    }
    _servingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    _upToDateManager.refresh();

    final List<Widget> children = <Widget>[];

    // List of focus nodes for all text fields except the serving one.
    final List<FocusNode> focusNodes;

    children.add(_switchNoNutrition(appLocalizations));

    if (!_nutritionContainer.noNutritionData) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
          child: ImageField.NUTRITION.getPhotoButton(context, _product),
        ),
      );
      children.add(_getServingField(appLocalizations));
      children.add(_getServingSwitch(appLocalizations));

      final Iterable<OrderedNutrient> displayableNutrients =
          _nutritionContainer.getDisplayableNutrients();

      focusNodes = List<FocusNode>.generate(
        displayableNutrients.length,
        (_) => FocusNode(),
        growable: false,
      );

      for (int i = 0; i != displayableNutrients.length; i++) {
        final OrderedNutrient orderedNutrient =
            displayableNutrients.elementAt(i);

        final Nutrient nutrient = _getNutrient(orderedNutrient);
        if (_controllers[nutrient] == null) {
          final double? value = _nutritionContainer.getValue(nutrient);
          _controllers[nutrient] = TextEditingControllerWithInitialValue(
            text: value == null ? '' : _decimalNumberFormat.format(value),
          );
        }

        children.add(
          _NutrientRow(
            _nutritionContainer,
            _decimalNumberFormat,
            _controllers[nutrient]!,
            orderedNutrient,
            i,
          ),
        );
      }
      children.add(
        NutritionAddNutrientButton(
          nutritionContainer: _nutritionContainer,
          refreshParent: () => setState(() {}),
        ),
      );
    } else {
      focusNodes = <FocusNode>[];
    }

    return WillPopScope(
      onWillPop: () async => _mayExitPage(saving: false),
      child: SmoothScaffold(
        fixKeyboard: true,
        appBar: SmoothAppBar(
          title: AutoSizeText(
            appLocalizations.nutrition_page_title,
            maxLines: _product.productName?.isNotEmpty == true ? 1 : 2,
          ),
          subTitle: _product.productName != null
              ? Text(
                  _product.productName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: SMALL_SPACE,
          ),
          child: Form(
            key: _formKey,
            child: Provider<List<FocusNode>>.value(
              value: focusNodes,
              child: ListView(children: children),
            ),
          ),
        ),
        bottomNavigationBar: ProductBottomButtonsBar(
          onSave: () async => _exitPage(
            await _mayExitPage(saving: true),
          ),
          onCancel: () async => _exitPage(
            await _mayExitPage(saving: false),
          ),
        ),
      ),
    );
  }

  Widget _getServingField(final AppLocalizations appLocalizations) {
    final String value = _nutritionContainer.servingSize;

    if (_servingController == null) {
      _servingController = TextEditingControllerWithInitialValue(text: value);
      _servingController!.selection =
          TextSelection.collapsed(offset: _servingController!.text.length - 1);
    }

    final TextEditingControllerWithInitialValue controller =
        _servingController!;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: VERY_LARGE_SPACE),
      child: Builder(
        builder: (BuildContext context) {
          return TextFormField(
            controller: controller,
            decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(),
              labelText: appLocalizations.nutrition_page_serving_size,
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              // Move to the first TextField
              final List<FocusNode> focusNodes = Provider.of<List<FocusNode>>(
                context,
                listen: false,
              );

              if (focusNodes.isNotEmpty) {
                focusNodes[0].requestFocus();
              }
            },
            validator: (String? value) => null, // free text
          );
        },
      ),
    );
  }

  Widget _getServingSwitch(final AppLocalizations appLocalizations) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                appLocalizations.nutrition_page_per_100g,
                style: _nutritionContainer.perSize == PerSize.oneHundredGrams
                    ? const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)
                    : null,
              ),
            ),
          ),
          Switch(
            value: _nutritionContainer.perSize == PerSize.serving,
            onChanged: (final bool value) => setState(
              () => _nutritionContainer.perSize =
                  value ? PerSize.serving : PerSize.oneHundredGrams,
            ),
          ),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                appLocalizations.nutrition_page_per_serving,
                style: _nutritionContainer.perSize == PerSize.serving
                    ? const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)
                    : null,
              ),
            ),
          )
        ],
      );

  Widget _switchNoNutrition(final AppLocalizations localizations) => SmoothCard(
        color: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: MEDIUM_SPACE,
          vertical: SMALL_SPACE,
        ),
        margin: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Switch(
              value: _nutritionContainer.noNutritionData,
              onChanged: (final bool value) =>
                  setState(() => _nutritionContainer.noNutritionData = value),
              trackColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.onPrimary),
            ),
            SizedBox(
              width: _getColumnSize(context, 0.6),
              child: AutoSizeText(
                localizations.nutrition_page_unspecified,
                style: Theme.of(context).primaryTextTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  /// Returns `true` if any value differs with initial state.
  bool _isEdited() {
    if (_servingController != null && _servingController!.valueHasChanged) {
      return true;
    }
    for (final TextEditingControllerWithInitialValue controller
        in _controllers.values) {
      if (controller.valueHasChanged) {
        return true;
      }
    }
    return _nutritionContainer.isEdited();
  }

  Product? _getChangedProduct(Product product) {
    if (!_formKey.currentState!.validate()) {
      return null;
    }
    for (final Nutrient nutrient in _controllers.keys) {
      final TextEditingControllerWithInitialValue controller =
          _controllers[nutrient]!;
      _nutritionContainer.setNutrientValueText(
        nutrient,
        controller.text,
        _decimalNumberFormat,
      );
    }
    if (_servingController != null) {
      _nutritionContainer.setServingText(_servingController?.text);
    }
    return _nutritionContainer.getChangedProduct(product);
  }

  /// Exits the page if the [flag] is `true`.
  void _exitPage(final bool flag) {
    if (flag) {
      Navigator.of(context).pop();
    }
  }

  /// Returns `true` if we should really exit the page.
  ///
  /// Parameter [saving] tells about the context: are we leaving the page,
  /// or have we clicked on the "save" button?
  Future<bool> _mayExitPage({required final bool saving}) async {
    if (!_isEdited()) {
      return true;
    }
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (!saving) {
      final bool? pleaseSave =
          await MayExitPageHelper().openSaveBeforeLeavingDialog(context);
      if (pleaseSave == null) {
        return false;
      }
      if (pleaseSave == false) {
        return true;
      }
      if (!mounted) {
        return false;
      }
    }

    final Product? changedProduct =
        _getChangedProduct(Product(barcode: _barcode));
    if (changedProduct == null) {
      if (!mounted) {
        return false;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // here I cheat and I reuse the only invalid case.
          content: Text(appLocalizations.nutrition_page_invalid_number),
        ),
      );
      return false;
    }

    AnalyticsHelper.trackProductEdit(
      AnalyticsEditEvents.nutrition_Facts,
      _barcode,
      true,
    );
    await BackgroundTaskDetails.addTask(
      changedProduct,
      widget: this,
      stamp: BackgroundTaskDetailsStamp.nutrition,
    );
    return true;
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow(
    this.nutritionContainer,
    this.decimalNumberFormat,
    this.controller,
    this.orderedNutrient,
    this.position,
  );

  final NutritionContainer nutritionContainer;
  final NumberFormat decimalNumberFormat;
  final TextEditingControllerWithInitialValue controller;
  final OrderedNutrient orderedNutrient;
  final int position;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: _NutrientValueCell(
              decimalNumberFormat,
              controller,
              orderedNutrient,
              position,
            ),
          ),
          SizedBox(
            width: _getColumnSize(context, 0.3),
            child: _NutrientUnitCell(
              nutritionContainer,
              orderedNutrient,
            ),
          ),
        ],
      );
}

class _NutrientValueCell extends StatelessWidget {
  const _NutrientValueCell(
    this.decimalNumberFormat,
    this.controller,
    this.orderedNutrient,
    this.position,
  );

  final NumberFormat decimalNumberFormat;
  final TextEditingControllerWithInitialValue controller;
  final OrderedNutrient orderedNutrient;
  final int position;

  @override
  Widget build(BuildContext context) {
    final List<FocusNode> focusNodes = Provider.of<List<FocusNode>>(
      context,
      listen: false,
    );

    final bool isLast = position == focusNodes.length - 1;

    return TextFormField(
      controller: controller,
      focusNode: focusNodes[position],
      decoration: InputDecoration(
        enabledBorder: const UnderlineInputBorder(),
        labelText: orderedNutrient.name,
      ),
      keyboardType: const TextInputType.numberWithOptions(
        signed: false,
        decimal: true,
      ),
      textInputAction: isLast ? null : TextInputAction.next,
      onFieldSubmitted: (_) async {
        if (!isLast) {
          focusNodes[position + 1].requestFocus();
        }
      },
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(
          SimpleInputNumberField.getNumberRegExp(decimal: true),
        ),
        DecimalSeparatorRewriter(decimalNumberFormat),
      ],
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return null;
        }
        try {
          decimalNumberFormat.parse(value);
          return null;
        } catch (e) {
          return AppLocalizations.of(context).nutrition_page_invalid_number;
        }
      },
    );
  }
}

class _NutrientUnitCell extends StatefulWidget {
  const _NutrientUnitCell(
    this.nutritionContainer,
    this.orderedNutrient,
  );

  final NutritionContainer nutritionContainer;
  final OrderedNutrient orderedNutrient;

  @override
  State<_NutrientUnitCell> createState() => _NutrientUnitCellState();
}

class _NutrientUnitCellState extends State<_NutrientUnitCell> {
  @override
  Widget build(BuildContext context) {
    final Unit unit =
        widget.nutritionContainer.getUnit(_getNutrient(widget.orderedNutrient));
    return ElevatedButton(
      onPressed: widget.nutritionContainer.isEditableWeight(unit)
          ? () => setState(
                () => widget.nutritionContainer
                    .setNextWeightUnit(widget.orderedNutrient),
              )
          : null,
      child: Text(
        _getUnitLabel(unit),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  static const Map<Unit, String> _unitLabels = <Unit, String>{
    Unit.G: 'g',
    Unit.MILLI_G: 'mg',
    Unit.MICRO_G: 'mcg/µg',
    Unit.KJ: 'kJ',
    Unit.KCAL: 'kcal',
    Unit.PERCENT: '%',
  };

  static String _getUnitLabel(final Unit unit) =>
      _unitLabels[unit] ?? UnitHelper.unitToString(unit)!;
}

double _getColumnSize(
  final BuildContext context,
  final double adjustmentFactor,
) =>
    MediaQuery.of(context).size.width * adjustmentFactor;

// cf. https://github.com/openfoodfacts/smooth-app/issues/3387
Nutrient _getNutrient(final OrderedNutrient orderedNutrient) {
  if (orderedNutrient.nutrient != null) {
    return orderedNutrient.nutrient!;
  }
  if (orderedNutrient.id == 'energy') {
    return Nutrient.energyKJ;
  }
  throw Exception('unknown nutrient for "${orderedNutrient.id}"');
}
