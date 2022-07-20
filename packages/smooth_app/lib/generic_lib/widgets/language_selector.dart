import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/pages/preferences/user_preferences_languages_list.dart';

class LanguageSelectorSettings extends StatelessWidget {
  const LanguageSelectorSettings({
    required this.userPreferences,
    required this.appLocalizations,
  });

  final UserPreferences userPreferences;
  final AppLocalizations appLocalizations;

  static final Languages _languages = Languages();

  @override
  Widget build(BuildContext context) {
    // The languages that are supported by flutter widget
    final String currentLanguageCode = userPreferences.appLanguageCode ??
        Localizations.localeOf(context).toString();
    final String nameInLanguage =
        _languages.getLanguageNameFromLangCode(currentLanguageCode);
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(
        appLocalizations.choose_app_language,
      ),
      subtitle: Text(
        '$nameInLanguage ($currentLanguageCode)',
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      onTap: () async {
        final List<String> leftovers =
            _languages.getSupportedLanguagesNameInEnglish();
        leftovers.sort();
        List<String> filteredList = leftovers;
        await showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context,
                    void Function(VoidCallback fn) setState) {
                  return SmoothAlertDialog(
                    body: Column(
                      children: <Widget>[
                        TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            enabledBorder: const UnderlineInputBorder(),
                            labelText: appLocalizations.search,
                          ),
                          onChanged: (String query) {
                            setState(
                              () {
                                filteredList = leftovers
                                    .where((String item) => item
                                        .toLowerCase()
                                        .contains(query.toLowerCase()))
                                    .toList();
                                // Search using Language Code
                                if (query.length <= 3) {
                                  _languages
                                      .getLanguageNameFromLanguageCodeQuery(
                                          query)
                                      .forEach((String nameInEnglish) {
                                    if (!filteredList.contains(nameInEnglish)) {
                                      filteredList.add(nameInEnglish);
                                    }
                                  });
                                }
                              },
                            );
                          },
                        ),
                        ...List<ListTile>.generate(
                          filteredList.length,
                          (int index) {
                            final String nameInEnglish = filteredList[index];
                            final OpenFoodFactsLanguage languageCode =
                                _languages
                                    .getLanguageCodeFromLanguageEnglishName(
                                        nameInEnglish);
                            final String nameInLanguage = _languages
                                .getLanguageNameInLanguageFromOpenFoodFactsLanguage(
                                    languageCode);
                            return ListTile(
                              title: Text(
                                '$nameInLanguage ($nameInEnglish)',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                              onTap: () {
                                userPreferences.setAppLanguageCode(_languages
                                    .getLanguageCodeFromLanguageEnglishName(
                                        nameInEnglish)
                                    .code);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    positiveAction: SmoothActionButton(
                      onPressed: () => Navigator.pop(context),
                      text: appLocalizations.cancel,
                    ),
                  );
                },
              );
            });
      },
    );
  }
}
