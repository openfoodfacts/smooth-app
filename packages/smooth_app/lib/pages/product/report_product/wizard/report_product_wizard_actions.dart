import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

abstract class ReportProductWizardAction {
  const ReportProductWizardAction();

  Function(BuildContext, Product) get action;

  Widget get icon;

  String Function(AppLocalizations appLocalisations) get text;
}

class ReportProductWizardActionTakePicture extends ReportProductWizardAction {
  const ReportProductWizardActionTakePicture();

  @override
  Function(BuildContext, Product) get action =>
      (BuildContext context, Product product) {
        // TODO(g123k): Fermer le signalement et faire l'équivalent de "En prendre une autre"
      };

  @override
  Widget get icon => const Icon(Icons.camera_alt);

  @override
  String Function(AppLocalizations appLocalisations) get text =>
      (AppLocalizations appLocalizations) => 'Take a picture';
}
