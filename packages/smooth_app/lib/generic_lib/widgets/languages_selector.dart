import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/pages/preferences/user_preferences_languages_list.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class LanguagesSelector extends StatelessWidget {
  const LanguagesSelector({
    required this.setLanguage,
    this.selectedLanguages,
    this.displayedLanguage,
    this.foregroundColor,
    this.icon,
    this.padding,
    this.borderRadius,
    this.product,
    this.checkedIcon,
  });

  /// What to do when the language is selected.
  final Future<void> Function(OpenFoodFactsLanguage?) setLanguage;

  /// Languages that are already selected (and will be displayed differently).
  final Iterable<OpenFoodFactsLanguage>? selectedLanguages;

  /// Initial language displayed, before even calling the dialog.
  final OpenFoodFactsLanguage? displayedLanguage;

  final Color? foregroundColor;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? checkedIcon;

  /// Product from which we can extract the languages that matter.
  final Product? product;

  static final Languages _languages = Languages();

  @override
  Widget build(BuildContext context) {
    final OpenFoodFactsLanguage language;
    if (displayedLanguage != null) {
      language = displayedLanguage!;
    } else {
      final String currentLanguageCode = ProductQuery.getLanguage().code;
      language = LanguageHelper.fromJson(currentLanguageCode);
    }
    final DaoStringList daoStringList =
        DaoStringList(context.read<LocalDatabase>());

    final TextStyle textStyle = Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: foregroundColor) ??
        TextStyle(color: foregroundColor);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () async {
          final OpenFoodFactsLanguage? language = await openLanguageSelector(
            context,
            selectedLanguages: selectedLanguages,
            showSelectedLanguages: true,
            checkedIcon: checkedIcon,
          );
          if (language != null) {
            await daoStringList.add(
              DaoStringList.keyLanguages,
              language.offTag,
            );
          }
          await setLanguage(language);
        },
        borderRadius: borderRadius ?? ANGULAR_BORDER_RADIUS,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: SMALL_SPACE,
          ).add(padding ?? EdgeInsets.zero),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.language,
                color: foregroundColor,
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
                  child: Text(
                    _getCompleteName(language),
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: textStyle,
                  ),
                ),
              ),
              IconTheme(
                data: IconThemeData(
                  color: foregroundColor ?? textStyle.color,
                ),
                child: icon ?? const Icon(Icons.arrow_drop_down),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the language selected by the user.
  ///
  /// [selectedLanguages] will be displayed first if [showSelectedLanguages] is [true].
  /// Otherwise, they will be filtered
  static Future<OpenFoodFactsLanguage?> openLanguageSelector(
    final BuildContext context, {
    required final Iterable<OpenFoodFactsLanguage>? selectedLanguages,
    final bool showSelectedLanguages = false,
    final Widget? checkedIcon,
    final String? title,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.read<UserPreferences>();

    final List<OpenFoodFactsLanguage> allLanguages =
        _languages.getSupportedLanguagesNameInEnglish();

    /// Take the 3 most popular languages
    final Iterable<MapEntry<String, int>> popularList = userPreferences
        .languagesUsage.entries
        .sorted((final MapEntry<String, int> entry1,
            final MapEntry<String, int> entry2) {
      return entry1.value.compareTo(entry2.value);
    }).take(3);

    final List<OpenFoodFactsLanguage> selectedLanguagesList =
        <OpenFoodFactsLanguage>[];
    final List<OpenFoodFactsLanguage> popularLanguagesList =
        <OpenFoodFactsLanguage>[];
    final List<OpenFoodFactsLanguage> otherLanguagesList =
        <OpenFoodFactsLanguage>[];

    for (final OpenFoodFactsLanguage language in allLanguages) {
      if (selectedLanguages?.contains(language) == true) {
        if (!showSelectedLanguages) {
          continue;
        } else {
          selectedLanguagesList.add(language);
        }
      } else if (popularList.any(
          (final MapEntry<String, int> entry) => entry.key == language.code)) {
        popularLanguagesList.add(language);
      } else {
        otherLanguagesList.add(language);
      }
    }

    final Languages languagesHelper = Languages();
    _sortLanguages(selectedLanguagesList, languagesHelper);
    _sortLanguages(popularLanguagesList, languagesHelper);
    _sortLanguages(otherLanguagesList, languagesHelper);

    final OpenFoodFactsLanguage? language =
        await showSmoothModalSheetForTextField<OpenFoodFactsLanguage>(
      context: context,
      header: SmoothModalSheetHeader(
        title: title ?? appLocalizations.language_selector_title,
        prefix: const SmoothModalSheetHeaderPrefixIndicator(),
        suffix: const SmoothModalSheetHeaderCloseButton(),
      ),
      bodyBuilder: (BuildContext context) {
        return _LanguagesList(
          selectedLanguages: selectedLanguagesList,
          popularLanguages: popularLanguagesList,
          otherLanguages: otherLanguagesList,
          checkedIcon: checkedIcon,
        );
      },
    );

    if (language != null) {
      userPreferences.increaseLanguageUsage(language);
    }

    return language;
  }

  static String _getCompleteName(
    final OpenFoodFactsLanguage language,
  ) {
    final String nameInLanguage = _languages.getNameInLanguage(language);
    final String nameInEnglish = _languages.getNameInEnglish(language);
    return '$nameInLanguage ($nameInEnglish)';
  }

  static void _sortLanguages(
    List<OpenFoodFactsLanguage> languages,
    Languages languagesHelper,
  ) {
    return languages
        .sort((final OpenFoodFactsLanguage a, final OpenFoodFactsLanguage b) {
      return languagesHelper
          .getNameInEnglish(a)
          .compareTo(languagesHelper.getNameInEnglish(b));
    });
  }
}

class _LanguagesList extends StatefulWidget {
  const _LanguagesList({
    required this.selectedLanguages,
    required this.popularLanguages,
    required this.otherLanguages,
    required this.checkedIcon,
  });

  final List<OpenFoodFactsLanguage> selectedLanguages;
  final List<OpenFoodFactsLanguage> popularLanguages;
  final List<OpenFoodFactsLanguage> otherLanguages;
  final Widget? checkedIcon;

  @override
  State<_LanguagesList> createState() => _LanguagesListState();
}

class _LanguagesListState extends State<_LanguagesList> {
  final TextEditingController languageTextController = TextEditingController();

  late List<OpenFoodFactsLanguage> _otherLanguages;
  late List<OpenFoodFactsLanguage> _popularLanguages;
  late List<OpenFoodFactsLanguage> _selectedLanguages;

  @override
  void initState() {
    super.initState();
    _otherLanguages = List<OpenFoodFactsLanguage>.of(widget.otherLanguages);
    _popularLanguages = List<OpenFoodFactsLanguage>.of(widget.popularLanguages);
    _selectedLanguages =
        List<OpenFoodFactsLanguage>.of(widget.selectedLanguages);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    final double keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height *
              (widget.selectedLanguages.isNotEmpty ? 0.4 : 0.3),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerTheme: DividerThemeData(
                color: context.lightTheme() ? null : extension.greyDark,
              ),
            ),
            child: Scrollbar(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int index) {
                  final (OpenFoodFactsLanguage? language, _LanguageType type) =
                      _findItem(index);

                  if (type == _LanguageType.selectedTitle ||
                      type == _LanguageType.popularTitle) {
                    return _buildSection(extension, type, appLocalizations);
                  }

                  return _buildLanguageTile(language, type);
                },
                itemCount: _countItems(),
                shrinkWrap: true,
                separatorBuilder: (_, __) => const Divider(height: 1.0),
                reverse: true,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: MEDIUM_SPACE,
            vertical: SMALL_SPACE,
          ),
          child: SmoothTextFormField(
            prefixIcon: const Icon(Icons.search),
            autofocus: true,
            hintText: appLocalizations.search,
            type: TextFieldTypes.PLAIN_TEXT,
            allowEmojis: false,
            maxLines: 1,
            controller: languageTextController,
            onChanged: (String? query) {
              if (query != null) {
                _filterLanguages(query);
              }
            },
          ),
        ),

        /// Keyboard height or status bar height
        SizedBox(
          height: keyboardHeight > 0.0
              ? keyboardHeight
              : MediaQuery.viewPaddingOf(context).bottom,
        )
      ],
    );
  }

  Container _buildSection(
    SmoothColorsThemeExtension extension,
    _LanguageType type,
    AppLocalizations appLocalizations,
  ) {
    return Container(
      color: context.lightTheme()
          ? extension.primaryMedium
          : extension.primarySemiDark,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: VERY_LARGE_SPACE,
        vertical: VERY_SMALL_SPACE,
      ),
      child: Text(
        type == _LanguageType.selectedTitle
            ? appLocalizations.language_selector_section_selected
            : appLocalizations.language_selector_section_frequently_used,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  ListTile _buildLanguageTile(
    OpenFoodFactsLanguage? language,
    _LanguageType type,
  ) {
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: VERY_LARGE_SPACE,
      ),
      minTileHeight: 50.0,
      title: TextHighlighter(
        text: LanguagesSelector._getCompleteName(language!),
        filter: languageTextController.text,
      ),
      trailing: switch (type) {
        _LanguageType.selected =>
          widget.checkedIcon ?? const Icon(Icons.check_rounded),
        _LanguageType.popular => const Icon(Icons.stars_rounded),
        _ => null,
      },
      onTap: () => Navigator.of(context).pop(language),
    );
  }

  (OpenFoodFactsLanguage?, _LanguageType) _findItem(int index) {
    final int selectedLength = _selectedLanguages.length;
    int diff = 0;
    if (selectedLength > 0) {
      if (index == selectedLength) {
        return (null, _LanguageType.selectedTitle);
      } else if (index < selectedLength) {
        return (_selectedLanguages[index], _LanguageType.selected);
      }
      diff++;
    }

    final int popularLength = _popularLanguages.length;
    if (popularLength > 0) {
      if (index < selectedLength + popularLength + diff) {
        return (
          _popularLanguages[index - selectedLength - diff],
          _LanguageType.popular
        );
      } else if (index == selectedLength + popularLength + diff) {
        return (null, _LanguageType.popularTitle);
      }
      diff++;
    }

    return (
      _otherLanguages[index - selectedLength - popularLength - diff],
      _LanguageType.other
    );
  }

  dynamic _countItems() {
    int count = 0;
    if (_selectedLanguages.isNotEmpty) {
      count += 1 + _selectedLanguages.length;
    }
    if (_popularLanguages.isNotEmpty) {
      count += 1 + _popularLanguages.length;
    }
    count += _otherLanguages.length;
    return count;
  }

  void _filterLanguages(String query) {
    _selectedLanguages = _filterList(widget.selectedLanguages, query);
    _popularLanguages = _filterList(widget.popularLanguages, query);
    _otherLanguages = _filterList(widget.otherLanguages, query);
    setState(() {});
  }

  List<OpenFoodFactsLanguage> _filterList(
      List<OpenFoodFactsLanguage> list, String query) {
    return list
        .where((OpenFoodFactsLanguage item) =>
            Languages()
                .getNameInEnglish(item)
                .getComparisonSafeString()
                .contains(query.toLowerCase()) ||
            Languages()
                .getNameInLanguage(item)
                .getComparisonSafeString()
                .contains(query.toLowerCase()) ||
            item.code.contains(query))
        .toList(growable: false);
  }
}

enum _LanguageType {
  selected,
  selectedTitle,
  popular,
  popularTitle,
  other,
}
