import 'package:smooth_app/pages/product/report_product/wizard/report_product_wizard_reasons.dart';

abstract class ReportProductWizard {
  const ReportProductWizard();

  // TODO(g123k): Rajouter photo signaler (header)

  List<ReportProductWizardReason> get reasons;
}

class ReportProductWizardPhoto extends ReportProductWizard {
  const ReportProductWizardPhoto();

  @override
  List<ReportProductWizardReason> get reasons => <ReportProductWizardReason>[
        const ReportPhotoWizardInappropriate(),
        const ReportPhotoWizardOtherReason(),
      ];
}
