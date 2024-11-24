import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_string_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/language_priority.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/pages/preferences/user_preferences_languages_list.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    required this.setLanguage,
    this.selectedLanguages,
    this.displayedLanguage,
    this.foregroundColor,
    this.icon,
    this.padding,
    this.product,
  });

  /// What to do when the language is selected.
  final Future<void> Function(OpenFoodFactsLanguage?) setLanguage;

  /// Languages that are already selected (and will be displayed differently).
  final Iterable<OpenFoodFactsLanguage>? selectedLanguages;

  /// Initial language displayed, before even calling the dialog.
  final OpenFoodFactsLanguage? displayedLanguage;

  final Color? foregroundColor;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

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
    final LanguagePriority languagePriority = LanguagePriority(
      product: product,
      selectedLanguages: selectedLanguages,
      daoStringList: daoStringList,
    );
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () async {
          final OpenFoodFactsLanguage? language = await openLanguageSelector(
            context,
            selectedLanguages: selectedLanguages,
            languagePriority: languagePriority,
          );
          if (language != null) {
            await daoStringList.add(
              DaoStringList.keyLanguages,
              language.offTag,
            );
          }
          await setLanguage(language);
        },
        borderRadius: ANGULAR_BORDER_RADIUS,
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
                    style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: foregroundColor) ??
                        TextStyle(color: foregroundColor),
                  ),
                ),
              ),
              Icon(
                icon ?? Icons.arrow_drop_down,
                color: foregroundColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the language selected by the user.
  ///
  /// [selectedLanguages] have a specific "more important" display.
  // TODO(g123k): Improve the language selector to usable without the Widget
  static Future<OpenFoodFactsLanguage?> openLanguageSelector(
    final BuildContext context, {
    final Iterable<OpenFoodFactsLanguage>? selectedLanguages,
    required final LanguagePriority languagePriority,
  }) async {
    final ScrollController scrollController = ScrollController();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextEditingController languageSelectorController =
        TextEditingController();
    final List<OpenFoodFactsLanguage> leftovers =
        _languages.getSupportedLanguagesNameInEnglish();
    leftovers.sort(
      (OpenFoodFactsLanguage a, OpenFoodFactsLanguage b) {
        final int? compare = languagePriority.compare(a, b);
        if (compare != null) {
          return compare;
        }
        // Sorted in English
        return _languages
            .getNameInEnglish(a)
            .compareTo(_languages.getNameInEnglish(b));
      },
    );
    List<OpenFoodFactsLanguage> filteredList = leftovers;
    return showDialog<OpenFoodFactsLanguage>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (
          BuildContext context,
          void Function(VoidCallback fn) setState,
        ) =>
            SmoothListAlertDialog(
          title: appLocalizations.language_selector_title,
          header: SmoothTextFormField(
            type: TextFieldTypes.PLAIN_TEXT,
            hintText: appLocalizations.search,
            prefixIcon: const Icon(Icons.search),
            controller: languageSelectorController,
            onChanged: (String? query) {
              query = query!.trim().getComparisonSafeString();

              setState(
                () {
                  filteredList = leftovers
                      .where((OpenFoodFactsLanguage item) =>
                          _languages
                              .getNameInEnglish(item)
                              .getComparisonSafeString()
                              .contains(query!.toLowerCase()) ||
                          _languages
                              .getNameInLanguage(item)
                              .getComparisonSafeString()
                              .contains(query.toLowerCase()) ||
                          item.code.contains(query))
                      .toList();
                },
              );
            },
          ),
          scrollController: scrollController,
          list: ListView.separated(
            controller: scrollController,
            itemBuilder: (BuildContext context, int index) {
              final OpenFoodFactsLanguage language = filteredList[index];
              final bool selected = selectedLanguages != null &&
                  selectedLanguages.contains(language);
              return ListTile(
                dense: true,
                trailing: selected ? const Icon(Icons.check) : null,
                title: TextHighlighter(
                  text: _getCompleteName(language),
                  filter: languageSelectorController.text,
                  selected: selected,
                ),
                onTap: () => Navigator.of(context).pop(language),
              );
            },
            separatorBuilder: (_, __) => const Divider(
              height: 1.0,
            ),
            itemCount: filteredList.length,
            shrinkWrap: true,
          ),
          positiveAction: SmoothActionButton(
            onPressed: () {
              languageSelectorController.clear();
              Navigator.of(context).pop();
            },
            text: appLocalizations.cancel,
          ),
        ),
      ),
    );
  }

  static String _getCompleteName(
    final OpenFoodFactsLanguage language,
  ) {
    final String nameInLanguage = _languages.getNameInLanguage(language);
    final String nameInEnglish = _languages.getNameInEnglish(language);
    return '$nameInLanguage ($nameInEnglish)';
  }
}
