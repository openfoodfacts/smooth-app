import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/edit_ocr/edit_ocr_page.dart';
import 'package:smooth_app/pages/product/edit_ocr/ocr_helper.dart';
import 'package:smooth_app/pages/product/multilingual_helper.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/pages/product/simple_input_widget.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class EditOCRTextField extends StatelessWidget {
  const EditOCRTextField({
    required this.helper,
    required this.controller,
    required this.isOwnerField,
    this.extraButton,
  });

  final OcrHelper helper;
  final TextEditingController controller;
  final bool isOwnerField;
  final Widget? extraButton;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Consumer<OcrState>(
      builder: (
        BuildContext context,
        OcrState ocrState,
        Widget? child,
      ) {
        if (ocrState == OcrState.EXTRACTING_DATA) {
          return AbsorbPointer(
            absorbing: ocrState == OcrState.EXTRACTING_DATA,
            child: Opacity(
              opacity: 0.2,
              child: child,
            ),
          );
        } else {
          return child!;
        }
      },
      child: SmoothCardWithRoundedHeader(
        title: helper.getEditableContentTitle(appLocalizations),
        leading: helper.getIcon().call(context),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isOwnerField) const EditOCROwnerFieldIcon(),
            ExplanationTitleIcon(
              type: helper.getType(appLocalizations),
              text: helper.getInstructions(appLocalizations),
            ),
          ],
        ),
        titlePadding: const EdgeInsetsDirectional.only(
          top: 2.0,
          start: LARGE_SPACE,
          end: SMALL_SPACE,
          bottom: 2.0,
        ),
        contentPadding: const EdgeInsetsDirectional.all(
          MEDIUM_SPACE,
        ),
        child: Column(
          children: <Widget>[
            ConsumerFilter<UserPreferences>(
              buildWhen: (
                UserPreferences? previousValue,
                UserPreferences currentValue,
              ) {
                return previousValue?.getFlag(UserPreferencesDevMode
                        .userPreferencesFlagSpellCheckerOnOcr) !=
                    currentValue.getFlag(UserPreferencesDevMode
                        .userPreferencesFlagSpellCheckerOnOcr);
              },
              builder: (
                BuildContext context,
                UserPreferences prefs,
                Widget? child,
              ) {
                final ThemeData theme = Theme.of(context);

                return Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      onSurface:
                          context.read<ThemeProvider>().isDarkMode(context)
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                  child: TextFormField(
                    minLines: null,
                    maxLines: null,
                    controller: controller,
                    textInputAction: TextInputAction.newline,
                    spellCheckConfiguration: (prefs.getFlag(
                                    UserPreferencesDevMode
                                        .userPreferencesFlagSpellCheckerOnOcr) ??
                                false) &&
                            (Platform.isAndroid || Platform.isIOS)
                        ? const SpellCheckConfiguration()
                        : const SpellCheckConfiguration.disabled(),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: LARGE_SPACE,
                        vertical: SMALL_SPACE,
                      ),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: ROUNDED_BORDER_RADIUS,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: ROUNDED_BORDER_RADIUS,
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 5.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (extraButton != null) extraButton!,
          ],
        ),
      ),
    );
  }
}

class EditOCRExtraButton extends StatelessWidget {
  const EditOCRExtraButton({
    required this.barcode,
    required this.productType,
    required this.multilingualHelper,
    required this.isLoggedInMandatory,
  });

  final String barcode;
  final ProductType? productType;
  final MultilingualHelper multilingualHelper;
  final bool isLoggedInMandatory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SMALL_SPACE),
      child: addPanelButton(
        AppLocalizations.of(context).add_packaging_photo_button_label,
        onPressed: () async => confirmAndUploadNewPicture(
          context,
          imageField: ImageField.OTHER,
          barcode: barcode,
          productType: productType,
          language: multilingualHelper.getCurrentLanguage(),
          isLoggedInMandatory: isLoggedInMandatory,
        ),
        iconData: Icons.add_a_photo_rounded,
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
          start: VERY_SMALL_SPACE,
        ),
      ),
    );
  }
}

class EditOCROwnerFieldIcon extends StatelessWidget {
  const EditOCROwnerFieldIcon();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothCardHeaderButton(
      tooltip: appLocalizations.owner_field_info_title,
      child: const OwnerFieldIcon(),
      onTap: () => showOwnerFieldInfoInModalSheet(
        context,
        headerColor: SmoothCardWithRoundedHeader.getHeaderColor(context),
      ),
    );
  }
}
