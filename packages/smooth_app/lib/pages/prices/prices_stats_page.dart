import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';

class PricesStatsPage extends StatefulWidget {
  const PricesStatsPage({super.key});

  @override
  State<PricesStatsPage> createState() => _PricesStatsPageState();
}

class _PricesStatsPageState extends State<PricesStatsPage> {
  bool isLoading = true;
  Map<String, dynamic> statsData = <String, dynamic>{};
  String lastUpdated = '';

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      final Map<String, dynamic>? directResult = await _fetchStatsDirectly();
      if (directResult != null) {
        setState(() {
          statsData = directResult;
          isLoading = false;
          _updateTimestamp(directResult['updated']);
        });
        return;
      }

      final MaybeError<PriceTotalStats> result =
          await OpenPricesAPIClient.getStats();

      if (!result.isError) {
        final Map<String, dynamic> rawData = result.value.toJson();
        debugPrint('Raw data from API client: $rawData');

        if (rawData.containsKey('price_count') &&
            rawData['price_count'] != null) {
          setState(() {
            statsData = rawData;
            isLoading = false;
            _updateTimestamp(rawData['updated']);
          });
          return;
        }
      }

      setState(() {
        statsData = <String, dynamic>{};
        isLoading = false;
        lastUpdated = 'N/A';
      });
    } catch (e) {
      debugPrint('Exception while fetching stats: $e');
      setState(() {
        statsData = <String, dynamic>{};
        isLoading = false;
        lastUpdated = 'N/A';
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchStatsDirectly() async {
    try {
      const String apiUrl = 'https://prices.openfoodfacts.org/api/v1/stats';

      final http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(response.body) as Map<String, dynamic>;
        debugPrint(
            'Direct API response: ${response.body.substring(0, min(300, response.body.length))}...');
        return data;
      } else {
        debugPrint(
            'Direct API request failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error in direct API request: $e');
      return null;
    }
  }

  int min(int a, int b) => a < b ? a : b;

  void _updateTimestamp(dynamic timestamp) {
    if (timestamp != null) {
      try {
        final DateTime updatedTime = DateTime.parse(timestamp.toString());
        lastUpdated = _formatDateTime(updatedTime);
      } catch (e) {
        debugPrint('Error parsing timestamp: $e');
        lastUpdated = 'N/A';
      }
    } else {
      lastUpdated = 'N/A';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day} ${_getMonth(dateTime.month)} ${dateTime.year} at '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _getMonth(int month) {
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

  int _getSafeInt(String field) {
    try {
      final dynamic value = statsData[field];
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value) ?? 0;
      } else if (value is double) {
        return value.toInt();
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting field $field: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const CategoryHeader(
                        icon: Icons.attach_money,
                        title: 'Prices',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt('price_count').toString(),
                              label: 'Total',
                              hasArrow: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number:
                                  _getSafeInt('price_type_product_code_count')
                                      .toString(),
                              label: 'With a barcode',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number:
                                  _getSafeInt('price_type_category_tag_count')
                                      .toString(),
                              label: 'With a category',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt('price_with_discount_count')
                                  .toString(),
                              label: 'With a discount',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt('price_kind_community_count')
                                  .toString(),
                              label: 'Community',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number:
                                  _getSafeInt('price_kind_consumption_count')
                                      .toString(),
                              label: 'Consumption',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const CategoryHeader(
                        icon: Icons.inventory_2,
                        title: 'Products',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt('product_with_price_count')
                                  .toString(),
                              label: 'With a price',
                              hasArrow: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt('product_count').toString(),
                              label: 'Total',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number:
                                  '${_getSafeInt('product_source_off_with_price_count')} / ${_getSafeInt('product_source_off_count')}',
                              label: 'Food',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number:
                                  '${_getSafeInt('product_source_obf_with_price_count')} / ${_getSafeInt('product_source_obf_count')}',
                              label: 'Beauty',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number:
                                  '${_getSafeInt('product_source_opf_with_price_count')} / ${_getSafeInt('product_source_opf_count')}',
                              label: 'Products',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number:
                                  '${_getSafeInt('product_source_opff_with_price_count')} / ${_getSafeInt('product_source_opff_count')}',
                              label: 'Pet food',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const CategoryHeader(
                        icon: Icons.location_on,
                        title: 'Locations',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt('location_count').toString(),
                              label: 'Total',
                              hasArrow: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt('location_type_osm_count')
                                  .toString(),
                              label: 'OpenStreetMap',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt('location_type_online_count')
                                  .toString(),
                              label: 'Online',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number:
                                  _getSafeInt('price_location_country_count')
                                      .toString(),
                              label: 'Countries',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const CategoryHeader(
                        icon: Icons.camera_alt,
                        title: 'Proofs',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt('proof_count').toString(),
                              label: 'Total',
                              hasArrow: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt('proof_type_price_tag_count')
                                  .toString(),
                              label: 'Price tag',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt('proof_type_receipt_count')
                                  .toString(),
                              label: 'Receipt',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number:
                                  _getSafeInt('proof_type_gdpr_request_count')
                                      .toString(),
                              label: 'GDPR request',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number:
                                  _getSafeInt('proof_type_shop_import_count')
                                      .toString(),
                              label: 'Shop import',
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const CategoryHeader(
                        icon: Icons.people,
                        title: 'Contributors',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt('user_with_price_count')
                                  .toString(),
                              label: 'Total',
                              hasArrow: true,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const CategoryHeader(
                        icon: Icons.science,
                        title: 'Experiments',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: StatsCard(
                              number: '1',
                              label: 'Challenges',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt(
                                      'price_tag_status_linked_to_price_count')
                                  .toString(),
                              label: 'Prices linked to a price tag',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const CategoryHeader(
                        icon: Icons.miscellaneous_services,
                        title: 'Miscellaneous',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number:
                                  _getSafeInt('price_location_country_count')
                                      .toString(),
                              label: 'Countries',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number: _getSafeInt('price_currency_count')
                                  .toString(),
                              label: 'Currencies',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number:
                                  _getSafeInt('price_year_count').toString(),
                              label: 'Years',
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          'Prices and proofs per source',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number:
                                  '${_getSafeInt('price_source_web_count')} | ${_getSafeInt('proof_source_web_count')}',
                              label: 'Website',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number:
                                  '${_getSafeInt('price_source_mobile_count')} | ${_getSafeInt('proof_source_mobile_count')}',
                              label: 'Mobile app',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: StatsCard(
                              number:
                                  '${_getSafeInt('price_source_api_count')} | ${_getSafeInt('proof_source_api_count')}',
                              label: 'API',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatsCard(
                              number:
                                  '${_getSafeInt('price_source_other_count')} | ${_getSafeInt('proof_source_other_count')}',
                              label: 'Other',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Last updated on $lastUpdated',
                          style: const TextStyle(
                            color: Color(0xFFD3D3D3),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class CategoryHeader extends StatelessWidget {
  const CategoryHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.number,
    required this.label,
    this.hasArrow = false,
    this.url,
  });

  final String number;
  final String label;
  final bool hasArrow;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final Widget card = Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFBDBDBD),
                  ),
                ),
              ],
            ),
          ),
          if (hasArrow)
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 20,
            ),
        ],
      ),
    );

    if (hasArrow && url != null) {
      return InkWell(
        onTap: () => LaunchUrlHelper.launchURL(url!),
        borderRadius: BorderRadius.circular(6),
        child: card,
      );
    }

    return card;
  }
}
