import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/pages/preferences/user_preferences_languages_list.dart';

class LanguagePickerSetting extends StatelessWidget {
  const LanguagePickerSetting({
    required this.userPreferences,
    required this.appLocalizations,
  });
  final UserPreferences userPreferences;
  final AppLocalizations appLocalizations;

  @override
  Widget build(BuildContext context) {
    final Languages languages = Languages();

    // The languages that are supported by flutter widget
    final String currentLanguageCode = userPreferences.appLanguageCode ??
        Localizations.localeOf(context).toString();
    final LanguageName languageName =
        languages.getLanguageNameFromLangCode(currentLanguageCode);
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text(
        // TODO(abughalib): Localize this
        'Choose App Language',
      ),
      subtitle: Text(
        '${languageName.nameInLanguage} (${languageName.englishName})',
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      onTap: () async {
        final List<Pair<String, OpenFoodFactsLanguage>> leftovers =
            languages.getSupportedLanguagesEnglishName();
        leftovers.sort((Pair<String, OpenFoodFactsLanguage> a,
                Pair<String, OpenFoodFactsLanguage> b) =>
            (a.first).compareTo(b.first));
        List<Pair<String, OpenFoodFactsLanguage>> filteredList = leftovers;
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
                                    .where((Pair<String, OpenFoodFactsLanguage>
                                            item) =>
                                        item.first
                                            .toLowerCase()
                                            .contains(query.toLowerCase()))
                                    .toList();
                              },
                            );
                          },
                        ),
                        ...List<ListTile>.generate(
                          filteredList.length,
                          (int index) {
                            final Pair<String, OpenFoodFactsLanguage>
                                translatedLang = filteredList[index];
                            final LanguageName languageName = languages
                                .getLanguageName(translatedLang.second);
                            return ListTile(
                              title: Text(
                                '${languageName.nameInLanguage} (${translatedLang.second.code})',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                              onTap: () {
                                userPreferences.setAppLanguageCode(
                                    translatedLang.second.code);

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
