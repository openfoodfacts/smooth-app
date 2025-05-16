import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/languages_selector.dart';
import 'package:smooth_app/helpers/border_radius_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/preferences/user_preferences_languages_list.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_tabbar.dart';

class EditLanguageTabBar extends StatefulWidget {
  const EditLanguageTabBar({
    super.key,
    required this.productEquality,
    required this.productLanguages,
    required this.onTabChanged,
    required this.forceUserLanguage,
    this.defaultLanguageMissingState = OpenFoodFactsLanguageState.warning,
    this.mainLanguageMissingState = OpenFoodFactsLanguageState.warning,
    this.userLanguageMissingState,
    this.languageIndicatorNormal,
    this.languageIndicatorWarning,
    this.languageIndicatorError,
    this.showLanguageIndicator = true,
    this.padding = const EdgeInsetsDirectional.only(start: 55.0),
  });

  const EditLanguageTabBar.noIndicator({
    super.key,
    required this.productEquality,
    required this.productLanguages,
    required this.onTabChanged,
    required this.forceUserLanguage,
    this.padding = const EdgeInsetsDirectional.only(start: 55.0),
  })  : defaultLanguageMissingState = OpenFoodFactsLanguageState.normal,
        mainLanguageMissingState = OpenFoodFactsLanguageState.normal,
        userLanguageMissingState = OpenFoodFactsLanguageState.normal,
        languageIndicatorNormal = null,
        languageIndicatorWarning = null,
        languageIndicatorError = null,
        showLanguageIndicator = false;

  /// Compare two products to know if they are the same
  final DidProductChanged productEquality;

  /// Return all languages of a product (eg: a gallery may return all languages
  /// of its images)
  final ProductLanguagesProvider productLanguages;
  final void Function(OpenFoodFactsLanguage language) onTabChanged;

  /// Force the user language even if it is not in the list
  final bool forceUserLanguage;

  /// When the main language is missing, how should it be displayed (normal/error/warning)
  final OpenFoodFactsLanguageState mainLanguageMissingState;

  /// When the user language is missing, how should it be displayed (normal/error/warning)
  final OpenFoodFactsLanguageState? userLanguageMissingState;

  /// When a language is added (= incomplete), how should it be considered?
  final OpenFoodFactsLanguageState defaultLanguageMissingState;

  /// Show an indicator next to the language only if
  /// [languageIndicatorNormal], [languageIndicatorWarning] or
  /// [languageIndicatorError] are not null
  final bool showLanguageIndicator;

  final Widget? languageIndicatorNormal;
  final Widget? languageIndicatorWarning;
  final Widget? languageIndicatorError;

  final EdgeInsetsGeometry padding;

  static const Size PREFERRED_SIZE = Size(
    double.infinity,
    SmoothTabBar.TAB_BAR_HEIGHT + BALANCED_SPACE,
  );

  @override
  State<EditLanguageTabBar> createState() => _EditLanguageTabBarState();
}

