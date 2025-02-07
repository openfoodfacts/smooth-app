import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/report_product/wizard/report_product_wizard_actions.dart';

abstract class ReportProductWizardStep {
  const ReportProductWizardStep();

  String Function(AppLocalizations appLocalisations) get title;
}

class ReportProductWizardStepComment extends ReportProductWizardStep {
  const ReportProductWizardStepComment({
    required this.mandatory,
    this.text,
  });

  final String? text;
  final bool mandatory;

  @override
  String Function(AppLocalizations appLocalisations) get title =>
      (AppLocalizations appLocalisations) => 'Comment';
}

abstract class ReportProductWizardStepExplanation
    extends ReportProductWizardStep {
  const ReportProductWizardStepExplanation();

  String get text;

  List<ReportProductWizardAction> get actions;
}

// TODO(g123k): Créer une classe pour faire les explications sur "ne correspond pas au produit"
