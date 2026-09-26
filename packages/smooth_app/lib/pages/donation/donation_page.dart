import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/donation/donation_offer.dart';
import 'package:smooth_app/pages/donation/donation_tier_row.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/v2/smooth_leading_button.dart';
import 'package:smooth_app/widgets/v2/smooth_scaffold2.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

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
                  customAmountActive: _customAmount != null,
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
    required this.customAmountActive,
    required this.customAmountController,
    required this.onSelected,
    required this.onCustomAmount,
  });

  final DonationOffer offer;

  /// Always one of [DonationOffer.amounts], where [selectedAmount] can also be
  /// whatever was typed into the custom field.
  final int ladderAmount;
  final int selectedAmount;
  final bool customAmountActive;
  final TextEditingController customAmountController;
  final ValueChanged<int> onSelected;
  final ValueChanged<int?> onCustomAmount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final NumberFormat amountFormat = offer.amountFormat(
      appLocalizations.localeName,
    );
    final NumberFormat numberFormat = offer.numberFormat(
      appLocalizations.localeName,
    );
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
            DonationTierRow(
              selected: tier.amount == selectedAmount,
              amount: appLocalizations.donation_tier_amount_monthly(
                amountFormat.format(tier.amount),
              ),
              scans: appLocalizations.donation_tier_scans(
                numberFormat.format(tier.scans),
              ),
              onTap: () => onSelected(tier.amount),
            ),
          _CustomAmountField(
            active: customAmountActive,
            controller: customAmountController,
            currencySymbol: amountFormat.currencySymbol,
            numberFormat: numberFormat,
            onCustomAmount: onCustomAmount,
          ),
        ],
      ),
    );
  }
}

/// A nested [Theme] rather than a new parameter on a field with 50 other call
/// sites: its `filled: true` picks up the primary-button fill, and its unset
/// state borders would draw a second ring inside [DonationLadderOutline].
class _CustomAmountField extends StatelessWidget {
  const _CustomAmountField({
    required this.active,
    required this.controller,
    required this.currencySymbol,
    required this.numberFormat,
    required this.onCustomAmount,
  });

  final bool active;
  final TextEditingController controller;
  final String currencySymbol;
  final NumberFormat numberFormat;
  final ValueChanged<int?> onCustomAmount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    const InputBorder blank = OutlineInputBorder(
      borderRadius: ROUNDED_BORDER_RADIUS,
      borderSide: BorderSide(color: Colors.transparent, width: 5.0),
    );

    return DonationLadderOutline(
      active: active,
      child: Theme(
        data: theme.copyWith(
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            fillColor: Colors.transparent,
            focusedBorder: blank,
            errorBorder: blank,
            focusedErrorBorder: blank,
          ),
        ),
        child: SmoothTextFormField(
          type: TextFieldTypes.PLAIN_TEXT,
          controller: controller,
          hintText: appLocalizations.donation_custom_amount_hint,
          textInputType: TextInputType.number,
          maxLines: 1,
          borderRadius: ROUNDED_BORDER_RADIUS,
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
              child: Text(
                appLocalizations.donation_tier_amount_monthly(currencySymbol),
              ),
            ),
          ),
          onChanged: (String? value) =>
              onCustomAmount(_amountOf(numberFormat, value ?? '')),
        ),
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
        TextButton(
          onPressed: () => _alreadyDonated(context),
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(MINIMUM_TOUCH_SIZE),
          ),
          child: Text(appLocalizations.donation_already_donated),
        ),
      ],
    );
  }

  Future<void> _alreadyDonated(BuildContext context) async {
    AnalyticsHelper.trackEvent(
      AnalyticsEvent.donationAlreadyDonated,
      eventValue: source?.analyticsValue,
    );
    await context.read<UserPreferences>().muteDonationAsks(
      const Duration(days: 365),
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SmoothFloatingSnackbar.positive(
        context: context,
        text: AppLocalizations.of(context).donation_already_donated_thanks,
      ),
    );
  }

  Future<void> _open(String url, int monthlyAmount) async {
    AnalyticsHelper.trackEvent(
      AnalyticsEvent.donationHandoff,
      eventValue: monthlyAmount,
    );

    return LaunchUrlHelper.launchURLInBrowserView(url);
  }
}
