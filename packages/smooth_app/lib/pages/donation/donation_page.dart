import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/donation/donation_offer.dart';
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
  const DonationPage({this.source});

  static const Key whereItGoesKey = Key('donation_where_it_goes');

  final DonationSource? source;

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final TextEditingController _customAmountController = TextEditingController();

  /// Read once: a feed arriving mid-visit would move the ladder under the
  /// donor's current selection.
  late final DonationOffer _offer;

  int? _selectedAmount;
  int? _customAmount;

  @override
  void initState() {
    super.initState();

    final AppNewsState? news = context.read<AppNewsProvider?>()?.state;
    _offer = DonationOffer.fromNews(
      news is AppNewsStateLoaded ? news.content.donation : null,
    );

    AnalyticsHelper.trackEvent(
      AnalyticsEvent.donationPageOpened,
      eventValue: widget.source?.analyticsValue,
    );
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final int ladderAmount = _selectedAmount ?? _offer.defaultAmount;
    final int amount = _customAmount ?? ladderAmount;

    return SmoothScaffold2(
      backgroundColor: context.lightTheme() ? extension.primaryLight : null,
      topBar: SmoothTopBar2(
        leadingAction: SmoothLeadingAction.back,
        title: appLocalizations.preferences_support_title,
        productType: null,
      ),
      children: <Widget>[
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
                _WhereItGoes(labels: _offer.whereItGoes),
                _TierList(
                  offer: _offer,
                  ladderAmount: ladderAmount,
                  selectedAmount: amount,
                  customAmountController: _customAmountController,
                  onSelected: _select,
                  onCustomAmount: _setCustomAmount,
                ),
                _Ctas(offer: _offer, amount: amount, source: widget.source),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _select(int amount) {
    _customAmountController.clear();
    setState(() {
      _selectedAmount = amount;
      _customAmount = null;
    });
  }

  void _setCustomAmount(int? amount) {
    setState(() => _customAmount = amount);
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
  const _WhereItGoes({required this.labels});

  static const List<Widget> _icons = <Widget>[
    icons.Gears(),
    icons.Programming(),
    icons.Toolbox(),
  ];

  /// Empty unless the feed names the categories itself.
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final Color iconColor = context.lightTheme()
        ? extension.primarySemiDark
        : Colors.white;
    final List<String> lines = labels.isEmpty
        ? <String>[
            appLocalizations.donation_where_it_goes_servers,
            appLocalizations.donation_where_it_goes_engineer,
            appLocalizations.donation_where_it_goes_services,
          ]
        : labels;

    return _Block(
      title: appLocalizations.donation_where_it_goes_title,
      child: IconTheme.merge(
        data: IconThemeData(color: iconColor, size: 21.0),
        child: Column(
          key: DonationPage.whereItGoesKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: MEDIUM_SPACE,
          children: <Widget>[
            for (int i = 0; i < lines.length; i++)
              _WhereItGoesRow(icon: _icons[i % _icons.length], label: lines[i]),
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
      children: <Widget>[
        icon,
        Expanded(child: Text(label)),
      ],
    );
  }
}

class _TierList extends StatelessWidget {
  const _TierList({
    required this.offer,
    required this.ladderAmount,
    required this.selectedAmount,
    required this.customAmountController,
    required this.onSelected,
    required this.onCustomAmount,
  });

  final DonationOffer offer;

  /// Always one of [DonationOffer.amounts], where [selectedAmount] can also be
  /// whatever was typed into the custom field.
  final int ladderAmount;
  final int selectedAmount;
  final TextEditingController customAmountController;
  final ValueChanged<int> onSelected;
  final ValueChanged<int?> onCustomAmount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    // [AppLocalizations.localeName] rather than [ProductQuery]: it is the
    // locale the sentence itself is in. `intl` ships no number symbols for 46
    // of the app's 128 locales and both constructors throw there, so fall back
    // rather than lose the tier picker to an ErrorWidget.
    final String numberLocale =
        NumberFormat.localeExists(appLocalizations.localeName)
        ? appLocalizations.localeName
        : 'en';
    final NumberFormat amountFormat = NumberFormat.simpleCurrency(
      locale: numberLocale,
      name: offer.currency,
      decimalDigits: 0,
    );
    final NumberFormat numberFormat = NumberFormat.decimalPattern(numberLocale);
    final List<DonationTier> tiers = offer.tiers;

    return _Block(
      title: appLocalizations.donation_tiers_title,
      child: Column(
        spacing: SMALL_SPACE,
        children: <Widget>[
          if (tiers.length > 1)
            Slider(
              value: tiers
                  .indexWhere(
                    (DonationTier tier) => tier.amount == ladderAmount,
                  )
                  .toDouble(),
              max: (tiers.length - 1).toDouble(),
              divisions: tiers.length - 1,
              label: amountFormat.format(ladderAmount),
              semanticFormatterCallback: (double value) =>
                  amountFormat.format(tiers[value.round()].amount),
              onChanged: (double value) {
                final int amount = tiers[value.round()].amount;
                if (amount != ladderAmount) {
                  SmoothHapticFeedback.click();
                  onSelected(amount);
                }
              },
            ),
          for (final DonationTier tier in tiers)
            _TierRow(
              selected: tier.amount == selectedAmount,
              amount: appLocalizations.donation_tier_amount_monthly(
                amountFormat.format(tier.amount),
              ),
              scans: appLocalizations.donation_tier_scans(
                numberFormat.format(tier.scans),
              ),
              onTap: () => onSelected(tier.amount),
            ),
          SmoothTextFormField(
            type: TextFieldTypes.PLAIN_TEXT,
            controller: customAmountController,
            hintText: appLocalizations.donation_custom_amount_hint,
            textInputType: TextInputType.number,
            maxLines: 1,
            validator: (String? value) =>
                value == null ||
                    value.isEmpty ||
                    _amountOf(numberFormat, value) != null
                ? null
                : appLocalizations.donation_custom_amount_error,
            suffixIcon: Center(
              widthFactor: 1.0,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: MEDIUM_SPACE),
                child: Text(amountFormat.currencySymbol),
              ),
            ),
            onChanged: (String? value) =>
                onCustomAmount(_amountOf(numberFormat, value ?? '')),
          ),
        ],
      ),
    );
  }

  /// The locale's own format first, because [int.tryParse] reads nothing at all
  /// from a keyboard emitting Persian or Bengali digits - and plain digits
  /// after it, because those same locales' formats reject an ASCII `7`.
  static int? _amountOf(NumberFormat format, String value) {
    final num? amount = format.tryParse(value) ?? int.tryParse(value);
    return amount != null && amount.isFinite && amount > 0
        ? amount.toInt()
        : null;
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
              // Every row is outlined so all three read as pickable; only the
              // opacity moves, so selecting never shifts the list.
              border: Border.all(
                width: 2.0,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: selected ? 1.0 : 0.25),
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
  const _Ctas({
    required this.offer,
    required this.amount,
    required this.source,
  });

  final DonationOffer offer;
  final int amount;
  final DonationSource? source;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Column(
      children: <Widget>[
        SmoothLargeButtonWithIcon(
          text: appLocalizations.donation_cta_monthly,
          leadingIcon: const icons.Donate(),
          onPressed: () =>
              _open(offer.tier(amount).url(source: source), amount),
        ),
        TextButton(
          onPressed: () => _open(offer.oneOffUrl(source: source), 0),
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(MINIMUM_TOUCH_SIZE),
          ),
          child: Text(appLocalizations.donation_cta_one_off),
        ),
      ],
    );
  }

  Future<void> _open(String url, int monthlyAmount) async {
    AnalyticsHelper.trackEvent(
      AnalyticsEvent.donationHandoff,
      eventValue: monthlyAmount,
    );

    // Apple Pay and Google Pay disappear inside a webview, and a device with no
    // Custom Tabs provider silently gets url_launcher's own bundled one. Fall
    // back to a real browser instead, which keeps every payment method.
    final bool customTabs = await supportsLaunchMode(
      LaunchMode.inAppBrowserView,
    );

    return LaunchUrlHelper.launchURL(
      url,
      mode: customTabs
          ? LaunchMode.inAppBrowserView
          : LaunchMode.externalApplication,
    );
  }
}
