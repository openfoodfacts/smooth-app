import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/report_product/wizard/report_product_wizard_steps.dart';

abstract class ReportProductWizardReason {
  const ReportProductWizardReason();

  List<ReportProductWizardStep> get steps;

  String Function(AppLocalizations appLocalisations) get title;
}

abstract class ReportProductPhotoWizard extends ReportProductWizardReason {
  const ReportProductPhotoWizard();
}

class ReportPhotoWizardOtherReason extends ReportProductPhotoWizard {
  const ReportPhotoWizardOtherReason();

  @override
  List<ReportProductWizardStep> get steps => <ReportProductWizardStep>[
        const ReportProductWizardStepComment(mandatory: false),
      ];

  @override
  String Function(AppLocalizations appLocalisations) get title =>
      (AppLocalizations appLocalizations) => 'Another reason';
}

class ReportPhotoWizardInappropriate extends ReportProductPhotoWizard {
  const ReportPhotoWizardInappropriate();

  @override
  List<ReportProductWizardStep> get steps => <ReportProductWizardStep>[
        const ReportProductWizardStepComment(mandatory: false),
      ];

  @override
  String Function(AppLocalizations appLocalisations) get title =>
      (AppLocalizations appLocalizations) => 'This photo is inappropriate';
}