class _EditLanguageTabBarState extends State<EditLanguageTabBar>
    with TickerProviderStateMixin {
  late final _EditLanguageProvider _provider;
  late TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _provider = _EditLanguageProvider(
      productEquality: widget.productEquality,
      languagesProvider: widget.productLanguages,
      forceUserLanguage: widget.forceUserLanguage,
      defaultLanguageMissingState: widget.defaultLanguageMissingState,
      mainLanguageMissingState: widget.mainLanguageMissingState,
      userLanguageMissingState: widget.userLanguageMissingState,
    )..addListener(_updateListener);
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: EditLanguageTabBar.PREFERRED_SIZE,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: BALANCED_SPACE),
        child: Listener<Product>(
            listener: (BuildContext context, _, Product product) {
              _provider.attachProduct(product);
            },
            child: ChangeNotifierProvider<_EditLanguageProvider>(
              create: (_) => _provider,
              child: Consumer<_EditLanguageProvider>(
                builder: (
                  final BuildContext context,
                  final _EditLanguageProvider provider,
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
                          leadingItems: widget.showLanguageIndicator
                              ? provider.value.languagesStates!.map(
                                  (final OpenFoodFactsLanguageState state) {
                                    switch (state) {
                                      case OpenFoodFactsLanguageState.normal:
                                        return widget.languageIndicatorNormal;
                                      case OpenFoodFactsLanguageState.warning:
                                        return widget
                                                .languageIndicatorWarning ??
                                            const icons.Warning();
                                      case OpenFoodFactsLanguageState.error:
                                        return widget.languageIndicatorError ??
                                            const icons.Warning();
                                    }
                                  },
                                )
                              : null,
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
                        child: _EditLanguageTabBarAddLanguageButton(),
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
    final _EditLanguageTabBarProviderState value = _provider.value;

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

class _EditLanguageTabBarAddLanguageButton extends StatelessWidget {
  const _EditLanguageTabBarAddLanguageButton();

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
            color: lightTheme ? theme.primaryBlack : theme.primaryNormal,
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
                child: icons.Add(
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
    final List<OpenFoodFactsLanguage>? selectedLanguages =
        context.read<_EditLanguageProvider>().value.languages;

    final OpenFoodFactsLanguage? language =
        await LanguagesSelector.openLanguageSelector(
      context,
      selectedLanguages: selectedLanguages,
    );

    if (language != null && context.mounted) {
      context.read<_EditLanguageProvider>().addLanguage(language);
    }
  }
}

class _EditLanguageProvider
    extends ValueNotifier<_EditLanguageTabBarProviderState> {
  _EditLanguageProvider({
    required this.productEquality,
    required this.languagesProvider,
    required this.forceUserLanguage,
    required this.defaultLanguageMissingState,
    required this.mainLanguageMissingState,
    this.userLanguageMissingState,
  }) : super(const _EditLanguageTabBarProviderState.empty());

  final DidProductChanged productEquality;
  final ProductLanguagesProvider languagesProvider;
  final bool forceUserLanguage;
  final OpenFoodFactsLanguageState defaultLanguageMissingState;
  final OpenFoodFactsLanguageState mainLanguageMissingState;
  final OpenFoodFactsLanguageState? userLanguageMissingState;

  Product? product;

  void attachProduct(final Product product) {
    if (!equalsProduct(product)) {
      this.product = product;
      refreshLanguages(initial: true);
    }
  }

  void refreshLanguages({bool initial = false}) {
    final (
      List<OpenFoodFactsLanguage> imageLanguages,
      List<OpenFoodFactsLanguageState> languagesStates
    ) = _extractLanguages();

    final OpenFoodFactsLanguage userLanguage = ProductQuery.getLanguage();
    final OpenFoodFactsLanguage? mainLanguage = product!.lang;

    final List<OpenFoodFactsLanguage> languages = <OpenFoodFactsLanguage>[];
    final List<OpenFoodFactsLanguageState> states =
        <OpenFoodFactsLanguageState>[];

    /// The main language is always the first
    if (mainLanguage != null) {
      final int index = imageLanguages.indexOf(mainLanguage);

      languages.add(mainLanguage);
      states.add(
        index >= 0 ? languagesStates[index] : mainLanguageMissingState,
      );
    }

    /// Then, inject the user language
    /// - Forced even if it is not in the list with [forceUserLanguage]
    /// - Or if it is in the list
    if (mainLanguage != userLanguage) {
      final int index = imageLanguages.indexOf(userLanguage);

      if (mainLanguage == OpenFoodFactsLanguage.UNKNOWN_LANGUAGE &&
          userLanguage == OpenFoodFactsLanguage.ENGLISH) {
        Logs.d(
          'This product has a main unknown language, considering it as English',
        );
      } else {
        if (forceUserLanguage || index >= 0) {
          languages.add(userLanguage);
          states.add(
            index >= 0
                ? languagesStates[index]
                : userLanguageMissingState ?? mainLanguageMissingState,
          );
        }
      }
    }

    for (int i = 0; i < imageLanguages.length; i++) {
      if (imageLanguages[i] != mainLanguage &&
          imageLanguages[i] != userLanguage) {
        languages.add(imageLanguages[i]);
        states.add(languagesStates[i]);
      }
    }

    if (!const ListEquality<OpenFoodFactsLanguage>()
        .equals(value.languages, languages)) {
      value = _EditLanguageTabBarProviderState(
        languages: languages,
        languagesStates: states,
        selectedLanguage: mainLanguage ?? userLanguage,
        initialValue: initial,
      );
    }
  }

  (
    List<OpenFoodFactsLanguage>,
    List<OpenFoodFactsLanguageState>,
  ) _extractLanguages() {
    final List<ProductLanguageWithState> imageLanguagesWithState =
        languagesProvider(product!)
          ..sort((final ProductLanguageWithState a,
              final ProductLanguageWithState b) {
            return a.code.compareTo(b.code);
          });

    final List<OpenFoodFactsLanguage> imageLanguages =
        <OpenFoodFactsLanguage>[];
    final List<OpenFoodFactsLanguageState> languagesStates =
        <OpenFoodFactsLanguageState>[];

    for (final ProductLanguageWithState language in imageLanguagesWithState) {
      imageLanguages.add(language.language);
      languagesStates.add(language.state);
    }

    return (imageLanguages, languagesStates);
  }

  void addLanguage(OpenFoodFactsLanguage language) {
    if (value.languages == null) {
      throw Exception('Languages are not loaded');
    }

    if (value.languages!.contains(language)) {
      value = _EditLanguageTabBarProviderState(
        languages: value.languages,
        languagesStates: value.languagesStates,
        selectedLanguage: language,
      );
    } else {
      value = _EditLanguageTabBarProviderState(
        languages: <OpenFoodFactsLanguage>[...value.languages!, language],
        languagesStates: <OpenFoodFactsLanguageState>[
          ...value.languagesStates!,
          defaultLanguageMissingState,
        ],
        selectedLanguage: language,
        hasNewLanguage: true,
      );
    }
  }

  /// Generate a state with [hasNewLanguage] set to false
  void newLanguageSuccessfullyChanged() {
    value = _EditLanguageTabBarProviderState(
      languages: value.languages,
      languagesStates: value.languagesStates,
      selectedLanguage: value.selectedLanguage,
      hasNewLanguage: false,
    );
  }

  bool equalsProduct(Product product) {
    if (this.product == null) {
      return false;
    }

    return productEquality(this.product!, product);
  }
}

class _EditLanguageTabBarProviderState {
  _EditLanguageTabBarProviderState({
    required this.languages,
    required this.languagesStates,
    required this.selectedLanguage,
    this.hasNewLanguage = false,
    this.initialValue = false,
  })  : assert(
          selectedLanguage == null || languages!.contains(selectedLanguage),
        ),
        assert(
          languagesStates == null && languages == null ||
              languagesStates != null &&
                  languages != null &&
                  languagesStates.length == languages.length,
        );

  const _EditLanguageTabBarProviderState.empty()
      : languages = null,
        languagesStates = null,
        selectedLanguage = null,
        hasNewLanguage = false,
        initialValue = false;

  final List<OpenFoodFactsLanguage>? languages;
  final List<OpenFoodFactsLanguageState>? languagesStates;
  final OpenFoodFactsLanguage? selectedLanguage;
  final bool initialValue;
  final bool hasNewLanguage;
}

typedef DidProductChanged = bool Function(
  Product oldProduct,
  Product newProduct,
);
typedef ProductLanguagesProvider = List<ProductLanguageWithState> Function(
  Product product,
);

@immutable
class ProductLanguageWithState {
  const ProductLanguageWithState({
    required this.language,
    required this.state,
  });

  const ProductLanguageWithState.normal({
    required this.language,
  }) : state = OpenFoodFactsLanguageState.normal;

  final OpenFoodFactsLanguage language;
  final OpenFoodFactsLanguageState state;

  String get code => language.code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductLanguageWithState &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          state == other.state;

  @override
  int get hashCode => language.hashCode ^ state.hashCode;
}

enum OpenFoodFactsLanguageState {
  normal,
  warning,
  error,
}
