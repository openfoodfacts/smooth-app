import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';

class OfflineDataScreen extends StatefulWidget {
  const OfflineDataScreen();
  @override
  State<OfflineDataScreen> createState() => _OfflineDataScreenState();
}

int length = 0;
double size = 0;

class _OfflineDataScreenState extends State<OfflineDataScreen> {
  Future<void> getDetails(DaoProduct daoProduct) async {
    length = await daoProduct.getLength() ?? 0;
    size = await daoProduct.getSize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final DaoProduct daoProduct = DaoProduct(context.watch<LocalDatabase>());
    getDetails(daoProduct);
    final DaoProductList daoProductList =
        DaoProductList(context.watch<LocalDatabase>());
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    // TODO(monsieurtanuki): experimental - find a better value
    const double titleHeightInExpandedMode = 50;
    final double backgroundHeight = mediaQueryData.size.height * .20;
    // TODO(monsieurtanuki): get rid of explicit foregroundColor when appbartheme colors are correct
    final Color? foregroundColor = dark ? null : Colors.black;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              snap: false,
              floating: false,
              stretch: true,
              centerTitle: true,
              backgroundColor: dark ? null : Colors.white,
              expandedHeight: backgroundHeight + titleHeightInExpandedMode,
              foregroundColor: foregroundColor,
              // Force a light status bar
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Offline Mode',
                  style: TextStyle(color: foregroundColor),
                ),
                background: Padding(
                  padding:
                      const EdgeInsets.only(bottom: titleHeightInExpandedMode),
                  child: SvgPicture.asset(
                    'assets/preferences/main.svg',
                    height: backgroundHeight,
                  ),
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      dense: true,
                      title: Text(
                        'Offline Product Data',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      subtitle: Text(
                        '$length products available for immediate scanning',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        '$size Mb',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    ListTile(
                      trailing: const Icon(Icons.refresh),
                      onTap: () async {
                        await daoProduct.getFreshLocalDataBase();
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$length products refreshed'),
                          ),
                        );
                      },
                      title: Text(
                        'Refresh Offline Data',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      subtitle: const Text(
                        'Refresh the offline data base with the latest data from the server',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      trailing: const Icon(Icons.delete),
                      onTap: () async {
                        final int noOdDeletedProducts =
                            await daoProduct.clearAll();
                        await daoProductList.clearAll();
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '$noOdDeletedProducts products deleted, freed $size Mb'),
                          ),
                        );
                      },
                      title: Text(
                        'Clear Offline Data',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      subtitle: const Text(
                        'Clear All Offline Data and Free up space',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                        trailing: const Icon(Icons.info),
                        title: Text(
                          'Know More ',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        subtitle: const Text(
                          'Click to know more about the offline mode',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                ),
              );
            }, childCount: 1)),
          ],
        ),
      ),
    );
  }
}
