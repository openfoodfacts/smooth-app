import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/prices/prices_stats_model.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

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
    final Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),
        ],
      ),
    );
  }
}

class StatsListTile extends StatelessWidget {
  const StatsListTile({
    super.key,
    required this.number,
    required this.label,
    required this.icon,
    this.onTap,
    this.showRedirectArrow = false,
  });

  final String number;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showRedirectArrow;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = dark ? const Color(0xFF303030) : Colors.white;
    final Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      color: cardColor,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        leading: Icon(icon, color: textColor, size: 24),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: textColor,
              ),
        ),
        trailing: Container(
          constraints: const BoxConstraints(minWidth: 80),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Flexible(
                child: Text(
                  number,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
              if (showRedirectArrow)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.chevron_right,
                    color: textColor,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class PricesStatsPage extends StatefulWidget {
  const PricesStatsPage({super.key});

  @override
  State<PricesStatsPage> createState() => _PricesStatsPageState();
}

class _PricesStatsPageState extends State<PricesStatsPage> {
  bool isLoading = true;
  PriceStats? statsData;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final PriceStats? result = await PriceStats.fetchStats();
    setState(() {
      statsData = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: Text(
          localizations.prices_stats_title,
          maxLines: 2,
        ),
        leading: const SmoothBackButton(),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (statsData == null
              ? Center(
                  child: Text(
                  localizations.prices_stats_error,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ))
              : Scrollbar(
                  controller: _controller,
                  child: _buildStatsContent(
                      context, localizations, statsData!, dark),
                )),
    );
  }

  Widget _buildStatsContent(BuildContext context,
      AppLocalizations localizations, PriceStats stats, bool dark) {
    final Color subtitleColor = dark
        ? const Color(0xFFBDBDBD)
        : Theme.of(context).textTheme.bodySmall!.color!;

    return SingleChildScrollView(
      controller: _controller,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Prices Section
            CategoryHeader(
              icon: Icons.attach_money,
              title: localizations.prices_stats_prices_section,
            ),
            const SizedBox(height: 12),
            _buildListItems(<List<dynamic>>[
              <dynamic>[
                stats.prices['total'].toString(),
                localizations.prices_stats_total,
                Icons.attach_money,
                true,
                'https://prices.openfoodfacts.org/prices'
              ],
              <dynamic>[
                stats.prices['with_barcode'].toString(),
                localizations.prices_stats_with_barcode,
                Icons.qr_code
              ],
              <dynamic>[
                stats.prices['with_category'].toString(),
                localizations.prices_stats_with_category,
                Icons.category
              ],
              <dynamic>[
                stats.prices['with_discount'].toString(),
                localizations.prices_stats_with_discount,
                Icons.discount
              ],
              <dynamic>[
                stats.prices['community'].toString(),
                localizations.prices_stats_community,
                Icons.people
              ],
              <dynamic>[
                stats.prices['consumption'].toString(),
                localizations.prices_stats_consumption,
                Icons.shopping_cart
              ],
            ]),
            const SizedBox(height: 24),

            // Products Section
            CategoryHeader(
              icon: Icons.inventory_2,
              title: localizations.prices_stats_products_section,
            ),
            const SizedBox(height: 12),
            _buildListItems(<List<dynamic>>[
              <dynamic>[
                stats.products['with_price'].toString(),
                localizations.prices_stats_with_price,
                Icons.inventory_2
              ],
              <dynamic>[
                stats.products['total'].toString(),
                localizations.prices_stats_total,
                Icons.inventory_2,
                true,
                'https://prices.openfoodfacts.org/products'
              ],
              <dynamic>[
                '${stats.products['food_with_price']} / ${stats.products['food_total']}',
                localizations.prices_stats_food,
                Icons.fastfood
              ],
              <dynamic>[
                '${stats.products['beauty_with_price']} / ${stats.products['beauty_total']}',
                localizations.prices_stats_beauty,
                Icons.spa
              ],
              <dynamic>[
                '${stats.products['products_with_price']} / ${stats.products['products_total']}',
                localizations.prices_stats_products,
                Icons.shopping_bag
              ],
              <dynamic>[
                '${stats.products['pet_food_with_price']} / ${stats.products['pet_food_total']}',
                localizations.prices_stats_pet_food,
                Icons.pets
              ],
            ]),
            const SizedBox(height: 24),

            // Locations Section
            CategoryHeader(
              icon: Icons.location_on,
              title: localizations.prices_stats_locations_section,
            ),
            const SizedBox(height: 12),
            _buildListItems(<List<dynamic>>[
              <dynamic>[
                stats.locations['total'].toString(),
                localizations.prices_stats_total,
                Icons.location_on,
                true,
                'https://prices.openfoodfacts.org/locations'
              ],
              <dynamic>[
                stats.locations['osm'].toString(),
                localizations.prices_stats_osm,
                Icons.map
              ],
              <dynamic>[
                stats.locations['online'].toString(),
                localizations.prices_stats_online,
                Icons.public
              ],
              <dynamic>[
                stats.locations['countries'].toString(),
                localizations.prices_stats_countries,
                Icons.flag
              ],
            ]),
            const SizedBox(height: 24),

            // Proofs Section
            CategoryHeader(
              icon: Icons.camera_alt,
              title: localizations.prices_stats_proofs_section,
            ),
            const SizedBox(height: 12),
            _buildListItems(<List<dynamic>>[
              <dynamic>[
                stats.proofs['total'].toString(),
                localizations.prices_stats_total,
                Icons.camera_alt,
                true,
                'https://prices.openfoodfacts.org/proofs'
              ],
              <dynamic>[
                stats.proofs['price_tag'].toString(),
                localizations.prices_stats_price_tag,
                Icons.local_offer
              ],
              <dynamic>[
                stats.proofs['receipt'].toString(),
                localizations.prices_stats_receipt,
                Icons.receipt
              ],
              <dynamic>[
                stats.proofs['gdpr_request'].toString(),
                localizations.prices_stats_gdpr_request,
                Icons.security
              ],
              <dynamic>[
                stats.proofs['shop_import'].toString(),
                localizations.prices_stats_shop_import,
                Icons.store
              ],
            ]),
            const SizedBox(height: 24),

            // Contributors Section
            CategoryHeader(
              icon: Icons.people,
              title: localizations.prices_stats_contributors_section,
            ),
            const SizedBox(height: 12),
            _buildListItems(<List<dynamic>>[
              <dynamic>[
                stats.contributors['total'].toString(),
                localizations.prices_stats_total,
                Icons.people,
                true,
                'https://prices.openfoodfacts.org/users'
              ],
            ]),
            const SizedBox(height: 24),

            // Experiments Section
            CategoryHeader(
              icon: Icons.science,
              title: localizations.prices_stats_experiments_section,
            ),
            const SizedBox(height: 12),
            _buildListItems(<List<dynamic>>[
              <dynamic>[
                stats.experiments['challenges'].toString(),
                localizations.prices_stats_challenges,
                Icons.emoji_events
              ],
              <dynamic>[
                stats.experiments['linked_to_price_tag'].toString(),
                localizations.prices_stats_linked_to_price_tag,
                Icons.link
              ],
            ]),
            const SizedBox(height: 24),

            // Misc Section
            CategoryHeader(
              icon: Icons.miscellaneous_services,
              title: localizations.prices_stats_misc_section,
            ),
            const SizedBox(height: 12),
            _buildListItems(<List<dynamic>>[
              <dynamic>[
                stats.misc['countries'].toString(),
                localizations.prices_stats_countries,
                Icons.flag
              ],
              <dynamic>[
                stats.misc['currencies'].toString(),
                localizations.prices_stats_currencies,
                Icons.money
              ],
              <dynamic>[
                stats.misc['years'].toString(),
                localizations.prices_stats_years,
                Icons.date_range
              ],
            ]),
            const SizedBox(height: 24),

            // Sources Section
            CategoryHeader(
              icon: Icons.source,
              title: localizations.prices_stats_by_source_title,
            ),
            const SizedBox(height: 12),
            _buildListItems(<List<dynamic>>[
              <dynamic>[
                stats.sources['website'] ?? '',
                localizations.prices_stats_website,
                Icons.web
              ],
              <dynamic>[
                stats.sources['mobile_app'] ?? '',
                localizations.prices_stats_mobile_app,
                Icons.phone_android
              ],
              <dynamic>[
                stats.sources['api'] ?? '',
                localizations.prices_stats_api,
                Icons.code
              ],
              <dynamic>[
                stats.sources['other'] ?? '',
                localizations.prices_stats_other,
                Icons.more_horiz
              ],
            ]),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${localizations.prices_stats_last_updated} ${stats.lastUpdated}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: subtitleColor),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildListItems(List<List<dynamic>> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final List<dynamic> item = items[index];
        final String number = item[0] as String;
        final String label = item[1] as String;
        final IconData icon = item[2] as IconData;
        final bool showRedirectArrow = item.length > 3 && item[3] == true;
        final String? url = item.length > 4 ? (item[4] as String) : null;
        return StatsListTile(
          number: number,
          label: label,
          icon: icon,
          showRedirectArrow: showRedirectArrow,
          onTap: url != null ? () => LaunchUrlHelper.launchURL(url) : null,
        );
      },
    );
  }
}
