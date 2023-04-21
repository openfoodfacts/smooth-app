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
  });

  final Function(OpenFoodFactsLanguage) setLanguage;

  static const Languages _languages = Languages();

  @override
  Widget build(BuildContext context) {
    // The languages that are supported by flutter widget
    final String currentLanguageCode = ProductQuery.getLanguage().code;
    final OpenFoodFactsLanguage language =
        LanguageHelper.fromJson(currentLanguageCode);
    final String nameInEnglish = _languages.getNameInEnglish(
      language,
    );
    final String nameInLanguage = _languages.getNameInLanguage(
      language,
    );
    return InkWell(
      onTap: () async {
        final OpenFoodFactsLanguage? language =
            await openLanguageSelector(context);
        if (context.mounted) {
          if (language != null) {
            setLanguage(language);
          }
        }
      },
      borderRadius: ANGULAR_BORDER_RADIUS,
      child: ListTile(
        leading: const Icon(Icons.language),
        title: Text(
          '$nameInLanguage ($nameInEnglish)',
          softWrap: false,
          overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  /// Returns the selected language.
  static Future<OpenFoodFactsLanguage?> openLanguageSelector(
    final BuildContext context,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextEditingController languageSelectorController =
        TextEditingController();
    final List<OpenFoodFactsLanguage> leftovers =
        _languages.getSupportedLanguagesNameInEnglish();
    leftovers.sort((OpenFoodFactsLanguage a, OpenFoodFactsLanguage b) =>
        _languages
            .getNameInEnglish(a)
            .compareTo(_languages.getNameInEnglish(b)));
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
                      return ListTile(
                        title: Text(
                          '$nameInLanguage ($nameInEnglish)',
                          softWrap: false,
                          overflow: TextOverflow.fade,
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
