import 'package:flutter/material.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/onboarding/knowledge_panel_page_template.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class SampleHealthCardPage extends StatelessWidget {
  const SampleHealthCardPage(this._localDatabase, this.backgroundColor);

  final LocalDatabase _localDatabase;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) => SmoothBrightnessOverride(
        brightness: Brightness.dark,
        child: KnowledgePanelPageTemplate(
          headerTitle: AppLocalizations.of(context).healthCardUtility,
          page: OnboardingPage.HEALTH_CARD_EXAMPLE,
          panelId: 'health_card',
          localDatabase: _localDatabase,
          backgroundColor: backgroundColor,
          svgAsset: 'assets/onboarding/health.svg',
          nextKey: const Key('nextAfterHealth'),
        ),
      );
}
