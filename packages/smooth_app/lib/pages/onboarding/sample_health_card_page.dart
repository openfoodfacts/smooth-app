import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/onboarding/knowledge_panel_page_template.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

/// Next button showed at the bottom of the onboarding flow.
class SampleHealthCardPage extends StatelessWidget {
  const SampleHealthCardPage();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return KnowledgePanelPageTemplate(
      assetFile: 'assets/onboarding/sample_health_knowledge_panels.json',
      headerTitle: appLocalizations.healthCardUtility,
      page: OnboardingPage.HEALTH_CARD_EXAMPLE,
    );
  }
}
