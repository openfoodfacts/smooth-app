import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/pages/preferences/user_preferences_languages_list.dart';
import 'package:smooth_app/query/product_query.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    required this.setLanguage,
    this.selectedLanguages,
    this.displayedLanguage,
    this.foregroundColor,
  });

  /// What to do when the language is selected.
  final Future<void> Function(OpenFoodFactsLanguage?) setLanguage;

  /// Languages that are already selected (and will be displayed differently).
  final Iterable<OpenFoodFactsLanguage>? selectedLanguages;

  /// Initial language displayed, before even calling the dialog.
  final OpenFoodFactsLanguage? displayedLanguage;

  final Color? foregroundColor;

  static const Languages _languages = Languages();

  @override
  Widget build(BuildContext context) {
    final OpenFoodFactsLanguage language;
    if (displayedLanguage != null) {
      language = displayedLanguage!;
    } else {
      final String currentLanguageCode = ProductQuery.getLanguage().code;
      language = LanguageHelper.fromJson(currentLanguageCode);
    }
    final String nameInEnglish = _languages.getNameInEnglish(language);
    final String nameInLanguage = _languages.getNameInLanguage(language);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () async {
          final OpenFoodFactsLanguage? language = await openLanguageSelector(
            context,
            selectedLanguages: selectedLanguages,
          );
          await setLanguage(language);
        },
        borderRadius: ANGULAR_BORDER_RADIUS,
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
                  '$nameInLanguage ($nameInEnglish)',
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
              Icons.arrow_drop_down,
              color: foregroundColor,
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the language selected by the user.
  ///
  /// [selectedLanguages] have a specific "more important" display.
  static Future<OpenFoodFactsLanguage?> openLanguageSelector(
    final BuildContext context, {
    final Iterable<OpenFoodFactsLanguage>? selectedLanguages,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextEditingController languageSelectorController =
        TextEditingController();
    final List<OpenFoodFactsLanguage> leftovers =
        _languages.getSupportedLanguagesNameInEnglish();
    leftovers.sort(
      (OpenFoodFactsLanguage a, OpenFoodFactsLanguage b) {
        // Selected languages first.
        final bool selectedA =
            selectedLanguages != null && selectedLanguages.contains(a);
        final bool selectedB =
            selectedLanguages != null && selectedLanguages.contains(b);
        if (selectedA) {
          if (!selectedB) {
            return -1;
          }
        } else {
          if (selectedB) {
            return 1;
          }
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
            SmoothAlertDialog(
          body: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                SmoothTextFormField(
                  type: TextFieldTypes.PLAIN_TEXT,
                  hintText: appLocalizations.search,
                  prefixIcon: const Icon(Icons.search),
                  controller: languageSelectorController,
                  onChanged: (String? query) {
                    setState(
                      () {
                        filteredList = leftovers
                            .where((OpenFoodFactsLanguage item) =>
                                _languages
                                    .getNameInEnglish(item)
                                    .toLowerCase()
                                    .contains(query!.toLowerCase()) ||
                                _languages
                                    .getNameInLanguage(item)
                                    .toLowerCase()
                                    .contains(query.toLowerCase()) ||
                                item.code.contains(query))
                            .toList();
                      },
                    );
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      final OpenFoodFactsLanguage language =
                          filteredList[index];
                      final String nameInLanguage =
                          _languages.getNameInLanguage(language);
                      final String nameInEnglish =
                          _languages.getNameInEnglish(language);
                      final bool selected = selectedLanguages != null &&
                          selectedLanguages.contains(language);
                      return ListTile(
                        dense: true,
                        trailing: selected ? const Icon(Icons.check) : null,
                        title: Text(
                          '$nameInLanguage ($nameInEnglish)',
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: selected
                              ? const TextStyle(fontWeight: FontWeight.bold)
                              : null,
                        ),
                        onTap: () => Navigator.of(context).pop(language),
                      );
                    },
                    itemCount: filteredList.length,
                    shrinkWrap: true,
                  ),
                ),
              ],
            ),
          ),
          positiveAction: SmoothActionButton(
            onPressed: () => Navigator.of(context).pop(),
            text: appLocalizations.cancel,
          ),
        ),
      ),
    );
  }
}
