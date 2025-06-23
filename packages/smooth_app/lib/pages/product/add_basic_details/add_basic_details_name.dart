import 'dart:io';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/languages_selector.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/paint_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/input/debounced_text_editing_controller.dart';
import 'package:smooth_app/pages/preferences/user_preferences_languages_list.dart';
import 'package:smooth_app/pages/product/gallery_view/product_image_gallery_view.dart';
import 'package:smooth_app/pages/product/multilingual_helper.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_explanation_banner.dart';
import 'package:smooth_app/widgets/smooth_text.dart';
import 'package:smooth_app/widgets/widget_height.dart';

/// Widget to edit the product name in multiple languages
class AddProductNameInputWidget extends StatefulWidget {
  const AddProductNameInputWidget({
    required this.product,
    required this.onShowImagePreview,
    super.key,
  });

  final Product product;
  final Function(
    ImageField imageField,
    OpenFoodFactsLanguage language,
  ) onShowImagePreview;

  @override
  State<AddProductNameInputWidget> createState() =>
      _AddProductNameInputWidgetState();
}

class _AddProductNameInputWidgetState extends State<AddProductNameInputWidget> {
  final Map<OpenFoodFactsLanguage, DebouncedTextEditingController>
      _controllers = <OpenFoodFactsLanguage, DebouncedTextEditingController>{};

  static const int MIN_COLLAPSED_COUNT = 3;

