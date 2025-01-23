import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_sliver_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/input/unfocus_field_when_tap_outside.dart';
import 'package:smooth_app/pages/product/common/product_buttons.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_add_nutrient_button.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_availability_container.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_facts_editor.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_image_viewer.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_serving_size.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_serving_switch.dart';
import 'package:smooth_app/pages/product/simple_input_number_field.dart';
import 'package:smooth_app/pages/product/simple_input_widget.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
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
}

class _NutritionPageLoadedState extends State<NutritionPageLoaded>
    with UpToDateMixin {
  final Map<Nutrient, TextEditingControllerWithHistory> _controllers =
      <Nutrient, TextEditingControllerWithHistory>{};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingControllerWithHistory _servingController;
  late final NutritionContainerHelper _nutritionContainer;
  late final NumberFormat _decimalNumberFormat;

  bool _imageVisible = false;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
    _nutritionContainer = NutritionContainerHelper(
      orderedNutrients: widget.orderedNutrients,
      product: upToDateProduct,
    );

    _servingController =
        TextEditingControllerWithHistory(text: _nutritionContainer.servingSize);
    _servingController.selection =
        TextSelection.collapsed(offset: _servingController.text.length - 1);
    _decimalNumberFormat =
        SimpleInputNumberField.getNumberFormat(decimal: true);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    refreshUpToDate();

    return WillPopScope2(
      onWillPop: () async => (await _mayExitPage(saving: false), null),
      child: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<NutritionContainerHelper>(
            create: (_) => _nutritionContainer,
          ),
          Provider<Product>.value(
            value: upToDateProduct,
          ),
          Provider<Map<Nutrient, TextEditingControllerWithHistory>>.value(
            value: _controllers,
          ),
          Provider<NumberFormat>.value(
            value: _decimalNumberFormat,
          ),
        ],
        child: UnfocusFieldWhenTapOutside(
          child: Theme(
            data: Theme.of(context).copyWith(
              scaffoldBackgroundColor: context.lightTheme()
                  ? Theme.of(context)
                      .extension<SmoothColorsThemeExtension>()!
                      .primaryLight
                  : null,
            ),
            child: SmoothScaffold(
              fixKeyboard: true,
              appBar: buildEditProductAppBar(
                  context: context,
                  title: appLocalizations.nutrition_page_title,
                  product: upToDateProduct,
                  actions: <Widget>[
                    if (!_imageVisible)
                      IconButton(
                        icon: const Icon(Icons.image_rounded),
                        tooltip: ImageField.NUTRITION
                            .getProductImageButtonText(appLocalizations),
                        onPressed: () {
                          if (TransientFile.fromProduct(
                            upToDateProduct,
                            ImageField.NUTRITION,
                            ProductQuery.getLanguage(),
                          ).isImageAvailable()) {
                            setState(() {
                              _imageVisible = !_imageVisible;
                            });
                          } else {
                            ImageField.NUTRITION.openDetails(
                              context,
                              upToDateProduct,
                              widget.isLoggedInMandatory,
                            );
                          }
                        },
                      ),
                  ]),
              body: Column(
                children: <Widget>[
                  NutritionImageViewer(
                    visible: _imageVisible,
                    onClose: () => setState(() => _imageVisible = false),
                  ),
                  Expanded(
                    child: _NutritionPageBody(
                      servingController: _servingController,
                      formKey: _formKey,
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
        ),
      ),
    );
  }

  /// Returns `true` if any value differs with initial state.
  bool _isEdited() {
    if (_servingController.isDifferentFromInitialValue) {
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
    _nutritionContainer.setServingText(_servingController.text);
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
        SmoothFloatingSnackbar(
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
      productType: upToDateProduct.productType,
    );
    return true;
  }

  @override
  void dispose() {
    for (final TextEditingControllerWithHistory controller
        in _controllers.values) {
      controller.dispose();
    }
    _servingController.dispose();
    super.dispose();
  }
}

class _NutritionPageBody extends StatefulWidget {
  const _NutritionPageBody({
    required this.formKey,
    required this.servingController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingControllerWithHistory servingController;

  @override
  State<_NutritionPageBody> createState() => _NutritionPageBodyState();
}

class _NutritionPageBodyState extends State<_NutritionPageBody> {
  final Map<OrderedNutrient, FocusNode> _focusNodes =
      <OrderedNutrient, FocusNode>{};

  /// When a nutrient is added, ensure that the focus will be on it
  OrderedNutrient? _nutrientToHighlight;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Provider<Map<OrderedNutrient, FocusNode>>.value(
        value: _focusNodes,
        child: CustomScrollView(
          slivers: <Widget>[
            const NutritionAvailabilityContainer(),
            Consumer<NutritionContainerHelper>(
              builder: (
                BuildContext context,
                NutritionContainerHelper nutritionContainer,
                _,
              ) {
                final List<Widget> children;

                if (nutritionContainer.noNutritionData) {
                  children = <Widget>[];
                  for (final FocusNode node in _focusNodes.values) {
                    node.dispose();
                  }
                  _focusNodes.clear();
                } else {
                  children = <Widget>[
                    NutritionServingSize(
                      controller: widget.servingController,
                    ),
                    _nutritionDataWidgets(
                      context,
                      nutritionContainer,
                    ),
                  ];
                }

                return MultiSliver(children: children);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutritionDataWidgets(
    BuildContext context,
    NutritionContainerHelper nutritionContainer,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<Widget> widgets = <Widget>[
      const NutritionServingSwitch(),
    ];

    final Iterable<OrderedNutrient> displayableNutrients =
        nutritionContainer.getDisplayableNutrients();
    if (_focusNodes.length != displayableNutrients.length) {
      for (final OrderedNutrient nutrient in displayableNutrients) {
        _focusNodes[nutrient] ??= FocusNode();
      }
    }

    final NumberFormat decimalNumberFormat = context.watch<NumberFormat>();

    for (int i = 0; i != displayableNutrients.length; i++) {
      final OrderedNutrient orderedNutrient = displayableNutrients.elementAt(i);

      final Nutrient nutrient = getNutrient(orderedNutrient);
      final Map<Nutrient, TextEditingControllerWithHistory> controllers =
          context.watch<Map<Nutrient, TextEditingControllerWithHistory>>();

      if (controllers[nutrient] == null) {
        final double? value = nutritionContainer.getValue(nutrient);
        controllers[nutrient] = TextEditingControllerWithHistory(
          text: value == null ? '' : decimalNumberFormat.format(value),
        );
      }

      widgets.add(
        ChangeNotifierProvider<TextEditingControllerWithHistory>.value(
          value: controllers[nutrient]!,
          child: NutrientRow(
            nutritionContainer: nutritionContainer,
            decimalNumberFormat: decimalNumberFormat,
            orderedNutrient: orderedNutrient,
            position: i,
            isLast: i == displayableNutrients.length - 1,
            highlighted: _nutrientToHighlight == orderedNutrient,
          ),
        ),
      );
    }

    widgets.add(NutritionAddNutrientButton(
      onNutrientSelected: (final OrderedNutrient nutrient) {
        setState(() => _nutrientToHighlight = nutrient);
      },
    ));

    if (_nutrientToHighlight != null) {
      final FocusNode focusNode = _focusNodes[_nutrientToHighlight]!;
      onNextFrame(() {
        return focusNode.requestFocus();
      });
      _nutrientToHighlight = null;
    }

    return SliverPadding(
      padding: const EdgeInsetsDirectional.only(
        start: MEDIUM_SPACE,
        end: MEDIUM_SPACE,
        bottom: MEDIUM_SPACE,
      ),
      sliver: SliverCardWithRoundedHeader(
        title: appLocalizations.edit_product_form_item_nutrition_facts_title,
        leading: const NutritionFacts(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            NutritionAddNutrientHeaderButton(
              onNutrientSelected: (final OrderedNutrient nutrient) {
                setState(() => _nutrientToHighlight = nutrient);
              },
            ),
            ExplanationTitleIcon(
              title:
                  appLocalizations.edit_product_form_item_nutrition_facts_title,
              text: appLocalizations
                  .edit_product_form_item_nutrition_facts_explanation,
            ),
          ],
        ),
        contentPadding: EdgeInsets.zero,
        child: Column(
          children: widgets,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final FocusNode node in _focusNodes.values) {
      node.dispose();
    }
    _focusNodes.clear();

    super.dispose();
  }
}

// cf. https://github.com/openfoodfacts/smooth-app/issues/3387
Nutrient getNutrient(final OrderedNutrient orderedNutrient) {
  if (orderedNutrient.nutrient != null) {
    return orderedNutrient.nutrient!;
  }
  if (orderedNutrient.id == 'energy') {
    return Nutrient.energyKJ;
  }
  throw Exception('unknown nutrient for "${orderedNutrient.id}"');
}
