import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/donation/donation_offer.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/bottom_cards/news/scan_news_provider.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/bottom_cards/scan_bottom_card.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/top_card/scan_search_card.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ScanMainCard extends StatelessWidget {
  const ScanMainCard();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScanNewsFeedProvider>(
      create: (BuildContext context) => ScanNewsFeedProvider(context),
      child: Consumer<ScanNewsFeedProvider>(
        builder: (BuildContext context, ScanNewsFeedProvider provider, _) {
          final ScanTagLineState state = provider.value;
          if (state is! ScanTagLineStateLoaded) {
            return const ScanSearchCard(expandedMode: true);
          }
          return Semantics(
            explicitChildNodes: true,
            child: LayoutBuilder(
              builder: (_, BoxConstraints constraints) => ListView(
                padding: EdgeInsetsDirectional.zero,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(
                        ScanSearchCard.computeMinSize(context),
                        constraints.maxHeight * 0.5,
                      ),
                    ),
                    child: const ScanSearchCard(expandedMode: false),
                  ),
                  const SizedBox(height: SMALL_SPACE),
                  if (state.donationStrip) ...const <Widget>[
                    _DonationStrip(),
                    SizedBox(height: SMALL_SPACE),
                  ],
                  const ScanBottomCard(dense: true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DonationStrip extends StatefulWidget {
  const _DonationStrip();

  static const String _impressionId = 'donation_strip';

  @override
  State<_DonationStrip> createState() => _DonationStripState();
}

class _DonationStripState extends State<_DonationStrip> {
  static final String _action = DonationTestArm.reminder.action(
    DonationSource.strip,
  );

  @override
  void initState() {
    super.initState();

    // On the preferences rather than this State: the carousel disposes
    // off-screen pages, so a swipe away and back would count twice.
    if (context.read<UserPreferences>().taglineFeedSessionImpressions.add(
      _DonationStrip._impressionId,
    )) {
      AnalyticsHelper.trackEvent(
        AnalyticsEvent.donationStripShown,
        action: _action,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final AppNewsState news = context.watch<AppNewsProvider>().state;
    final AppNewsFunding? funding = news is AppNewsStateLoaded
        ? news.content.donation?.funding
        : null;

    return Material(
      color: context.lightTheme()
          ? extension.primaryMedium
          : extension.primaryUltraBlack,
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        onTap: () => AppNavigator.of(
          context,
        ).push(AppRoutes.DONATE(DonationSource.strip)),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: MEDIUM_SPACE,
            end: VERY_SMALL_SPACE,
          ),
          child: Column(
            children: <Widget>[
              Row(
                spacing: SMALL_SPACE,
                children: <Widget>[
                  icons.Heart.filled(
                    size: 18.0,
                    color: extension.secondaryVibrant,
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).donation_page_headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const icons.Chevron.right(size: 14.0),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    icon: const icons.Close(size: 14.0),
                    onPressed: () => _close(context),
                  ),
                ],
              ),
              if (funding != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: MEDIUM_SPACE,
                    bottom: MEDIUM_SPACE,
                  ),
                  child: Row(
                    spacing: SMALL_SPACE,
                    children: <Widget>[
                      Expanded(
                        child: LinearProgressIndicator(
                          value: funding.progress,
                          semanticsValue: (funding.ratio * 100)
                              .round()
                              .toString(),
                          minHeight: VERY_SMALL_SPACE,
                          borderRadius: MAX_BORDER_RADIUS,
                          color: extension.secondaryVibrant,
                        ),
                      ),
                      Text(
                        NumberFormat.percentPattern(
                          ProductQuery.getLocaleString(),
                        ).format(funding.ratio),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _close(BuildContext context) {
    AnalyticsHelper.trackEvent(
      AnalyticsEvent.donationStripClosed,
      action: _action,
    );
    final AppNewsState news = context.read<AppNewsProvider>().state;
    final DonationOffer offer = DonationOffer.fromNews(
      news is AppNewsStateLoaded ? news.content.donation : null,
    );
    return context.read<UserPreferences>().hideDonationStrip(
      Duration(days: offer.stripHideDays),
    );
  }
}
