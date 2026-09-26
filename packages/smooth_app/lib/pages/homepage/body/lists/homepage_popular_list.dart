import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/homepage/body/homepage_list_title.dart';
import 'package:smooth_app/pages/homepage/body/homepage_scanned_list.dart';

class HomePageMostScannedProducts extends StatelessWidget {
  const HomePageMostScannedProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return HomePageListContainer(
      title: appLocalizations.homepage_list_most_scanned_title,
      sliver: const SliverToBoxAdapter(
        child: HomePageHorizontalList<Product>(
          items: <HomePageHorizontalListItem<Product>>[],
        ),
      ),
    );
  }
}
