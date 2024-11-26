import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/language_priority.dart';
import 'package:smooth_app/generic_lib/widgets/language_selector.dart';
import 'package:smooth_app/helpers/border_radius_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/preferences/user_preferences_languages_list.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_tabbar.dart';

class ProductImageGalleryTabBar extends StatefulWidget
    implements PreferredSizeWidget {
  const ProductImageGalleryTabBar({
    required this.padding,
    required this.onTabChanged,
  });

  final EdgeInsetsGeometry padding;
  final void Function(OpenFoodFactsLanguage) onTabChanged;

  @override
  State<ProductImageGalleryTabBar> createState() =>
      _ProductImageGalleryTabBarState();

  @override
  Size get preferredSize => const Size(
        double.infinity,
        SmoothTabBar.TAB_BAR_HEIGHT + BALANCED_SPACE,
      );
}

class _ProductImageGalleryTabBarState extends State<ProductImageGalleryTabBar>
    with TickerProviderStateMixin {
  late final _ImageGalleryLanguagesProvider _provider;
  late TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _provider = _ImageGalleryLanguagesProvider()..addListener(_updateListener);
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: widget.preferredSize,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: BALANCED_SPACE),
        child: Listener<Product>(
            listener: (BuildContext context, _, Product product) {
              _provider.attachProduct(product);
            },
            child: ChangeNotifierProvider<_ImageGalleryLanguagesProvider>(
              create: (_) => _provider,
              child: Consumer<_ImageGalleryLanguagesProvider>(
                builder: (
                  final BuildContext context,
                  final _ImageGalleryLanguagesProvider provider,
                  _,
                ) {
                  if (provider.value.languages == null) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  /// We need a Stack to have to tab bar shadow below the button
                  return Stack(
                    children: <Widget>[
                      PositionedDirectional(
                        top: 0.0,
                        start: 0.0,
                        bottom: 0.0,
                        end: 40.0,
                        child: SmoothTabBar<OpenFoodFactsLanguage>(
                          tabController: _tabController!,
                          items: provider.value.languages!.map(
                            (final OpenFoodFactsLanguage language) =>
                                SmoothTabBarItem<OpenFoodFactsLanguage>(
                              label: Languages().getNameInLanguage(language),
                              value: language,
                            ),
                          ),
                          onTabChanged: (final OpenFoodFactsLanguage value) {
                            widget.onTabChanged.call(value);
                          },
                          padding: widget.padding.add(
                            const EdgeInsetsDirectional.only(
                              end: 20.0,
                            ),
                          ),
                        ),
                      ),
                      const PositionedDirectional(
                        top: 0.0,
                        end: 0.0,
                        bottom: 0.0,
                        child: _ImageGalleryAddLanguageButton(),
                      ),
                    ],
                  );
                },
              ),
            )),
      ),
    );
  }

  void _updateListener() {
    final _ImageGalleryLanguagesState value = _provider.value;

    if (value.languages != null) {
      final int initialIndex = _tabController?.index ?? -1;
      final int newIndex = value.selectedLanguage != null
          ? value.languages!.indexOf(value.selectedLanguage!)
          : initialIndex;

      if (_tabController?.length != value.languages!.length) {
        _tabController = TabController(
          length: value.languages!.length,
          vsync: this,
          initialIndex: newIndex >= 0 ? newIndex : 0,
        );
      } else if (newIndex >= 0 && _tabController!.index != newIndex) {
        onNextFrame(() {
          _tabController!.animateTo(newIndex);
          _provider.newLanguageSuccessfullyChanged();
        });
      }

      if (value.initialValue || (newIndex >= 0 && initialIndex != newIndex)) {
        widget.onTabChanged.call(value.selectedLanguage!);
      }
    }
  }
}

class _ImageGalleryAddLanguageButton extends StatelessWidget {
  const _ImageGalleryAddLanguageButton();

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final BorderRadius borderRadius = BorderRadiusHelper.fromDirectional(
      context: context,
      topStart: const Radius.circular(10.0),
    );

    final String label = AppLocalizations.of(context).product_add_a_language;

