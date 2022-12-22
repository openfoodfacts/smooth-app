import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/pages/preferences/user_preferences_languages_list.dart';
import 'package:smooth_app/query/product_query.dart';

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
    final String currentLanguageCode = ProductQuery.getLanguage().code;
    final OpenFoodFactsLanguage language =
        LanguageHelper.fromJson(currentLanguageCode);
    final String nameInEnglish =
        _languages.getLanguageNameInEnglishFromOpenFoodFactsLanguage(
      language,
    );
    final String nameInLanguage =
        _languages.getLanguageNameInLanguageFromOpenFoodFactsLanguage(
      language,
    );
    final TextEditingController languageSelectorController =
        TextEditingController();
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(
        '$nameInLanguage ($nameInEnglish)',
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: () async {
        final List<OpenFoodFactsLanguage> leftovers =
            _languages.getSupportedLanguagesNameInEnglish();
        leftovers.sort((OpenFoodFactsLanguage a, OpenFoodFactsLanguage b) =>
            _languages
                .getLanguageNameInEnglishFromOpenFoodFactsLanguage(a)
                .compareTo(_languages
                    .getLanguageNameInEnglishFromOpenFoodFactsLanguage(b)));
        List<OpenFoodFactsLanguage> filteredList = leftovers;
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context,
                  void Function(VoidCallback fn) setState) {
                return SmoothAlertDialog(
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
                                            .getLanguageNameInEnglishFromOpenFoodFactsLanguage(
                                                item)
                                            .toLowerCase()
                                            .contains(query!.toLowerCase()) ||
                                        _languages
                                            .getLanguageNameInLanguageFromOpenFoodFactsLanguage(
                                                item)
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
                              final OpenFoodFactsLanguage
                                  openFoodFactsLanguage = filteredList[index];
                              final String nameInLanguage = _languages
                                  .getLanguageNameInLanguageFromOpenFoodFactsLanguage(
                                      openFoodFactsLanguage);
                              return ListTile(
                                title: Text(
                                  '$nameInLanguage (${_languages.getLanguageNameInEnglishFromOpenFoodFactsLanguage(openFoodFactsLanguage)})',
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                ),
                                onTap: () {
                                  ProductQuery.setLanguage(
                                    context,
                                    userPreferences,
                                    languageCode: openFoodFactsLanguage.code,
                                  );
                                  Navigator.of(context).pop();
                                },
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
                    onPressed: () => Navigator.pop(context),
                    text: appLocalizations.cancel,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
