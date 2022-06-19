import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class OfflineDataScreen extends StatefulWidget {
  const OfflineDataScreen();
  @override
  State<OfflineDataScreen> createState() => _OfflineDataScreenState();
}

int length = 0;
double size = 0;

// TODO(ashaman999): update all the applocalizations
class _OfflineDataScreenState extends State<OfflineDataScreen> {
  Future<void> _getDetails(DaoProduct daoProduct) async {
    length = await daoProduct.getLength() ?? 0;
    size = await daoProduct.getSize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final DaoProduct daoProduct = DaoProduct(context.watch<LocalDatabase>());
    _getDetails(daoProduct);
    final DaoProductList daoProductList =
        DaoProductList(context.watch<LocalDatabase>());
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    const double titleHeightInExpandedMode = 50;
    final double backgroundHeight = mediaQueryData.size.height * .20;
    final Color? foregroundColor = dark ? null : Colors.black;
    final List<Widget> children = <Widget>[
      UserPreferencesListTile(
        title: const Text(
          'Offline Product Data',
        ),
        subtitle: Text(
          '$length products available for immediate scanning',
        ),
        trailing: Text(
          '$size Mb',
        ),
      ),
      UserPreferencesListTile(
        trailing: const Icon(Icons.refresh),
        onTap: () async {
          String? status = await LoadingDialog.run<String>(
            context: context,
            future: daoProduct.getFreshLocalDataBase(),
            title: 'Refreshing \n This may take a while',
            dismissible: true,
          );
          if (status == 'OK') {
            status = '$length items refreshed';
          }
          // TODO(ashaman999): dapproductlist.updateTimestamp();
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(status!),
            ),
          );
        },
        title: const Text(
          'Update Offline Data',
        ),
        subtitle: const Text(
          'Update the databse with the latest data from the server',
        ),
      ),
      UserPreferencesListTile(
        trailing: const Icon(Icons.delete),
        onTap: () async {
          final int noOdDeletedProducts = await daoProduct.clearAll();
          await daoProductList.clearAll();
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('$noOdDeletedProducts products deleted, freed $size Mb'),
            ),
          );
        },
        title: const Text(
          'Clear Offline Data',
        ),
        subtitle: const Text(
          'Clear All Offline Data and Free up space',
        ),
      ),
      UserPreferencesListTile(
        trailing: const Icon(Icons.info),
        title: const Text(
          'Know More ',
        ),
        subtitle: const Text(
          'Click to know more about the offline mode',
        ),
        onTap: () {
          // TODO(ashaman999): refrence the acutal link
          // Or maybe show something as an alert dialog
          launchUrl(
            Uri.parse('https://openfoodfacts.org/'),
          );
        },
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              snap: false,
              floating: false,
              stretch: true,
              backgroundColor: dark ? null : Colors.white,
              expandedHeight: backgroundHeight + titleHeightInExpandedMode,
              foregroundColor: foregroundColor,
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
                    // TODO(ashaman999): add a proper header image replacing this
                    'assets/preferences/main.svg',
                    height: backgroundHeight,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return children[index];
                },
                childCount: children.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
