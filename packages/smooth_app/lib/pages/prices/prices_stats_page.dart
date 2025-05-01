import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
  bool _isLoading = true;
  Map<String, dynamic>? _statsData;

  @override
  void initState() {
    super.initState();
    unawaited(_loadStats());
  }

  Future<void> _loadStats() async {
    try {
      final Map<String, dynamic>? result = await _fetchStats();
      _statsData = result;
    } catch (e) {
      _statsData = null;
    }
    setState(() {
      _isLoading = false;
    });
  }

  static Future<Map<String, dynamic>?> _fetchStats() async {
    try {
      const String apiUrl = 'https://prices.openfoodfacts.org/api/v1/stats';
      final http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      //
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: Text(
          localizations.prices_stats_title,
          maxLines: 2,
        ),
        leading: const SmoothBackButton(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_statsData == null
              ? Center(child: Text(localizations.prices_stats_error))
              : _buildStatsContent(context, localizations)),
    );
  }

  Widget _buildStatsContent(
      BuildContext context, AppLocalizations localizations) {
    return ListView(
      children: <Widget>[
        _getSectionHeader(
          Icons.attach_money,
          localizations.prices_stats_prices_section,
        ),
        _getDataTile(
          value: _getValue('price_count'),
          description: localizations.prices_stats_total,
          url: 'https://prices.openfoodfacts.org/prices',
        ),
        _getDataTile(
          value: _getValue('price_type_product_code_count'),
          description: localizations.prices_stats_with_barcode,
        ),
        _getDataTile(
          value: _getValue('price_type_category_tag_count'),
          description: localizations.prices_stats_with_category,
        ),
        _getDataTile(
          value: _getValue('price_with_discount_count'),
          description: localizations.prices_stats_with_discount,
        ),
        _getDataTile(
          value: _getValue('price_kind_community_count'),
          description: localizations.prices_stats_community,
        ),
        _getDataTile(
          value: _getValue('price_kind_consumption_count'),
          description: localizations.prices_stats_consumption,
        ),
        _getSectionHeader(
          Icons.inventory_2,
          localizations.prices_stats_products_section,
        ),
        _getDataTile(
          value: _getValue('product_count'),
          description: localizations.prices_stats_total,
          url: 'https://prices.openfoodfacts.org/products',
        ),
        _getDataTile(
          value: _getValue('product_with_price_count'),
          description: localizations.prices_stats_with_price,
        ),
        _getDataTile(
          value: _getValue('product_source_off_with_price_count'),
          denominator: _getValue('product_source_off_count'),
          description: localizations.prices_stats_food,
        ),
        _getDataTile(
          value: _getValue('product_source_obf_with_price_count'),
          denominator: _getValue('product_source_obf_count'),
          description: localizations.prices_stats_beauty,
        ),
        _getDataTile(
          value: _getValue('product_source_opf_with_price_count'),
          denominator: _getValue('product_source_opf_count'),
          description: localizations.prices_stats_products,
        ),
        _getDataTile(
          value: _getValue('product_source_opff_with_price_count'),
          denominator: _getValue('product_source_opff_count'),
          description: localizations.prices_stats_pet_food,
        ),
        _getSectionHeader(
          Icons.location_on,
          localizations.prices_stats_locations_section,
        ),
        _getDataTile(
          value: _getValue('location_count'),
          description: localizations.prices_stats_total,
          url: 'https://prices.openfoodfacts.org/locations',
        ),
        _getDataTile(
          value: _getValue('location_type_osm_count'),
          description: localizations.prices_stats_osm,
        ),
        _getDataTile(
          value: _getValue('location_type_online_count'),
          description: localizations.prices_stats_online,
        ),
        _getDataTile(
          value: _getValue('price_location_country_count'),
          description: localizations.prices_stats_countries,
        ),
        _getSectionHeader(
          Icons.camera_alt,
          localizations.prices_stats_proofs_section,
        ),
        _getDataTile(
          value: _getValue('proof_count'),
          description: localizations.prices_stats_total,
          url: 'https://prices.openfoodfacts.org/proofs',
        ),
        _getDataTile(
          value: _getValue('proof_type_price_tag_count'),
          description: localizations.prices_stats_price_tag,
        ),
        _getDataTile(
          value: _getValue('proof_type_receipt_count'),
          description: localizations.prices_stats_receipt,
        ),
        _getDataTile(
          value: _getValue('proof_type_gdpr_request_count'),
          description: localizations.prices_stats_gdpr_request,
        ),
        _getDataTile(
          value: _getValue('proof_type_shop_import_count'),
          description: localizations.prices_stats_shop_import,
        ),
        _getSectionHeader(
          Icons.people,
          localizations.prices_stats_contributors_section,
        ),
        _getDataTile(
          value: _getValue('user_with_price_count'),
          description: localizations.prices_stats_total,
          url: 'https://prices.openfoodfacts.org/users',
        ),
        _getSectionHeader(
          Icons.science,
          localizations.prices_stats_experiments_section,
        ),
        _getDataTile(
          value: _getValue('price_tag_status_linked_to_price_count'),
          description: localizations.prices_stats_linked_to_price_tag,
        ),
        _getSectionHeader(
          Icons.miscellaneous_services,
          localizations.prices_stats_misc_section,
        ),
        _getDataTile(
          value: _getValue('price_location_country_count'),
          description: localizations.prices_stats_countries,
        ),
        _getDataTile(
          value: _getValue('price_currency_count'),
          description: localizations.prices_stats_currencies,
        ),
        _getDataTile(
          value: _getValue('price_year_count'),
          description: localizations.prices_stats_years,
        ),
        _getSectionHeader(
          Icons.source,
          localizations.prices_stats_by_source_title,
        ),
        _getDataTile(
          value: _getValue('price_source_web_count'),
          denominator: _getValue('proof_source_web_count'),
          description: localizations.prices_stats_website,
        ),
        _getDataTile(
          value: _getValue('price_source_mobile_count'),
          denominator: _getValue('proof_source_mobile_count'),
          description: localizations.prices_stats_mobile_app,
        ),
        _getDataTile(
          value: _getValue('price_source_api_count'),
          denominator: _getValue('proof_source_api_count'),
          description: localizations.prices_stats_api,
        ),
        _getDataTile(
          value: _getValue('price_source_other_count'),
          denominator: _getValue('proof_source_other_count'),
          description: localizations.prices_stats_other,
        ),
        if (_statsData!.containsKey('updated') &&
            _statsData!['updated'] != null)
          ListTile(
            title:
                Text(_formatDateTime(_statsData!['updated'].toString()) ?? ' '),
            subtitle: Text(
              localizations.prices_stats_last_updated,
            ),
          ),
      ],
    );
  }

  Widget _getSectionHeader(IconData iconData, String description) {
    return ListTile(
      leading: Icon(iconData),
      title: Text(
        description,
      ),
    );
  }

  Widget _getDataTile({
    required int? value,
    int? denominator,
    required String description,
    String? url,
  }) {
    if (value == null) {
      return EMPTY_WIDGET;
    }

    final String displayValue =
        denominator == null ? value.toString() : '$value / $denominator';

    return ListTile(
      title: Text(displayValue),
      subtitle: Text(description),
      trailing: url == null ? null : const Icon(Icons.open_in_new),
      onTap: url == null ? null : () async => LaunchUrlHelper.launchURL(url),
    );
  }

  int? _getValue(final String tag) =>
      _statsData == null ? null : _statsData![tag] as int?;

  String? _formatDateTime(String dateTimeStr) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeStr);
      return DateFormat.yMd(ProductQuery.getLanguage().offTag)
          .add_jms()
          .format(dateTime);
    } catch (e) {
      return null;
    }
  }
}