    return Semantics(
      label: label,
      button: true,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border(
              bottom: BorderSide(
                color: lightTheme ? theme.primarySemiDark : theme.primaryDark,
                width: lightTheme ? 1.5 : 2.0,
              ),
            ),
            color: lightTheme ? theme.primaryDark : theme.primaryNormal,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: () => _addLanguage(context),
              child: const Padding(
                padding: EdgeInsetsDirectional.only(
                  start: LARGE_SPACE,
                  end: MEDIUM_SPACE,
                ),
                child: Add(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addLanguage(BuildContext context) async {
    // TODO(g123k): Improve the language selector
    final DaoStringList daoStringList =
        DaoStringList(context.read<LocalDatabase>());

    final List<OpenFoodFactsLanguage>? selectedLanguages =
        context.read<_ImageGalleryLanguagesProvider>().value.languages;

    final LanguagePriority languagePriority = LanguagePriority(
      product: context.read<Product>(),
      selectedLanguages: selectedLanguages,
      daoStringList: daoStringList,
    );

    final OpenFoodFactsLanguage? language =
        await LanguageSelector.openLanguageSelector(
      context,
      selectedLanguages: selectedLanguages,
      languagePriority: languagePriority,
    );

    if (language != null && context.mounted) {
      context.read<_ImageGalleryLanguagesProvider>().addLanguage(language);
    }
  }
}

class _ImageGalleryLanguagesProvider
    extends ValueNotifier<_ImageGalleryLanguagesState> {
  _ImageGalleryLanguagesProvider()
      : super(const _ImageGalleryLanguagesState.empty());

  Product? product;

  void attachProduct(final Product product) {
    if (product != this.product) {
      this.product = product;
      refreshLanguages(initial: true);
    }
  }

  void refreshLanguages({bool initial = false}) {
    final List<OpenFoodFactsLanguage> imageLanguages = <OpenFoodFactsLanguage>{
      ...getProductImageLanguages(product!, ImageField.FRONT),
      ...getProductImageLanguages(product!, ImageField.INGREDIENTS),
      ...getProductImageLanguages(product!, ImageField.NUTRITION),
      ...getProductImageLanguages(product!, ImageField.PACKAGING),
    }.toList(growable: false)
      ..sort((final OpenFoodFactsLanguage a, final OpenFoodFactsLanguage b) {
        return a.code.compareTo(b.code);
      });

    /// The main language is always the first, then the user one
    final OpenFoodFactsLanguage userLanguage = ProductQuery.getLanguage();
    final OpenFoodFactsLanguage? mainLanguage = product!.lang;

    final List<OpenFoodFactsLanguage> languages = <OpenFoodFactsLanguage>[];

    if (mainLanguage != null) {
      languages.add(mainLanguage);
    }

    if (mainLanguage != userLanguage) {
      languages.add(userLanguage);
    }

    for (final OpenFoodFactsLanguage language in imageLanguages) {
      if (language != mainLanguage && language != userLanguage) {
        languages.add(language);
      }
    }

    if (!const ListEquality<OpenFoodFactsLanguage>()
        .equals(value.languages, languages)) {
      value = _ImageGalleryLanguagesState(
        languages: languages,
        selectedLanguage: mainLanguage ?? userLanguage,
        initialValue: initial,
      );
    }
  }

  void addLanguage(OpenFoodFactsLanguage language) {
    if (value.languages == null) {
      throw Exception('Languages are not loaded');
    }

    if (value.languages!.contains(language)) {
      value = _ImageGalleryLanguagesState(
        languages: value.languages,
        selectedLanguage: language,
      );
    } else {
      value = _ImageGalleryLanguagesState(
        languages: <OpenFoodFactsLanguage>[...value.languages!, language],
        selectedLanguage: language,
        hasNewLanguage: true,
      );
    }
  }

  /// Generate a state with [hasNewLanguage] set to false
  void newLanguageSuccessfullyChanged() {
    value = _ImageGalleryLanguagesState(
      languages: value.languages,
      selectedLanguage: value.selectedLanguage,
      hasNewLanguage: false,
    );
  }
}

class _ImageGalleryLanguagesState {
  _ImageGalleryLanguagesState({
    required this.languages,
    required this.selectedLanguage,
    this.hasNewLanguage = false,
    this.initialValue = false,
  }) : assert(
          selectedLanguage == null || languages!.contains(selectedLanguage),
        );

  const _ImageGalleryLanguagesState.empty()
      : languages = null,
        selectedLanguage = null,
        hasNewLanguage = false,
        initialValue = false;

  final List<OpenFoodFactsLanguage>? languages;
  final OpenFoodFactsLanguage? selectedLanguage;
  final bool initialValue;
  final bool hasNewLanguage;
}