  bool _collapsed = true;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Provider<Product>(
      create: (_) => widget.product,
      child: SmoothCardWithRoundedHeader(
        title: appLocalizations.product_names,
        leading: const icons.Milk.happy(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.product.hasOwnerField(ProductField.NAME_IN_LANGUAGES))
              const OwnerFieldSmoothCardIcon(),
            const _ProductNameAddNewLanguage(),
            const _ProductNameExplanation(),
          ],
        ),
        contentPadding: EdgeInsets.zero,
        child: ValueNotifierListener<ProductNameEditorProvider,
            _ProductNameEditorProviderState>(
          listener: (
            final BuildContext context,
            _ProductNameEditorProviderState? oldValue,
            _ProductNameEditorProviderState value,
          ) {
            if (oldValue?.productNames.length != value.productNames.length) {
              for (final _EditingProductName productName
                  in value.productNames) {
                if (!_controllers.containsKey(productName.language)) {
                  _controllers[productName.language] =
                      DebouncedTextEditingController(
                    controller: TextEditingController(text: productName.name)
                      ..addListener(
                        () {
                          context
                              .read<ProductNameEditorProvider>()
                              .onNameChanged(
                                productName.language,
                                _controllers[productName.language]!.text,
                              );
                        },
                      ),
                  );
                }
              }
            }
          },
          child: ConsumerValueNotifierFilter<ProductNameEditorProvider,
              _ProductNameEditorProviderState>(
            buildWhen: (_ProductNameEditorProviderState? oldValue,
                    _ProductNameEditorProviderState value) =>
                oldValue?.productNames.length != value.productNames.length ||
                oldValue?.addedLanguages.length != value.addedLanguages.length,
            builder: (
              final BuildContext context,
              final _ProductNameEditorProviderState value,
              _,
            ) {
              final int count = _collapsed
                  ? math.min(
                      value.productNames.length - value.addedLanguages.length,
                      MIN_COLLAPSED_COUNT)
                  : value.productNames.length;

              final bool collapsed = _collapsed &&
                  value.productNames.length - value.addedLanguages.length >
                      MIN_COLLAPSED_COUNT;

              return Column(
                children: <Widget>[
                  ...value.productNames.sublist(0, count).map(
                        (_EditingProductName productName) =>
                            _ProductNameInputWidget(
                          productName: productName,
                          controller: _controllers[productName.language]!,
                          onShowImagePreview: () {
                            widget.onShowImagePreview(
                              ImageField.FRONT,
                              productName.language,
                            );
                          },
                        ),
                      ),
                  if (value.addedLanguages.isNotEmpty &&
                      _collapsed) ...<Widget>[
                    const _ProductNameNewTranslationWarning(),
                    ...value.productNames
                        .sublist(value.productNames.length -
                            value.addedLanguages.length)
                        .map(
                          (_EditingProductName productName) =>
                              _ProductNameInputWidget(
                            productName: productName,
                            controller: _controllers[productName.language]!,
                            onShowImagePreview: () {
                              widget.onShowImagePreview(
                                ImageField.FRONT,
                                productName.language,
                              );
                            },
                          ),
                        ),
                  ],
                  if (collapsed)
                    _ProductNameCollapsedSection(
                      onTap: () => setState(() {
                        _collapsed = false;
                      }),
                    )
                  else
                    const SizedBox(height: BALANCED_SPACE),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final DebouncedTextEditingController controller
        in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }
}

class _ProductNameAddNewLanguage extends StatelessWidget {
  const _ProductNameAddNewLanguage();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return IconButton(
      icon: const icons.Add.circled(),
      tooltip: appLocalizations.add_basic_details_product_name_add_translation,
      onPressed: () => _openLanguagePicker(context),
    );
  }

  Future<void> _openLanguagePicker(BuildContext context) async {
    final ProductNameEditorProvider provider =
        context.read<ProductNameEditorProvider>();

    final List<OpenFoodFactsLanguage> selectedLanguages = provider
        .value.productNames
        .map((final _EditingProductName productName) => productName.language)
        .toList(growable: false);

    final OpenFoodFactsLanguage? language =
        await LanguagesSelector.openLanguageSelector(
      context,
      selectedLanguages: selectedLanguages,
      title: AppLocalizations.of(context)
          .add_basic_details_product_name_add_translation,
    );

    if (language != null) {
      provider.addLanguage(language);
    }
  }
}

class _ProductNameInputWidget extends StatefulWidget {
  const _ProductNameInputWidget({
    required this.productName,
    required this.controller,
    required this.onShowImagePreview,
  });

  final _EditingProductName productName;
  final TextEditingController controller;
  final VoidCallback onShowImagePreview;

  @override
  State<_ProductNameInputWidget> createState() =>
      _ProductNameInputWidgetState();
}

class _ProductNameInputWidgetState extends State<_ProductNameInputWidget> {
  bool _photoTaken = false;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return KeyedSubtree(
      key: ValueKey<OpenFoodFactsLanguage>(widget.productName.language),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: BALANCED_SPACE,
          start: 11.0,
          end: 8.0,
        ),
        child: IconButtonTheme(
          data: const IconButtonThemeData(
            style: ButtonStyle(
              fixedSize: WidgetStatePropertyAll<Size>(Size.square(40.0)),
              iconSize: WidgetStatePropertyAll<double>(24.0),
              padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
                EdgeInsetsDirectional.all(SMALL_SPACE),
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Tooltip(
                    message: Languages().getNameInEnglish(
                      widget.productName.language,
                    ),
                    child: CircleAvatar(
                      backgroundColor: lightTheme
                          ? extension.primaryMedium
                          : extension.primarySemiDark,
                      child: AutoSizeText(
                        widget.productName.language.offTag.toUpperCase(),
                        style: TextStyle(
                          color: lightTheme
                              ? extension.primaryDark
                              : extension.primaryLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: SmoothTextFormField(
                    controller: widget.controller,
                    type: TextFieldTypes.PLAIN_TEXT,
                    textCapitalization: TextCapitalization.sentences,
                    hintText:
                        appLocalizations.add_basic_details_product_name_hint,
                    hintTextStyle:
                        SmoothTextFormField.defaultHintTextStyle(context),
                    borderRadius: CIRCULAR_BORDER_RADIUS,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: LARGE_SPACE,
                      vertical: 10.5,
                    ),
                    allowEmojis: false,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 2.0),
                if (widget.productName.hasPhoto || _photoTaken)
                  IconButton(
                    icon: icons.Picture.check(
                      color: extension.success,
                    ),
                    tooltip: appLocalizations
                        .add_basic_details_product_name_open_photo,
                    onPressed: widget.onShowImagePreview,
                  )
                else
                  IconButton(
                    icon: icons.Picture.add(
                      color: lightTheme
                          ? extension.primaryDark
                          : extension.primaryNormal,
                    ),
                    tooltip: appLocalizations
                        .add_basic_details_product_name_take_photo,
                    onPressed: () => _takePicture(context),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _takePicture(BuildContext context) async {
    final File? file = await ProductImageGalleryView.takePicture(
      context: context,
      product: context.read<Product>(),
      language: widget.productName.language,
      imageField: ImageField.FRONT,
      pictureSource: UserPictureSource.SELECT,
    );

    if (file != null) {
      setState(() => _photoTaken = true);
    }
  }
}

class _ProductNameCollapsedSection extends StatelessWidget {
  const _ProductNameCollapsedSection({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final _ProductNameEditorProviderState state =
        context.watch<ProductNameEditorProvider>().value;
    final int count = state.productNames.length -
        (math.min(state.productNames.length,
                _AddProductNameInputWidgetState.MIN_COLLAPSED_COUNT) +
            state.addedLanguages.length);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: BALANCED_SPACE),
        CustomPaint(
          foregroundPainter: DashedLinePainter(
            color: extension.primaryMedium,
            dashGap: 4.0,
            dashSpace: 4.0,
          ),
          size: const Size(double.infinity, 1.0),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: ROUNDED_RADIUS,
                bottomRight: ROUNDED_RADIUS,
              ),
              color: lightTheme
                  ? extension.primaryLight
                  : extension.primarySemiDark,
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.only(
                bottomLeft: ROUNDED_RADIUS,
                bottomRight: ROUNDED_RADIUS,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: SMALL_SPACE,
                ),
                child: icons.AppIconTheme(
                  color: lightTheme
                      ? extension.greyMedium
                      : extension.primaryLight,
                  size: 8.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const icons.DoubleChevron.down(),
                      const SizedBox(width: SMALL_SPACE),
                      Text(
                        AppLocalizations.of(context)
                            .add_basic_details_product_name_other_translations(
                          count,
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontStyle: FontStyle.italic,
                          color: lightTheme
                              ? extension.primaryDark
                              : extension.primaryMedium,
                        ),
                      ),
                      const SizedBox(width: MEDIUM_SPACE),
                      const icons.DoubleChevron.down(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductNameExplanation extends StatelessWidget {
  const _ProductNameExplanation();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ExplanationTitleIcon(
      title: appLocalizations.add_basic_details_product_name_help_title,
      safeArea: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ExplanationBodyInfo(
            text: appLocalizations.add_basic_details_product_name_help_info1,
            icon: false,
          ),
          ExplanationGoodExamplesContainer(
            items: <String>[
              appLocalizations
                  .add_basic_details_product_name_help_good_examples_1,
              appLocalizations
                  .add_basic_details_product_name_help_good_examples_2,
            ],
          ),
          const SizedBox(height: SMALL_SPACE),
          ExplanationBadExamplesContainer(
            items: <String>[
              appLocalizations
                  .add_basic_details_product_name_help_bad_examples_1_example,
              appLocalizations
                  .add_basic_details_product_name_help_bad_examples_2_example,
            ],
            explanations: <String>[
              appLocalizations
                  .add_basic_details_product_name_help_bad_examples_1_explanation,
              appLocalizations
                  .add_basic_details_product_name_help_bad_examples_2_explanation,
            ],
          ),
          const SizedBox(height: VERY_LARGE_SPACE),
          ExplanationBodyInfo(
            text: appLocalizations.add_basic_details_product_name_help_info2,
            safeArea: true,
          ),
        ],
      ),
    );
  }
}

class _ProductNameNewTranslationWarning extends StatefulWidget {
  const _ProductNameNewTranslationWarning();

  @override
  State<_ProductNameNewTranslationWarning> createState() =>
      _ProductNameNewTranslationWarningState();
}

class _ProductNameNewTranslationWarningState
    extends State<_ProductNameNewTranslationWarning>
    with SingleTickerProviderStateMixin {
  /// Animation to hide the banner
  AnimationController? _controller;
  Animation<double>? _animation;
  Size? _size;

  @override
  Widget build(BuildContext context) {
    if (!context.watch<UserPreferences>().showInputProductNameBanner()) {
      return EMPTY_WIDGET;
    }

    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    double? height;
    if (_size != null && _animation != null) {
      height = _size!.height - _animation!.value;
    } else {
      height = _size?.height;
    }

    return SizedBox(
      width: _size?.width,
      height: height,
      child: MeasureSize(
        onChange: (Size size) {
          if (size != _size && _controller == null) {
            _size = size;
          }
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.only(top: MEDIUM_SPACE),
          child: Container(
            color: lightTheme ? extension.greyLight : extension.primaryDark,
            child: ClipRRect(
              child: Stack(
                children: <Widget>[
                  PositionedDirectional(
                    bottom: 0.0,
                    start: 0.0,
                    child: ExcludeSemantics(
                      child: Transform.translate(
                        offset: const Offset(-12.0, 07.0),
                        child: icons.Warning(
                          size: 55.0,
                          color: lightTheme
                              ? extension.greyMedium
                              : extension.primaryTone,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 62.0,
                      top: 9.0,
                      bottom: BALANCED_SPACE,
                      end: 17.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: TextWithBoldParts(
                            text: AppLocalizations.of(context)
                                .add_basic_details_product_name_warning_translations,
                            textStyle: const TextStyle(height: 1.6),
                          ),
                        ),
                        const SizedBox(width: VERY_SMALL_SPACE),
                        DecoratedBox(
                          decoration: ShapeDecoration(
                            shape: const CircleBorder(),
                            color: lightTheme
                                ? extension.greyMedium
                                : extension.primaryTone,
                          ),
                          child: Material(
                            type: MaterialType.transparency,
                            child: Tooltip(
                              message: MaterialLocalizations.of(context)
                                  .closeButtonTooltip,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _startAnimation,
                                child: const Padding(
                                  padding:
                                      EdgeInsetsDirectional.all(SMALL_SPACE),
                                  child: icons.Close(
                                    size: 10.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startAnimation() {
    if (_size == null) {
      return;
    }

    _controller = AnimationController(
      duration: SmoothAnimationsDuration.medium,
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((final AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          context.read<UserPreferences>().hideInputProductNameBanner();
        }
      });
    _animation = Tween<double>(begin: 0.0, end: _size!.height).animate(
      CurvedAnimation(curve: Curves.easeInOutCubic, parent: _controller!),
    );
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class ProductNameEditorProvider
    extends ValueNotifier<_ProductNameEditorProviderState> {
  ProductNameEditorProvider()
      : super(
          _ProductNameEditorProviderState.init(),
        );

  void loadLanguages({
    required final Product product,
    final ImageField? imageField,
    OpenFoodFactsLanguage? userLanguage,
  }) {
    final Map<OpenFoodFactsLanguage, String> localizedNames =
        <OpenFoodFactsLanguage, String>{};
    final List<_EditingProductName> productNames = <_EditingProductName>[];

    // Add existing languages
    final Map<OpenFoodFactsLanguage, String>? multilingualTexts =
        product.productNameInLanguages;
    if (multilingualTexts != null) {
      for (final OpenFoodFactsLanguage language in multilingualTexts.keys) {
        final String name =
            MultilingualHelper.getCleanText(multilingualTexts[language]);
        if (name.isNotEmpty) {
          localizedNames[language] = name;
        }
      }
    }

    /// Add photos without name
    if (product.selectedImages != null && imageField != null) {
      for (final ProductImage image in product.images!) {
        if (image.field == imageField) {
          if (image.language != null &&
              !productNames.any((final _EditingProductName productName) =>
                  productName.language == image.language)) {
            final OpenFoodFactsLanguage language = image.language!;

            if (localizedNames.containsKey(language)) {
              productNames.add(
                _EditingProductName.initial(
                  language: language,
                  initialName: localizedNames[language]!,
                  hasPhoto: true,
                ),
              );
            } else {
              productNames.add(
                _EditingProductName.initial(
                  language: language,
                  initialName: '',
                  hasPhoto: true,
                ),
              );
            }
          }
        }
      }
    }

    /// Add existing languages without photo
    for (final OpenFoodFactsLanguage language in localizedNames.keys) {
      if (!productNames.any((final _EditingProductName productName) =>
          productName.language == language)) {
        productNames.add(
          _EditingProductName.initial(
            language: language,
            initialName: localizedNames[language]!,
            hasPhoto: false,
          ),
        );
      }
    }

    /// Add user language
    if (userLanguage != null) {
      if (!productNames.any((final _EditingProductName productName) =>
          productName.language == userLanguage)) {
        productNames.add(
          _EditingProductName.initial(
            language: userLanguage,
            initialName: '',
            hasPhoto: false,
          ),
        );
      }
    }

    final OpenFoodFactsLanguage? productLanguage = product.lang;
    productNames.sort(
      (final _EditingProductName a, final _EditingProductName b) {
        // Product language is always first
        if (a.language == productLanguage) {
          return -1;
        } else if (b.language == productLanguage) {
          return 1;
        }

        // Then user language
        if (a.language == userLanguage && b.language != productLanguage) {
          return -1;
        } else if (b.language == userLanguage &&
            a.language != productLanguage) {
          return 1;
        }

        return a.language.offTag.compareTo(b.language.offTag);
      },
    );

    value = _ProductNameEditorProviderState(
      productNames: productNames,
      addedLanguages: const <OpenFoodFactsLanguage>[],
    );
  }

  void addLanguage(OpenFoodFactsLanguage language) {
    final List<_EditingProductName> productNames =
        List<_EditingProductName>.from(value.productNames);
    productNames.add(
      _EditingProductName.initial(
        language: language,
        initialName: '',
        hasPhoto: false,
      ),
    );

    value = _ProductNameEditorProviderState(
      productNames: productNames,
      addedLanguages: List<OpenFoodFactsLanguage>.from(value.addedLanguages)
        ..add(language),
    );
  }

  void onNameChanged(
    OpenFoodFactsLanguage language,
    String name,
  ) {
    final List<_EditingProductName> productNames = value.productNames;
    final int index = productNames.indexWhere(
      (final _EditingProductName productName) =>
          productName.language == language,
    );

    if (index >= 0) {
      final List<_EditingProductName> editedProductNames =
          List<_EditingProductName>.from(value.productNames);
      editedProductNames[index] = productNames[index].copyWith(name: name);

      value = _ProductNameEditorProviderState(
        productNames: editedProductNames,
        addedLanguages: value.addedLanguages,
      );
    }
  }

  Map<OpenFoodFactsLanguage, String> getChangedProductNames() {
    final Map<OpenFoodFactsLanguage, String> changedProductNames =
        <OpenFoodFactsLanguage, String>{};

    for (final _EditingProductName productName in value.productNames) {
      if (productName.initialName != productName.name) {
        changedProductNames[productName.language] = productName.name;
      }
    }

    return changedProductNames;
  }

  bool hasChanged() {
    if (value.addedLanguages.isNotEmpty) {
      return true;
    }

    for (final _EditingProductName productName in value.productNames) {
      if (productName.initialName != productName.name) {
        return true;
      }
    }

    return false;
  }
}

@immutable
class _ProductNameEditorProviderState {
  const _ProductNameEditorProviderState({
    required this.productNames,
    required this.addedLanguages,
  });

  _ProductNameEditorProviderState.init()
      : productNames = <_EditingProductName>[],
        addedLanguages = <OpenFoodFactsLanguage>[];

  final List<_EditingProductName> productNames;
  final List<OpenFoodFactsLanguage> addedLanguages;
}

class _EditingProductName {
  _EditingProductName({
    required this.language,
    required this.initialName,
    required this.name,
    required this.hasPhoto,
  });

  _EditingProductName.initial({
    required OpenFoodFactsLanguage language,
    required String initialName,
    required bool hasPhoto,
  }) : this(
          language: language,
          initialName: initialName,
          name: initialName,
          hasPhoto: hasPhoto,
        );

  final OpenFoodFactsLanguage language;
  final String initialName;
  final String name;
  final bool hasPhoto;

  _EditingProductName copyWith({
    OpenFoodFactsLanguage? language,
    String? initialName,
    String? name,
    bool? hasPhoto,
  }) {
    return _EditingProductName(
      language: language ?? this.language,
      initialName: initialName ?? this.initialName,
      name: name ?? this.name,
      hasPhoto: hasPhoto ?? this.hasPhoto,
    );
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _EditingProductName &&
          runtimeType == other.runtimeType &&
          language == other.language;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => language.hashCode;
}
