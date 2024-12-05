import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_full_refresh.dart';
import 'package:smooth_app/background/background_task_offline.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_last_access.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/pages/product/product_type_extensions.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class OfflineDataPage extends StatefulWidget {
  const OfflineDataPage({super.key});

  @override
  State<OfflineDataPage> createState() => _OfflineDataPageState();
}

class _OfflineDataPageState extends State<OfflineDataPage> {
  /// Number of Top N products to download.
  static const int _topNSize = 10000;

  /// Page size for download operations.
  static const int _pageSize = 100;

  @override
  Widget build(BuildContext context) {
    // TODO(ashaman999): replaace the header asset with a custom one for this page
    const String headerAsset = 'assets/preferences/main.svg';
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final double backgroundHeight = MediaQuery.sizeOf(context).height * .20;
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final DaoProductLastAccess daoProductLastAccess =
        DaoProductLastAccess(localDatabase);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: Text(appLocalizations.offline_data),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          children: <Widget>[
            Container(
              color: dark ? null : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
              child: SvgPicture.asset(
                headerAsset,
                height: backgroundHeight,
                package: AppHelper.APP_PACKAGE,
              ),
            ),
            _StatsWidget(
              daoProduct: daoProduct,
            ),
            for (final ProductType productType in ProductType.values)
              _OfflinePageListTile(
                title:
                    '${appLocalizations.download_data} (${productType.getLabel(appLocalizations)})',
                subtitle: appLocalizations.download_top_n_products(_topNSize),
                onTap: () async => BackgroundTaskOffline.addTask(
                  context: context,
                  pageSize: _pageSize,
                  totalSize: _topNSize,
                  productType: productType,
                ),
                trailing: const Icon(Icons.download),
              ),
            _OfflinePageListTile(
              title: appLocalizations.update_offline_data,
              subtitle: appLocalizations.update_local_database_sub,
              trailing: const Icon(Icons.refresh),
              onTap: () async => BackgroundTaskFullRefresh.addTask(
                context: context,
                pageSize: _pageSize,
              ),
            ),
            _OfflinePageListTile(
              title: appLocalizations.clear_local_database,
              subtitle: appLocalizations.clear_local_database_sub,
              trailing: const Icon(Icons.delete),
              onTap: () async {
                final int totalProductsDeleted = await daoProduct.deleteAll();
                await daoProductLastAccess.deleteAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        appLocalizations.deleted_products(totalProductsDeleted),
                      ),
                      duration: SnackBarDuration.brief,
                    ),
                  );
                }
                setState(() {});
              },
            ),
            _OfflinePageListTile(
              title: appLocalizations.know_more,
              subtitle: appLocalizations.offline_data_desc,
              trailing: const Icon(Icons.info),
              // ignore: avoid_returning_null_for_void
              onTap: () => null,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget to display the stats of the local databas, ie. the number of products
// in the database and the size of the database
class _StatsWidget extends StatelessWidget {
  const _StatsWidget({
    required this.daoProduct,
  });

  final DaoProduct daoProduct;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations applocalizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: ListTile(
        title: Text(applocalizations.offline_product_data_title),
        subtitle: FutureBuilder<Map<ProductType, int>>(
          future: daoProduct.getTotalNoOfProducts(),
          builder: (
            BuildContext context,
            AsyncSnapshot<Map<ProductType, int>> snapshot,
          ) {
            if (!snapshot.hasData) {
              return Text(applocalizations.loading);
            }
            int count = 0;
            final List<String> list = <String>[];
            for (final MapEntry<ProductType, int> item
                in snapshot.data!.entries) {
              count += item.value;
              list.add(
                  '${item.value} (${item.key.getLabel(applocalizations)})');
            }
            return Text(
              '${applocalizations.available_for_download(count)} ${list.join(', ')}',
            );
          },
        ),
        trailing: FutureBuilder<double>(
          future: daoProduct.getEstimatedTotalSizeInMB(),
          builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
            if (snapshot.hasData) {
              return Text('${snapshot.data} MB');
            } else {
              return const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator.adaptive(),
              );
            }
          },
        ),
      ),
    );
  }
}

// Widget to display a list tile with a title, subtitle
// and a trailing widget and an onTap callback for OfflineDataPage
class _OfflinePageListTile extends StatelessWidget {
  const _OfflinePageListTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
