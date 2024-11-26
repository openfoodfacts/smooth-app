import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/text_input_formatters_helper.dart';
import 'package:smooth_app/pages/product/common/product_buttons.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/product/nutrition_add_nutrient_button.dart';
import 'package:smooth_app/pages/product/nutrition_container.dart';
import 'package:smooth_app/pages/product/ordered_nutrients_cache.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/pages/product/simple_input_number_field.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/smooth_switch.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

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
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
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
          ),
        );
      }
    }
  }
}

class _NutritionPageLoadedState extends State<NutritionPageLoaded>
    with UpToDateMixin {
  late final NumberFormat _decimalNumberFormat;
  late final NutritionContainer _nutritionContainer;
  bool _ownerFieldBannerVisible = false;

  /// When the banner is visible, we add a padding to the list
  double _ownerFieldBannerHeight = 0.0;

  final Map<Nutrient, TextEditingControllerWithHistory> _controllers =
      <Nutrient, TextEditingControllerWithHistory>{};
  TextEditingControllerWithHistory? _servingController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<FocusNode> _focusNodes = <FocusNode>[];

  @override
  void initState() {
    super.initState();
    initUpToDate(
      widget.product,
      context.read<LocalDatabase>(),
    );
    _nutritionContainer = NutritionContainer(
      orderedNutrients: widget.orderedNutrients,
      product: upToDateProduct,
    );

    _decimalNumberFormat = SimpleInputNumberField.getNumberFormat(
      decimal: true,
    );
  }

  @override
  void dispose() {
    _focusNodes.clear();

    for (final TextEditingControllerWithHistory controller
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
    refreshUpToDate();

    final List<Widget> children = _generateListOfWidgets(
      appLocalizations,
      context,
    );

    return WillPopScope2(
      onWillPop: () async => (await _mayExitPage(saving: false), null),
      child: Provider<_NutritionPageLoadedState>.value(
        value: this,
        child: SmoothScaffold(
          fixKeyboard: true,
          appBar: buildEditProductAppBar(
            context: context,
            title: appLocalizations.nutrition_page_title,
            product: upToDateProduct,
          ),
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: LARGE_SPACE,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Provider<List<FocusNode>>.value(
                      value: _focusNodes,
                      child: ListView(
                        padding: const EdgeInsetsDirectional.symmetric(
                          vertical: SMALL_SPACE,
                        ),
                        children: children,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: AnimatedOwnerFieldBanner(
                  visible: _ownerFieldBannerVisible,
                  shadow: true,
                  onHeightChanged: (double height) {
                    _ownerFieldBannerHeight = height;
                    if (_ownerFieldBannerVisible) {
                      setState(() {});
                    }
                  },
                  onDismissClicked: () {
                    setState(() => _ownerFieldBannerVisible = false);
                  },
                ),
              ),
            ],
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
      ),
    );
  }

  List<Widget> _generateListOfWidgets(
    AppLocalizations appLocalizations,
    BuildContext context,
  ) {
    final List<Widget> children = <Widget>[];

    // List of focus nodes for all text fields except the serving one.

    children.add(_switchNoNutrition(appLocalizations));

    if (!_nutritionContainer.noNutritionData) {
      final Iterable<OrderedNutrient> displayableNutrients =
          _nutritionContainer.getDisplayableNutrients();

      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
          child: ImageField.NUTRITION.getPhotoButton(
            context,
            upToDateProduct,
            widget.isLoggedInMandatory,
          ),
        ),
      );

      children.add(_getServingField(appLocalizations));
      children.add(_getServingSwitch(appLocalizations));

      if (_focusNodes.length != displayableNutrients.length) {
        _focusNodes.clear();
        _focusNodes.addAll(
          List<FocusNode>.generate(
            displayableNutrients.length,
            (_) => FocusNode(),
            growable: false,
          ),
        );
      }

      for (int i = 0; i != displayableNutrients.length; i++) {
        final OrderedNutrient orderedNutrient =
            displayableNutrients.elementAt(i);

        final Nutrient nutrient = _getNutrient(orderedNutrient);
        if (_controllers[nutrient] == null) {
          final double? value = _nutritionContainer.getValue(nutrient);
          _controllers[nutrient] = TextEditingControllerWithHistory(
            text: value == null ? '' : _decimalNumberFormat.format(value),
          );
        }

        children.add(
          ChangeNotifierProvider<TextEditingControllerWithHistory>.value(
            value: _controllers[nutrient]!,
            child: _NutrientRow(
              _nutritionContainer,
              _decimalNumberFormat,
              orderedNutrient,
              i,
              upToDateProduct,
            ),
          ),
        );
      }
      children.add(
        NutritionAddNutrientButton(
          nutritionContainer: _nutritionContainer,
          refreshParent: () => setState(() {}),
        ),
      );

      if (_ownerFieldBannerVisible) {
        children.add(SizedBox(height: _ownerFieldBannerHeight));
      }
    } else {
      _focusNodes.clear();
    }
    return children;
  }

  Widget _getServingField(final AppLocalizations appLocalizations) {
    final String value = _nutritionContainer.servingSize;

    if (_servingController == null) {
      _servingController = TextEditingControllerWithHistory(text: value);
      _servingController!.selection =
          TextSelection.collapsed(offset: _servingController!.text.length - 1);
    }

    final TextEditingControllerWithHistory controller = _servingController!;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: VERY_LARGE_SPACE),
      child: Builder(
        builder: (BuildContext context) {
          return TextFormField(
            controller: controller,
            decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(),
              labelText: appLocalizations.nutrition_page_serving_size,
              suffixIcon: _getServingFieldLeading(appLocalizations),
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

  Widget? _getServingFieldLeading(final AppLocalizations appLocalizations) {
    if (widget.product.getOwnerFieldTimestamp(OwnerField.productField(
          ProductField.SERVING_SIZE,
          ProductQuery.getLanguage(),
        )) !=
        null) {
      return IconButton(
        onPressed: () {
          context.read<_NutritionPageLoadedState>().toggleOwnerFieldBanner();
        },
        icon: const OwnerFieldIcon(),
      );
    }

    if (_servingController?.initialValue?.isEmpty == true &&
        _servingController?.text.isEmpty == true &&
        widget.product.quantity != null) {
      return IconButton(
        onPressed: () {
          _servingController!.text = widget.product.quantity!;
        },
        icon: const icons.Milk.download(),
        visualDensity: VisualDensity.compact,
        enableFeedback: true,
        tooltip: appLocalizations
            .nutrition_page_take_serving_size_from_product_quantity,
      );
    }

    return null;
  }

  Widget _getServingSwitch(final AppLocalizations appLocalizations) =>
      IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Semantics(
                label: appLocalizations.nutrition_page_per_100g,
                button: true,
                child: InkWell(
                  excludeFromSemantics: true,
                  borderRadius: const BorderRadius.horizontal(
                    left: CIRCULAR_RADIUS,
                  ),
                  onTap: () => setState(
                    () => _nutritionContainer.perSize = PerSize.oneHundredGrams,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      appLocalizations.nutrition_page_per_100g,
                      style:
                          _nutritionContainer.perSize == PerSize.oneHundredGrams
                              ? const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline)
                              : null,
                    ),
                  ),
                ),
              ),
            ),
            ExcludeSemantics(
              child: SmoothSwitch(
                size: const Size(60.0, 30.0),
                value: _nutritionContainer.perSize == PerSize.serving,
                onChanged: (final bool value) => setState(
                  () => _nutritionContainer.perSize =
                      value ? PerSize.serving : PerSize.oneHundredGrams,
                ),
              ),
            ),
            Expanded(
              child: Semantics(
                label: appLocalizations.nutrition_page_per_serving,
                button: true,
                child: InkWell(
                  excludeFromSemantics: true,
                  borderRadius: const BorderRadius.horizontal(
                    right: CIRCULAR_RADIUS,
                  ),
                  onTap: () => setState(
                    () => _nutritionContainer.perSize = PerSize.serving,
                  ),
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
                ),
              ),
            )
          ],
        ),
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
            Expanded(
              flex: 2,
              child: Switch(
                value: _nutritionContainer.noNutritionData,
                onChanged: (final bool value) =>
                    setState(() => _nutritionContainer.noNutritionData = value),
                trackColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            Expanded(
              flex: 6,
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
    if (_servingController != null &&
        _servingController!.isDifferentFromInitialValue) {
      return true;
    }
    for (final TextEditingControllerWithHistory controller
        in _controllers.values) {
      if (controller.isDifferentFromInitialValue) {
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
      final TextEditingControllerWithHistory controller =
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

    final Product? changedProduct = _getChangedProduct(
      Product(barcode: barcode),
    );
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
      upToDateProduct,
      true,
    );
    await BackgroundTaskDetails.addTask(
      changedProduct,
      context: context,
      stamp: BackgroundTaskDetailsStamp.nutrition,
      productType: widget.product.productType,
    );
    return true;
  }

  void toggleOwnerFieldBanner() {
    setState(() {
      _ownerFieldBannerVisible = !_ownerFieldBannerVisible;
    });
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow(
    this.nutritionContainer,
    this.decimalNumberFormat,
    this.orderedNutrient,
    this.position,
    this.product,
  );

  final NutritionContainer nutritionContainer;
  final NumberFormat decimalNumberFormat;
  final OrderedNutrient orderedNutrient;
  final int position;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final String key = orderedNutrient.id;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 6,
          child: KeyedSubtree(
            key: Key('$key-value'),
            child: _NutrientValueCell(
              decimalNumberFormat,
              orderedNutrient,
              position,
              product,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: KeyedSubtree(
            key: Key('$key-unit'),
            child: _NutrientUnitCell(
              nutritionContainer,
              orderedNutrient,
            ),
          ),
        ),
        KeyedSubtree(
          key: Key('$key-visibility'),
          child: const _NutrientUnitVisibility(),
        )
      ],
    );
  }
}

class _NutrientValueCell extends StatelessWidget {
  const _NutrientValueCell(
    this.decimalNumberFormat,
    this.orderedNutrient,
    this.position,
    this.product,
  );

  final NumberFormat decimalNumberFormat;
  final OrderedNutrient orderedNutrient;
  final int position;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<FocusNode> focusNodes = Provider.of<List<FocusNode>>(
      context,
      listen: false,
    );
    final TextEditingControllerWithHistory controller =
        context.watch<TextEditingControllerWithHistory>();
    final bool isLast = position == focusNodes.length - 1;
    final Nutrient? nutrient = orderedNutrient.nutrient;

    return TextFormField(
      controller: controller,
      enabled: controller.isSet,
      focusNode: focusNodes[position],
      decoration: InputDecoration(
        enabledBorder: const UnderlineInputBorder(),
        labelText: orderedNutrient.name,
        suffixIcon: nutrient == null ||
                product.getOwnerFieldTimestamp(OwnerField.nutrient(nutrient)) ==
                    null
            ? null
            : IconButton(
                onPressed: () {
                  context
                      .read<_NutritionPageLoadedState>()
                      .toggleOwnerFieldBanner();
                },
                icon: const OwnerFieldIcon(),
              ),
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
          return appLocalizations.nutrition_page_invalid_number;
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
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: VERY_SMALL_SPACE,
        end: SMALL_SPACE,
      ),
      child: _NutritionCellTextWatcher(
        builder: (_, TextEditingControllerWithHistory controller) {
          return ElevatedButton(
            onPressed: controller.isNotSet
                ? null
                : widget.nutritionContainer.isEditableWeight(unit)
                    ? () => setState(
                          () => widget.nutritionContainer
                              .setNextWeightUnit(widget.orderedNutrient),
                        )
                    : null,
            child: Text(
              _getUnitLabel(unit),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
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

class _NutrientUnitVisibility extends StatelessWidget {
  const _NutrientUnitVisibility();

  @override
  Widget build(BuildContext context) {
    return _NutritionCellTextWatcher(
      builder: (
        BuildContext context,
        TextEditingControllerWithHistory controller,
      ) {
        final bool isValueSet = controller.isSet;

        return ElevatedButton(
          onPressed: () {
            if (isValueSet) {
              controller.text = '-';
            } else {
              if (controller.previousValue != '-') {
                controller.text = controller.previousValue ?? '-';
              } else {
                controller.text = '';
              }
            }
          },
          child: Icon(
            isValueSet
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
          ),
        );
      },
    );
  }
}

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

extension _NutritionTextEditionController on TextEditingController {
  bool get isSet => text.trim() != '-';

  bool get isNotSet => text.trim() == '-';
}

/// Use this Widget to be notified when the value is set or not
class _NutritionCellTextWatcher extends StatelessWidget {
  const _NutritionCellTextWatcher({
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    TextEditingControllerWithHistory value,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return Selector<TextEditingControllerWithHistory,
        TextEditingControllerWithHistory>(
      selector: (_, TextEditingControllerWithHistory controller) {
        return controller;
      },
      shouldRebuild: (_, TextEditingControllerWithHistory controller) {
        return controller.isDifferentFromPreviousValue;
      },
      builder: (BuildContext context,
          TextEditingControllerWithHistory controller, _) {
        return builder(context, controller);
      },
    );
  }
}
