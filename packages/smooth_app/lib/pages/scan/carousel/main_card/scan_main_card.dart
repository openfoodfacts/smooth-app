import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/bottom_cards/scan_bottom_card.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/top_card/scan_search_card.dart';

class ScanMainCard extends StatelessWidget {
  const ScanMainCard();

  @override
  Widget build(BuildContext context) {
    return ConsumerFilter<AppNewsProvider>(
      buildWhen:
          (AppNewsProvider? previousValue, AppNewsProvider currentValue) {
            return previousValue?.hasContent != currentValue.hasContent;
          },
      builder: (BuildContext context, AppNewsProvider newsFeed, _) {
        if (!newsFeed.hasContent) {
          return const ScanSearchCard(expandedMode: true);
        } else {
          return Semantics(
            explicitChildNodes: true,
            child: LayoutBuilder(
              builder: (_, BoxConstraints constraints) {
                final bool dense =
                    constraints.maxHeight * 0.4 <=
                    _maxHeight(context.textScaler());

                if (dense) {
                  return ListView(
                    padding: EdgeInsets.zero,
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
                      const ScanBottomCard(dense: true),
                    ],
                  );
                } else {
                  return const Column(
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: ScanSearchCard(expandedMode: false),
                      ),
                      SizedBox(height: SMALL_SPACE),
                      Expanded(flex: 4, child: ScanBottomCard(dense: false)),
                    ],
                  );
                }
              },
            ),
          );
        }
      },
    );
  }

  double _maxHeight(double textScaler) {
    if (textScaler < 1.1) {
      return 160.0;
    } else if (textScaler < 1.3) {
      return 173.0;
    } else {
      return 186.0;
    }
  }
}
