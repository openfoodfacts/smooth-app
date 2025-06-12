import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class PricesStatsPage extends StatefulWidget {
  const PricesStatsPage();

  @override
  State<PricesStatsPage> createState() => _PricesStatsPageState();
}

class _PricesStatsPageState extends State<PricesStatsPage> {
  MaybeError<PriceTotalStats>? _statsData;

  @override
  void initState() {
    super.initState();
    unawaited(_loadStats());
  }

  Future<void> _loadStats() async {
    try {
      _statsData = await OpenPricesAPIClient.getStats(
        uriHelper: ProductQuery.uriPricesHelper,
      );
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: Text(appLocalizations.prices_stats_title),
        leading: const SmoothBackButton(),
      ),
      body: _statsData == null
          ? const Center(child: CircularProgressIndicator())
          : _statsData!.isError
              ? Center(
                  child: ListTile(
                    title: Text(appLocalizations.prices_stats_error),
                    subtitle: Text(_statsData!.detailError),
                  ),
                )
              : _buildStatsContent(_statsData!.value, appLocalizations),
    );
  }

  Widget _buildStatsContent(
    final PriceTotalStats stats,
    final AppLocalizations appLocalizations,
  ) {
    final String? updated = _formatDateTime(stats.updated);
    return ListView(
      children: <Widget>[
        _getSectionHeader(
          Icons.attach_money,
          appLocalizations.prices_stats_prices_section,
          path: 'prices',
        ),
        _getDataTile(
          value: stats.priceCount,
          description: appLocalizations.prices_stats_total,
        ),
        _getDataTile(
          value: stats.priceTypeProductCodeCount,
          description: appLocalizations.prices_stats_with_barcode,
        ),
        _getDataTile(
          value: stats.priceTypeCategoryTagCount,
          description: appLocalizations.prices_stats_with_category,
        ),
        _getDataTile(
          value: stats.priceWithDiscountCount,
          description: appLocalizations.prices_stats_with_discount,
        ),
        _getDataTile(
          value: stats.priceKindCommunityCount,
          description: appLocalizations.prices_stats_community,
        ),
        _getDataTile(
          value: stats.priceKindConsumptionCount,
          description: appLocalizations.prices_stats_consumption,
        ),
        _getSectionHeader(
          Icons.inventory_2,
          appLocalizations.prices_stats_products_section,
          path: 'products',
        ),
        _getDataTile(
          value: stats.productCount,
          description: appLocalizations.prices_stats_total,
        ),
        _getDataTile(
          value: stats.productWithPriceCount,
          description: appLocalizations.prices_stats_with_price,
        ),
        _getDataTile(
          value: stats.productSourceOffWithPriceCount,
          denominator: stats.productSourceOffCount,
          description: appLocalizations.prices_stats_food,
        ),
        _getDataTile(
          value: stats.productSourceObfWithPriceCount,
          denominator: stats.productSourceObfCount,
          description: appLocalizations.prices_stats_beauty,
        ),
        _getDataTile(
          value: stats.productSourceOpfWithPriceCount,
          denominator: stats.productSourceOpfCount,
          description: appLocalizations.prices_stats_products,
        ),
        _getDataTile(
          value: stats.productSourceOpffWithPriceCount,
          denominator: stats.productSourceOpffCount,
          description: appLocalizations.prices_stats_pet_food,
        ),
        _getSectionHeader(
          Icons.location_on,
          appLocalizations.prices_stats_locations_section,
          path: 'locations',
        ),
        _getDataTile(
          value: stats.locationCount,
          description: appLocalizations.prices_stats_total,
        ),
        _getDataTile(
          value: stats.locationTypeOsmCount,
          description: appLocalizations.prices_stats_osm,
        ),
        _getDataTile(
          value: stats.locationTypeOnlineCount,
          description: appLocalizations.prices_stats_online,
        ),
        _getDataTile(
          value: stats.priceLocationCountryCount,
          description: appLocalizations.prices_stats_countries,
        ),
        _getSectionHeader(
          Icons.camera_alt,
          appLocalizations.prices_stats_proofs_section,
          path: 'proofs',
        ),
        _getDataTile(
          value: stats.proofCount,
          description: appLocalizations.prices_stats_total,
        ),
        _getDataTile(
          value: stats.proofTypePriceTagCount,
          description: appLocalizations.prices_stats_price_tag,
        ),
        _getDataTile(
          value: stats.proofTypeReceiptCount,
          description: appLocalizations.prices_stats_receipt,
        ),
        _getDataTile(
          value: stats.proofTypeGdprRequestCount,
          description: appLocalizations.prices_stats_gdpr_request,
        ),
        _getDataTile(
          value: stats.proofTypeShopImportCount,
          description: appLocalizations.prices_stats_shop_import,
        ),
        _getSectionHeader(
          Icons.people,
          appLocalizations.prices_stats_contributors_section,
          path: 'users',
        ),
        _getDataTile(
          value: stats.userWithPriceCount,
          description: appLocalizations.prices_stats_total,
        ),
        _getSectionHeader(
          Icons.science,
          appLocalizations.prices_stats_experiments_section,
        ),
        _getDataTile(
          value: stats.priceTagStatusLinkedToPriceCount,
          description: appLocalizations.prices_stats_linked_to_price_tag,
        ),
        _getSectionHeader(
          Icons.miscellaneous_services,
          appLocalizations.prices_stats_misc_section,
        ),
        _getDataTile(
          value: stats.priceLocationCountryCount,
          description: appLocalizations.prices_stats_countries,
        ),
        _getDataTile(
          value: stats.priceCurrencyCount,
          description: appLocalizations.prices_stats_currencies,
        ),
        _getDataTile(
          value: stats.priceYearCount,
          description: appLocalizations.prices_stats_years,
        ),
        _getSectionHeader(
          Icons.source,
          appLocalizations.prices_stats_by_source_title,
        ),
        _getDataTile(
          value: stats.priceSourceWebCount,
          denominator: stats.proofSourceWebCount,
          description: appLocalizations.prices_stats_website,
        ),
        _getDataTile(
          value: stats.priceSourceMobileCount,
          denominator: stats.proofSourceMobileCount,
          description: appLocalizations.prices_stats_mobile_app,
        ),
        _getDataTile(
          value: stats.priceSourceApiCount,
          denominator: stats.proofSourceApiCount,
          description: appLocalizations.prices_stats_api,
        ),
        _getDataTile(
          value: stats.priceSourceOtherCount,
          denominator: stats.proofSourceOtherCount,
          description: appLocalizations.prices_stats_other,
        ),
        if (updated != null)
          ListTile(
            title: Text(updated),
            subtitle: Text(appLocalizations.prices_stats_last_updated),
          ),
      ],
    );
  }

  Widget _getSectionHeader(
    final IconData iconData,
    final String description, {
    final String? path,
  }) =>
      ListTile(
        leading: Icon(iconData),
        title: Text(description),
        trailing: path == null ? null : const Icon(Icons.open_in_new),
        onTap: path == null
            ? null
            : () async => LaunchUrlHelper.launchURL(
                  OpenPricesAPIClient.getUri(
                    path: path,
                    uriHelper: ProductQuery.uriPricesHelper,
                  ).toString(),
                ),
      );

  Widget _getDataTile({
    required int? value,
    int? denominator,
    required String description,
  }) {
    if (value == null) {
      return EMPTY_WIDGET;
    }

    final String displayValue =
        denominator == null ? value.toString() : '$value / $denominator';

    return ListTile(
      title: Text(displayValue),
      subtitle: Text(description),
    );
  }

  static String? _formatDateTime(final DateTime? dateTime) => dateTime == null
      ? null
      : DateFormat.yMd(ProductQuery.getLanguage().offTag)
          .add_jms()
          .format(dateTime);
}
