import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/donation/donation_links.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/v2/smooth_leading_button.dart';
import 'package:smooth_app/widgets/v2/smooth_scaffold2.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';
import 'package:url_launcher/url_launcher.dart';

/// Explains what a donation pays for and hands off to the donation form with
/// the amount, interval and currency preselected.
class DonationPage extends StatefulWidget {
  const DonationPage();

  static const Key whereItGoesKey = Key('donation_where_it_goes');

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  DonationTier _selected = DonationTier.values.first;

  @override
  void initState() {
    super.initState();
    AnalyticsHelper.trackEvent(AnalyticsEvent.donationPageOpened);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return SmoothScaffold2(
      backgroundColor: context.lightTheme() ? extension.primaryLight : null,
      topBar: SmoothTopBar2(
        leadingAction: SmoothLeadingAction.back,
        title: appLocalizations.preferences_support_title,
        productType: null,
      ),
      children: <Widget>[
        // A single adapter, not a list: every block must be laid out, even the
        // ones below the fold.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: LARGE_SPACE,
              children: <Widget>[
                Text(
                  appLocalizations.donation_page_headline,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const _WhereItGoes(),
                _TierList(
                  selected: _selected,
                  onSelected: (DonationTier tier) =>
                      setState(() => _selected = tier),
                ),
                _Ctas(selected: _selected),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: SMALL_SPACE,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        SmoothCard(
          margin: EdgeInsetsDirectional.zero,
          padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
          child: child,
        ),
      ],
    );
  }
}

class _WhereItGoes extends StatelessWidget {
  const _WhereItGoes();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final Color iconColor = context.lightTheme()
        ? extension.primarySemiDark
        : Colors.white;

    return _Block(
      title: appLocalizations.donation_where_it_goes_title,
      child: IconTheme.merge(
        data: IconThemeData(color: iconColor, size: 21.0),
        child: Column(
          key: DonationPage.whereItGoesKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: MEDIUM_SPACE,
          children: <Widget>[
            _WhereItGoesRow(
              icon: const icons.Gears(),
              label: appLocalizations.donation_where_it_goes_servers,
            ),
            _WhereItGoesRow(
              icon: const icons.Programming(),
              label: appLocalizations.donation_where_it_goes_engineer,
            ),
            _WhereItGoesRow(
              icon: const icons.Toolbox(),
              label: appLocalizations.donation_where_it_goes_services,
            ),
          ],
        ),
      ),
    );
  }
}

class _WhereItGoesRow extends StatelessWidget {
  const _WhereItGoesRow({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: MEDIUM_SPACE,
      children: <Widget>[icon, Expanded(child: Text(label))],
    );
  }
}

class _TierList extends StatelessWidget {
  const _TierList({required this.selected, required this.onSelected});

  final DonationTier selected;
  final ValueChanged<DonationTier> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    // Both numbers are formatted here and injected as placeholders, so no
    // translated string carries a currency symbol or a digit separator.
    // [AppLocalizations.localeName] rather than [ProductQuery]: it is the
    // locale the sentence itself is in, and it is always a valid `intl` locale.
    final NumberFormat amountFormat = NumberFormat.simpleCurrency(
      locale: appLocalizations.localeName,
      name: 'EUR',
      decimalDigits: 0,
    );
    final NumberFormat scansFormat = NumberFormat.decimalPattern(
      appLocalizations.localeName,
    );

    return _Block(
      title: appLocalizations.donation_tiers_title,
      child: Column(
        spacing: SMALL_SPACE,
        children: DonationTier.values
            .map(
              (DonationTier tier) => _TierRow(
                selected: tier == selected,
                amount: appLocalizations.donation_tier_amount_monthly(
                  amountFormat.format(tier.monthlyAmount),
                ),
                scans: appLocalizations.donation_tier_scans(
                  scansFormat.format(tier.scans),
                ),
                onTap: () => onSelected(tier),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.selected,
    required this.amount,
    required this.scans,
    required this.onTap,
  });

  final bool selected;
  final String amount;
  final String scans;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: ClipRRect(
          borderRadius: ROUNDED_BORDER_RADIUS,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: ROUNDED_BORDER_RADIUS,
              // Transparent rather than absent, so selecting does not move the
              // rest of the list.
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
            ),
            child: PreferenceTile(
              leading: selected
                  ? const icons.CheckBox.filled()
                  : const icons.CheckBox(),
              title: amount,
              subtitleText: scans,
              trailing: EMPTY_WIDGET,
              borderRadius: ROUNDED_BORDER_RADIUS,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}

class _Ctas extends StatelessWidget {
  const _Ctas({required this.selected});

  final DonationTier selected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Column(
      children: <Widget>[
        SmoothLargeButtonWithIcon(
          text: appLocalizations.donation_cta_monthly,
          leadingIcon: const icons.Donate(),
          onPressed: () => _openDonationForm(selected),
        ),
        TextButton(
          onPressed: () => _openDonationForm(null),
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(MINIMUM_TOUCH_SIZE),
          ),
          child: Text(appLocalizations.donation_cta_one_off),
        ),
      ],
    );
  }
}

/// Opens the donation form for [tier], or for a single gift when null.
void _openDonationForm(DonationTier? tier) {
  AnalyticsHelper.trackEvent(
    AnalyticsEvent.donationHandoff,
    eventValue: tier?.monthlyAmount ?? 0,
  );

  // In-app browser view, never a webview: Apple Pay and Google Pay disappear
  // inside a webview and the donor is pushed back to card entry.
  LaunchUrlHelper.launchURL(
    buildDonationUrl(tier),
    mode: LaunchMode.inAppBrowserView,
  );
}
