import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';

class PriceStats {
  PriceStats({
    required this.prices,
    required this.products,
    required this.locations,
    required this.proofs,
    required this.contributors,
    required this.experiments,
    required this.misc,
    required this.sources,
    required this.lastUpdated,
  });

  factory PriceStats.fromJson(Map<String, dynamic> json) {
    String formattedDate = 'N/A';

    if (json.containsKey('updated') && json['updated'] != null) {
      try {
        final DateTime updatedTime = DateTime.parse(json['updated'].toString());
        formattedDate = _formatDateTime(updatedTime);
      } catch (e) {
        // Empty catch block, but avoiding errors without printing
      }
    }

    return PriceStats(
      prices: <String, int>{
        'total': _getSafeInt(json, 'price_count'),
        'with_barcode': _getSafeInt(json, 'price_type_product_code_count'),
        'with_category': _getSafeInt(json, 'price_type_category_tag_count'),
        'with_discount': _getSafeInt(json, 'price_with_discount_count'),
        'community': _getSafeInt(json, 'price_kind_community_count'),
        'consumption': _getSafeInt(json, 'price_kind_consumption_count'),
      },
      products: <String, int>{
        'with_price': _getSafeInt(json, 'product_with_price_count'),
        'total': _getSafeInt(json, 'product_count'),
        'food_with_price':
            _getSafeInt(json, 'product_source_off_with_price_count'),
        'food_total': _getSafeInt(json, 'product_source_off_count'),
        'beauty_with_price':
            _getSafeInt(json, 'product_source_obf_with_price_count'),
        'beauty_total': _getSafeInt(json, 'product_source_obf_count'),
        'products_with_price':
            _getSafeInt(json, 'product_source_opf_with_price_count'),
        'products_total': _getSafeInt(json, 'product_source_opf_count'),
        'pet_food_with_price':
            _getSafeInt(json, 'product_source_opff_with_price_count'),
        'pet_food_total': _getSafeInt(json, 'product_source_opff_count'),
      },
      locations: <String, int>{
        'total': _getSafeInt(json, 'location_count'),
        'osm': _getSafeInt(json, 'location_type_osm_count'),
        'online': _getSafeInt(json, 'location_type_online_count'),
        'countries': _getSafeInt(json, 'price_location_country_count'),
      },
      proofs: <String, int>{
        'total': _getSafeInt(json, 'proof_count'),
        'price_tag': _getSafeInt(json, 'proof_type_price_tag_count'),
        'receipt': _getSafeInt(json, 'proof_type_receipt_count'),
        'gdpr_request': _getSafeInt(json, 'proof_type_gdpr_request_count'),
        'shop_import': _getSafeInt(json, 'proof_type_shop_import_count'),
      },
      contributors: <String, int>{
        'total': _getSafeInt(json, 'user_with_price_count'),
      },
      experiments: <String, int>{
        'challenges': 1,
        'linked_to_price_tag':
            _getSafeInt(json, 'price_tag_status_linked_to_price_count'),
      },
      misc: <String, int>{
        'countries': _getSafeInt(json, 'price_location_country_count'),
        'currencies': _getSafeInt(json, 'price_currency_count'),
        'years': _getSafeInt(json, 'price_year_count'),
      },
      sources: <String, String>{
        'website':
            '${_getSafeInt(json, 'price_source_web_count')} | ${_getSafeInt(json, 'proof_source_web_count')}',
        'mobile_app':
            '${_getSafeInt(json, 'price_source_mobile_count')} | ${_getSafeInt(json, 'proof_source_mobile_count')}',
        'api':
            '${_getSafeInt(json, 'price_source_api_count')} | ${_getSafeInt(json, 'proof_source_api_count')}',
        'other':
            '${_getSafeInt(json, 'price_source_other_count')} | ${_getSafeInt(json, 'proof_source_other_count')}',
      },
      lastUpdated: formattedDate,
    );
  }

  final Map<String, int> prices;
  final Map<String, int> products;
  final Map<String, int> locations;
  final Map<String, int> proofs;
  final Map<String, int> contributors;
  final Map<String, int> experiments;
  final Map<String, int> misc;
  final Map<String, String> sources;
  final String lastUpdated;

  static int _getSafeInt(Map<String, dynamic> data, String field) {
    try {
      final dynamic value = data[field];
      if (value is int) {
        return value;
      }
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      if (value is double) {
        return value.toInt();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day} ${_getMonth(dateTime.month)} ${dateTime.year} at '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  static String _getMonth(int month) {
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  // Static method to fetch stats data from API
  static Future<PriceStats?> fetchStats() async {
    try {
      final Map<String, dynamic>? directResult = await _fetchStatsDirectly();
      if (directResult != null) {
        return PriceStats.fromJson(directResult);
      }

      final MaybeError<PriceTotalStats> result =
          await OpenPricesAPIClient.getStats();
      if (!result.isError) {
        final Map<String, dynamic> rawData = result.value.toJson();
        if (rawData.containsKey('price_count') &&
            rawData['price_count'] != null) {
          return PriceStats.fromJson(rawData);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _fetchStatsDirectly() async {
    try {
      const String apiUrl = 'https://prices.openfoodfacts.org/api/v1/stats';
      final http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
